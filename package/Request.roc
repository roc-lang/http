import Method

Request :: {
	method : Method,
	headers : List((Str, Str)),
	uri : Str,
	body : List(U8),
	timeout_ms : [TimeoutMilliseconds(U64), NoTimeout],
}.{

	## Create a `Request` with the given HTTP method and empty/default values for all other fields.
	from_method : Method -> Request
	from_method = |initial_method|
		{
			method: initial_method,
			headers: [],
			uri: "",
			body: [],
			timeout_ms: NoTimeout,
		}

	## Get the HTTP method of the request.
	method : Request -> Method
	method = |req| req.method

	## Get the HTTP method of the request as a string.
	method_str : Request -> Str
	method_str = |req|
		match req.method {
			OPTIONS => "OPTIONS"
			GET => "GET"
			POST => "POST"
			PUT => "PUT"
			DELETE => "DELETE"
			HEAD => "HEAD"
			TRACE => "TRACE"
			CONNECT => "CONNECT"
			PATCH => "PATCH"
			Unknown(str) => str
		}

	## Get the list of HTTP headers in the request.
	headers : Request -> List((Str, Str))
	headers = |req| req.headers

	## Get the body of the request.
	body : Request -> List(U8)
	body = |req| req.body

	## Get the URI of the request.
	uri : Request -> Str
	uri = |req| req.uri

	## Get the timeout of the request.
	timeout : Request -> [TimeoutMilliseconds(U64), NoTimeout]
	timeout = |req| req.timeout_ms

	## Set the HTTP method of the request.
	with_method : Request, Method -> Request
	with_method = |req, new_method| { ..req, method: new_method }

	## Set the request's exact list of [HTTP headers](https://en.wikipedia.org/wiki/List_of_HTTP_header_fields).
	##
	## The HTTP spec [allows](https://www.rfc-editor.org/rfc/rfc7230#section-3.2.2) multiple headers to
	## have the same name. However, some recipients may not interpret this the way you would hope
	## they would, so it's generally best to make all the header names unique.
	with_headers : Request, List((Str, Str)) -> Request
	with_headers = |req, new_headers| { ..req, headers: new_headers }

	## Add a header to the request's list of [HTTP headers](https://en.wikipedia.org/wiki/List_of_HTTP_header_fields).
	##
	## The HTTP spec [allows](https://www.rfc-editor.org/rfc/rfc7230#section-3.2.2) multiple headers to
	## have the same name. However, some recipients may not interpret this the way you would hope
	## they would, so it's generally best to make all the header names unique.
	add_header : Request, Str, Str -> Request
	add_header = |req, name, value| { ..req, headers: List.append(req.headers, (name, value)) }

	## Set the URI of the request.
	with_uri : Request, Str -> Request
	with_uri = |req, new_uri| { ..req, uri: new_uri }

	## Set the body of the request.
	with_body : Request, List(U8) -> Request
	with_body = |req, new_body| { ..req, body: new_body }

	## Set the timeout of the request.
	with_timeout : Request, [TimeoutMilliseconds(U64), NoTimeout] -> Request
	with_timeout = |req, timeout_ms| { ..req, timeout_ms: timeout_ms }
}
