app [main!] {
	pf: platform "https://github.com/lukewilliamboswell/roc-platform-template-zig/releases/download/0.9/8GdFEvQYS3TeAZxKvTzCLVdQiomweGtXcdZkXNDEeABq.tar.zst",
	http: "../package/main.roc",
}

import pf.Stdout
import http.Method
import http.Request
import http.Response

main! : List(Str) => Try({}, [Exit(I32)])
main! = |_args| {
	request = Request.from_method(POST)
		.with_uri("https://example.com/messages")
		.with_body("hello".to_utf8())

	response = Response.from_status(201)
		.with_body("created".to_utf8())

	Stdout.line!("request body: ${Str.inspect(request.body())}")

	Stdout.line!("response body: ${Str.inspect(response.body())}")

	Ok({})
}
