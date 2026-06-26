app [main!] {
	pf: platform "https://github.com/lukewilliamboswell/roc-platform-template-zig/releases/download/0.9/8GdFEvQYS3TeAZxKvTzCLVdQiomweGtXcdZkXNDEeABq.tar.zst",
	http: "../package/main.roc",
}

import pf.Stdout
import http.Method
import http.Request
import http.Response

text_response = |status, body| {
	response0 = Response.from_status(status)
	response1 = Response.add_header(response0, "Content-Type", "text/plain")
	Response.with_body(response1, Str.to_utf8(body))
}

route = |request|
	match (Request.method(request), Request.uri(request)) {
		(GET, "/health") => text_response(200, "ok")
		(GET, "/widgets") => text_response(200, "[]")
		(POST, "/widgets") => text_response(201, "created")
		_ => text_response(404, "not found")
	}

main! = |_args| {
	request0 = Request.from_method(POST)
	request = Request.with_uri(request0, "/widgets")
	response = route(request)

	Stdout.line!("route status: ${Response.status(response).to_str()}")
	Ok({})
}
