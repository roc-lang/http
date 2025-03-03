module [
    Response,
    status,
    redirect,
    header,
    body,
    reserve_headers,
    content_type,
    etag,
    to_bytes_http1_1
    to_bytes_http2
]

## Example usage:
##
## Response.status(200)
##     .content_type("text/plain")
##     .content_encoding("gzip")
##     .header("X-Something", "blah")
##     .header("X-SomethingElse", "etc")
Response := {
    # In HTTP2 and HTTP3, status gets serialized differently from how it does in HTTP 1.1.
    status : U16,
    # In HTTP2 and HTTP3, commonly-used headers are encoded differently from less-common ones.
    headers : List({ key : [Common(CommonHeader), Uncommon(Str)], val : Str }),
    # All HTTP protocols support bodies of arbitrary bytes (not necessarily valid UTF-8).
    body : List U8,
}

# In HTTP2 and HTTP3, these common headers (e.g. Content-Type) are encoded differently from other headers.
# Specifically, they each have a hardcoded static table index: https://www.rfc-editor.org/rfc/rfc7541.html#appendix-A
# This list is not exposed, because we provide an abstraction over HTTP 1.1 and HTTP 2+ responses.
CommonHeader := [
    Authority,
    GET,
    POST,
    PathSlash,
    PathSlashIndexDotHtml,
    ShemeHttp,
    ShemeHttps,
    .. # TODO add the others
    Location,
    .. # TODO add the others
]

## Redirects can be Permanent (HTTP 301) or Temporary (Http 302),
## and include the URL that the response redirects to.
redirect : [Permanent, Temporary], Str -> Response
redirect = |permanence, url|
    {
        status: match permanence {
            Permanent => 301
            Temporary => 302
        },
        headers: [Common(Location, url)],
        body: [],
    }->Response

## Initialize a HTTP response with the given [status code](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status).
status : U16 -> Response
status = |u16|
    { status: u16, headers: [], body: [] }->Response

## Reserve space for this many additional headers. This can improve performance
## when you are about to append multiple headers.
reserve_headers : Response, U64 -> Response
reserve_headers = |Response(rec), count|
    rec..{ headers: resp.headers.reserve(count) }->Response

## Add the given header key and value to the response's headers, without verifying uniqueness.
##
## For performance, this does not verify anything about the header, so make sure
## not to include invalid content such as newlines. Also, some response headers
## are permitted to appear more than once, but many should be unique. Make sure not to
## add the same header key more than once if that header needs to be unique!
##
## In particular, note that the [Content-Length](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Length)
## header will be added automatically (based on the length of the body), so using
## `"Content-Length"` as a key here will create an invalid response!
header : Response, Str, Str -> Response
header = |Response(rec), key, value|
    rec..{ headers: resp.headers.append(Uncommon(key, value)) }->Response

## Adds a [Content-Type](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Type)
## header to the response.
content_type : Response, Str -> Response
content_type = |resp, val|
    resp.add_common_header(ContentType, val)

## Adds a [Content-Encoding](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Encoding)
## header to the response.
content_encoding : Response, Str -> Response
content_encoding = |resp, val|
    resp.add_common_header(ContentEncoding, val)

## Adds an [ETag](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/ETag)
## header to the response.
etag : Response, Str -> Response
etag = |resp, val|
    resp.add_common_header(ETag, val)

## Private helper for adding common headers to responses.
add_common_header : Response, CommonHeader, Str -> Response
add_common_header = |Response(rec), key, val|
    rec..{ headers: resp.headers.append({ key: Common(key), val}) }->Response

## This function does nothing, and only exists as a public service announcement never to set
## the `Content-Length` header manually. It will be set automatically!
content_length : Response -> Response
content_length = |resp|
    resp

## Sets the body of this response.
##
## Calling this more than once replaces the body with the given value.
## (This is different from heaaders, which get appended rather than replaced.)
body : Response, List U8 -> Response
body = |Response(rec), new_body|
    rec..{ body: new_body }->Response

## Converts to a HTTP 1.1 response.
to_bytes_http1_1 : Response -> List U8
to_bytes_http1_1 = |Response(resp)| {
    status_bytes = "HTTP/1.1 ${status_str_from_u16(resp.status)}".to_bytes()

    header_bytes = resp.headers.concat_map(|entry| {
        key = match entry.key {
            Common(k) => common_header_to_str(k)
            Uncommon(k) => (k)
        }

        # Headers use "\r\n" - https://www.rfc-editor.org/rfc/rfc2616#section-2.2
        # We include a leading newline because these go right after the status line.
        "\r\n${key}: ${entry.val}".to_bytes()
    })

    # We always include a Content-Length header for the length of the body.
    # Since we include it after the headers (which also all have leading newlines),
    # this also takes care of the blank line between the last header and the body.
    content_length = "\r\nContent-Length: ${resp.body.len().to_str()}\r\n\r\n".to_bytes()

    List.with_capacity(
        status_bytes.len()
        + header_bytes.len()
        + content_length.len()
        + resp.body.len()
    )
    .append(status_bytes)
    .append(header_bytes)
    .append(content_length)
    .append(resp.body)
}

## Used when serializing a HTTP 1.1 response.
status_str_from_u16 : U16 -> Str
status_str_from_u16 = |u16|
    match u16 {
        200 => "200 OK"
        201 => "201 Created"
        202 => "202 Accepted"
        203 => "203 Non-Authoritative Information"
        # ...
        500 | _ =>
            # When this is anything other than 500, the error is that
            # the server tried to return an invalid response status code.
            "500 Internal Server Error"
    }

to_http2_bytes : Response -> List U8
to_http2_bytes = |Response(resp)| {
    # HTTP/2 does not use status line, it uses pseudo-headers.
    # Status code is sent as :status pseudo-header
    status_header = ":status".to_bytes().append(" ".to_bytes()).append(resp.status.to_bytes())

    # Initialize headers list with status pseudo-header
    headers = [status_header]

    # Parse existing HTTP/1.1 headers into HTTP/2 format
    # In HTTP/2, headers don't have the HTTP/1.1 line endings
    if resp.headers != "" {
        # Split headers by CRLF
        header_lines = resp.headers.split("\r\n")

        # Process each header line
        headers = header_lines.walk(headers, |acc, line| {
            if line == "" {
                acc
            } else {
                # Split by first colon
                parts = line.split_first(":")

                when parts is Ok { name, value } {
                    # HTTP/2 headers are lowercase
                    header_name = name.trim().to_lowercase().to_bytes()
                    header_value = value.trim().to_bytes()

                    # Add header to accumulator
                    acc.append(header_name.append(" ".to_bytes()).append(header_value))
                } else {
                    # Skip invalid headers
                    acc
                }
            }
        })
    }

    # Add content-length header if not already present
    has_content_length = headers.any(|h| h.to_str().starts_with("content-length "))
    if !has_content_length {
        content_length_header = "content-length".to_bytes().append(" ".to_bytes()).append(resp.body.len().to_str().to_bytes())
        headers = headers.append(content_length_header)
    }

    # Calculate total size needed for headers frame and data frame
    headers_size = headers.walk(0, |acc, h| acc + h.len() + 2) # +2 for header encoding overhead

    # HTTP/2 frame consists of:
    # - 9-byte frame header
    # - Headers frame for headers
    # - Data frame for body

    # Allocate buffer with capacity for all frames
    capacity = 9 + headers_size + 9 + resp.body.len()
    result = List.with_capacity(capacity)

    # Add Headers frame
    # Frame Header: Length (3 bytes), Type (1 byte), Flags (1 byte), Reserved (1 bit), Stream ID (31 bits)
    header_length = headers_size.to_bytes_be(3) # 3-byte length field in big-endian
    frame_type = [0x01] # 0x01 = HEADERS frame
    frame_flags = [0x04] # 0x04 = END_HEADERS flag
    stream_id = [0x00, 0x00, 0x00, 0x01] # Stream ID 1

    result = result
        .append(header_length)
        .append(frame_type)
        .append(frame_flags)
        .append(stream_id)

    # Add all headers (in a real implementation, these would be HPACK encoded)
    headers.each(|h| {
        result = result.append(h)
    })

    # Add Data frame if body is not empty
    if resp.body.len() > 0 {
        # Frame Header for DATA frame
        data_length = resp.body.len().to_bytes_be(3) # 3-byte length field
        data_type = [0x00] # 0x00 = DATA frame
        data_flags = [0x01] # 0x01 = END_STREAM flag

        result = result
            .append(data_length)
            .append(data_type)
            .append(data_flags)
            .append(stream_id) # Same stream ID as headers
            .append(resp.body)
    } else {
        # If there's no body, set END_STREAM on the HEADERS frame
        # This is a simplification - in a real implementation we'd modify
        # the flags byte already in the buffer
        result.set(4, result.get(4) | 0x01) # Set END_STREAM bit
    }

    result
}

# Helper function to convert integer to big-endian bytes of specified length
to_bytes_be : Num a => a, Nat -> List U8
to_bytes_be = |num, length| {
    result = List.with_capacity(length)

    i = 0
    while i < length {
        shift = 8 * (length - 1 - i)
        byte = ((num >> shift) & 0xFF).to_u8()
        result = result.append([byte])

        i += 1
    }

    result
}
