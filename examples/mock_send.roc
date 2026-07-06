app [main!] {
	pf: platform "https://github.com/lukewilliamboswell/roc-platform-template-zig/releases/download/1.0.0/AnZoxzoGPtSGQ15EQh6pBeeaHJ7aizP9MQhK81dES3Uq.tar.zst",
	http: "../package/main.roc",
}

import pf.Stdout
import http.Method
import http.Request
import http.Response

mock_send : Request -> Response
mock_send = |request|
	if request.method() == GET {
		Response.from_status(200)
			.add_header("Content-Type", "text/plain")
			.with_body("mock response for ${request.uri()}".to_utf8())
	} else {
		Response.from_status(405)
	}

main! : List(Str) => Try({}, [Exit(I32), StdoutErr(Str), ..])
main! = |_args| {
	request = Request.from_method(GET)
		.with_uri("https://example.com/offline")

	response = mock_send(request)

	Stdout.line!("mock status: ${response.status().to_str()}")?

	Ok({})
}
