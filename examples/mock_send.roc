app [main!] {
	pf: platform "https://github.com/lukewilliamboswell/roc-platform-template-zig/releases/download/0.9/8GdFEvQYS3TeAZxKvTzCLVdQiomweGtXcdZkXNDEeABq.tar.zst",
	http: "../package/main.roc",
}

import pf.Stdout
import http.Method
import http.Request
import http.Response

mock_send = |request|
	if request.method() == GET {
		Response.from_status(200)
			.add_header("Content-Type", "text/plain")
			.with_body("mock response for ${request.uri()}".to_utf8())
	} else {
		Response.from_status(405)
	}

main! = |_args| {
	request = Request.from_method(GET)
		.with_uri("https://example.com/offline")
	response = mock_send(request)

	Stdout.line!("mock status: ${response.status().to_str()}")
	Ok({})
}
