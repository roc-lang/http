app [main!] {
	pf: platform "https://github.com/lukewilliamboswell/roc-platform-template-zig/releases/download/0.9/8GdFEvQYS3TeAZxKvTzCLVdQiomweGtXcdZkXNDEeABq.tar.zst",
	http: "../package/main.roc",
}

import pf.Stdout
import http.Method
import http.Request
import http.Response

text_response = |status, body| {
	Response.from_status(status)
		.add_header("Content-Type", "text/plain")
		.with_body(body.to_utf8())
}

route = |request|
	match (request.method(), request.uri()) {
		(GET, "/health") => text_response(200, "ok")
		(GET, "/widgets") => text_response(200, "[]")
		(POST, "/widgets") => text_response(201, "created")
		_ => text_response(404, "not found")
	}

main! = |_args| {
	request = Request.from_method(POST)
		.with_uri("/widgets")
	response = route(request)

	Stdout.line!("route status: ${response.status().to_str()}")
	Ok({})
}
