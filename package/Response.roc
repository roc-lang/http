Response :: {
	status : U16,
	headers : List((Str, Str)),
	body : List(U8),
}.{

	## Create a `Response` with the given HTTP status code and empty headers and body.
	from_status : U16 -> Response
	from_status = |initial_status|
		{
			status: initial_status,
			headers: [],
			body: [],
		}

	## Get the HTTP status code of the response.
	status : Response -> U16
	status = |resp| resp.status

	## Get the list of HTTP headers in the response.
	headers : Response -> List((Str, Str))
	headers = |resp| resp.headers

	## Get the body of the response.
	body : Response -> List(U8)
	body = |resp| resp.body

	## Set the HTTP status code of the response.
	with_status : Response, U16 -> Response
	with_status = |resp, new_status| { ..resp, status: new_status }

	## Set the response's exact list of [HTTP headers](https://en.wikipedia.org/wiki/List_of_HTTP_header_fields).
	##
	## The HTTP spec [allows](https://www.rfc-editor.org/rfc/rfc7230#section-3.2.2) multiple headers to
	## have the same name. However, some recipients may not interpret this the way you would hope
	## they would, so it's generally best to make all the header names unique.
	with_headers : Response, List((Str, Str)) -> Response
	with_headers = |resp, new_headers| { ..resp, headers: new_headers }

	## Add a header to the response's list of [HTTP headers](https://en.wikipedia.org/wiki/List_of_HTTP_header_fields).
	##
	## The HTTP spec [allows](https://www.rfc-editor.org/rfc/rfc7230#section-3.2.2) multiple headers to
	## have the same name. However, some recipients may not interpret this the way you would hope
	## they would, so it's generally best to make all the header names unique.
	add_header : Response, Str, Str -> Response
	add_header = |resp, name, value| { ..resp, headers: List.append(resp.headers, (name, value)) }

	## Set the body of the response.
	with_body : Response, List(U8) -> Response
	with_body = |resp, new_body| { ..resp, body: new_body }
}
