# https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods
Method := [OPTIONS, GET, POST, PUT, DELETE, HEAD, TRACE, CONNECT, PATCH, QUERY, Unknown(Str)].{

	## Convert an HTTP method to its wire-format string.
	to_str : Method -> Str
	to_str = |method|
		match method {
			OPTIONS => "OPTIONS"
			GET => "GET"
			POST => "POST"
			PUT => "PUT"
			DELETE => "DELETE"
			HEAD => "HEAD"
			TRACE => "TRACE"
			CONNECT => "CONNECT"
			PATCH => "PATCH"
			QUERY => "QUERY"
			Unknown(str) => str
		}

	## Compare two methods without treating `Unknown("GET")` as `GET`.
	is_eq : Method, Method -> Bool
	is_eq = |left, right|
		match (left, right) {
			(OPTIONS, OPTIONS) => True
			(GET, GET) => True
			(POST, POST) => True
			(PUT, PUT) => True
			(DELETE, DELETE) => True
			(HEAD, HEAD) => True
			(TRACE, TRACE) => True
			(CONNECT, CONNECT) => True
			(PATCH, PATCH) => True
			(QUERY, QUERY) => True
			(Unknown(left_str), Unknown(right_str)) => left_str == right_str
			_ => False
		}
}
