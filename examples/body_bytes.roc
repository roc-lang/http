app [main!] {
	pf: platform "https://github.com/lukewilliamboswell/roc-platform-template-zig/releases/download/0.9/8GdFEvQYS3TeAZxKvTzCLVdQiomweGtXcdZkXNDEeABq.tar.zst",
	http: "../package/main.roc",
}

import pf.Stdout
import http.Method
import http.Request
import http.Response

bytes_to_str = |bytes|
	match Str.from_utf8(bytes) {
		Ok(str) => str
		Err(_) => "<invalid utf8>"
	}

main! = |_args| {
	request0 = Request.from_method(POST)
	request1 = Request.with_uri(request0, "https://example.com/messages")
	request = Request.with_body(request1, Str.to_utf8("hello"))

	response0 = Response.from_status(201)
	response = Response.with_body(response0, Str.to_utf8("created"))

	Stdout.line!("request body: ${bytes_to_str(Request.body(request))}")
	Stdout.line!("response body: ${bytes_to_str(Response.body(response))}")
	Ok({})
}
