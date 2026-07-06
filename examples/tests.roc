app [main!] {
	pf: platform "https://github.com/lukewilliamboswell/roc-platform-template-zig/releases/download/0.9/8GdFEvQYS3TeAZxKvTzCLVdQiomweGtXcdZkXNDEeABq.tar.zst",
	http: "../package/main.roc",
}

import pf.Stdout
import http.Header
import http.Method
import http.Request
import http.Response

main! : List(Str) => Try({}, [Exit(I32)])
main! = |_args| {
	Stdout.line!("Run `roc test examples/tests.roc` to exercise the http package examples.")
	Ok({})
}

## Request builders set method, URI, headers, body, and timeout.
expect {
	request = Request.from_method(POST)
		.with_uri("https://example.com/messages")
		.add_header("Content-Type", "text/plain")
		.with_body("hello".to_utf8())
		.with_timeout(TimeoutMilliseconds(250))

	request.method() == POST
		and request.method_str() == "POST"
			and request.uri() == "https://example.com/messages"
				and request.headers() == [{ name: "Content-Type", value: "text/plain" }]
					and request.body() == "hello".to_utf8()
						and request.timeout() == TimeoutMilliseconds(250)
}

## Unknown methods keep their original wire value.
expect {
	request = Request.from_method(Unknown("PROPFIND"))
	request.method_str() == "PROPFIND"
}

## QUERY is available as a built-in HTTP method.
expect {
	request = Request.from_method(QUERY)
	query : Method
	query = QUERY

	request.method_str() == "QUERY" and query.to_str() == "QUERY"
}

## Method equality distinguishes known methods from unknown strings.
expect {
	query : Method
	query = QUERY

	get : Method
	get = GET

	unknown_query : Method
	unknown_query = Unknown("QUERY")

	propfind : Method
	propfind = Unknown("PROPFIND")

	query.is_eq(query)
		and !query.is_eq(get)
			and !unknown_query.is_eq(query)
				and propfind.is_eq(Unknown("PROPFIND"))
}

## Header helpers format and compare header records.
expect {
	header : Header
	header = { name: "Content-Type", value: "text/plain" }

	header.to_str() == "Content-Type: text/plain"
		and header.is_eq({ name: "Content-Type", value: "text/plain" })
			and !header.is_eq({ name: "Content-Type", value: "application/json" })
}

## Response builders set status, headers, and body.
expect {
	response = Response.from_status(204)
		.add_header("X-Test", "yes")
		.with_body([])

	response.status() == 204
		and response.headers() == [{ name: "X-Test", value: "yes" }]
			and response.body() == []
}
