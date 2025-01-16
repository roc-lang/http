module [
    Request,
    Method,
    from_method,
    method,
    method_str,
    headers,
    uri,
    body,
    timeout,
    with_method,
    with_headers,
    add_header,
    with_uri,
    with_body,
    with_timeout,
]

# https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods
Method : [OPTIONS, GET, POST, PUT, DELETE, HEAD, TRACE, CONNECT, PATCH, Unknown Str]

Request := {
    method : Method,
    headers : List (Str, Str),
    uri : Str,
    body : List U8,
    timeout_ms : [TimeoutMilliseconds U64, NoTimeout], # TODO change to Duration once that's in builtins
}

from_method : Method -> Request
from_method = \initial_method ->
    @Request(
        {
            method: initial_method,
            headers: [],
            uri: "",
            body: [],
            timeout_ms: NoTimeout,
        },
    )

method : Request -> Method
method = \@Request(req) -> req.method

method_str : Request -> Str
method_str = \@Request(req) ->
    when req.method is
        OPTIONS -> "OPTIONS"
        GET -> "GET"
        POST -> "POST"
        PUT -> "PUT"
        DELETE -> "DELETE"
        HEAD -> "HEAD"
        TRACE -> "TRACE"
        CONNECT -> "CONNECT"
        PATCH -> "PATCH"
        Unknown str -> str

headers : Request -> List (Str, Str)
headers = \@Request(req) -> req.headers

body : Request -> List U8
body = \@Request(req) -> req.body

uri : Request -> Str
uri = \@Request(req) -> req.uri

timeout : Request -> [TimeoutMilliseconds U64, NoTimeout]
timeout = \@Request(req) -> req.timeout_ms

with_method : Request, Method -> Request
with_method = \@Request(req), new_method -> @Request({ req & method: new_method })

## Set the request's exact list of [HTTP headers](https://en.wikipedia.org/wiki/List_of_HTTP_header_fields).
##
## The HTTP spec [allows](https://www.rfc-editor.org/rfc/rfc7230#section-3.2.2) multiple headers to
## have the same name. However, some recipients may not interpret this the way you would hope
## they would, so it's generally best to make all the header names unique.
with_headers : Request, List (Str, Str) -> Request
with_headers = \@Request(req), new_headers -> @Request({ req & headers: new_headers })

## Add a header to the request's list of [HTTP headers](https://en.wikipedia.org/wiki/List_of_HTTP_header_fields).
##
## The HTTP spec [allows](https://www.rfc-editor.org/rfc/rfc7230#section-3.2.2) multiple headers to
## have the same name. However, some recipients may not interpret this the way you would hope
## they would, so it's generally best to make all the header names unique.
add_header : Request, Str, Str -> Request
add_header = \@Request(req), name, value -> @Request({ req & headers: List.append(req.headers, (name, value)) })

with_uri : Request, Str -> Request
with_uri = \@Request(req), new_uri -> @Request({ req & uri: new_uri })

with_body : Request, List U8 -> Request
with_body = \@Request(req), new_body -> @Request({ req & body: new_body })

with_timeout : Request, [TimeoutMilliseconds U64, NoTimeout] -> Request
with_timeout = \@Request(req), timeout_ms -> @Request({ req & timeout_ms })
