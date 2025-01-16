module [
    Response,
    from_status,
    status,
    headers,
    body,
    with_status,
    with_headers,
    add_header,
    with_body,
]

Response := {
    status : U16,
    headers : List (Str, Str),
    body : List U8,
}

from_status : U16 -> Response
from_status = \initial_status ->
    @Response(
        {
            status: initial_status,
            headers: [],
            body: [],
        },
    )

status : Response -> U16
status = \@Response(resp) -> resp.status

headers : Response -> List (Str, Str)
headers = \@Response(resp) -> resp.headers

body : Response -> List U8
body = \@Response(resp) -> resp.body

with_status : Response, U16 -> Response
with_status = \@Response(resp), new_status -> @Response({ resp & status: new_status })

## Set the response's exact list of [HTTP headers](https://en.wikipedia.org/wiki/List_of_HTTP_header_fields).
##
## The HTTP spec [allows](https://www.rfc-editor.org/rfc/rfc7230#section-3.2.2) multiple headers to
## have the same name. However, some recipients may not interpret this the way you would hope
## they would, so it's generally best to make all the header names unique.
with_headers : Response, List (Str, Str) -> Response
with_headers = \@Response(resp), new_headers -> @Response({ resp & headers: new_headers })

## Add a header to the response's list of [HTTP headers](https://en.wikipedia.org/wiki/List_of_HTTP_header_fields).
##
## The HTTP spec [allows](https://www.rfc-editor.org/rfc/rfc7230#section-3.2.2) multiple headers to
## have the same name. However, some recipients may not interpret this the way you would hope
## they would, so it's generally best to make all the header names unique.
add_header : Response, Str, Str -> Response
add_header = \@Response(resp), name, value -> @Response({ resp & headers: List.append(resp.headers, (name, value)) })

with_body : Response, List U8 -> Response
with_body = \@Response(resp), new_body -> @Response({ resp & body: new_body })
