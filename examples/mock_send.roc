app [main!] {
	pf: platform "https://github.com/lukewilliamboswell/roc-platform-template-zig/releases/download/0.8/8qf28cxTaxwA16Xe3VBR7YSP2KLVUqDHiPpFYgyikEa1.tar.zst",
	http: "../package/main.roc",
}

import pf.Stdout
import http.Method
import http.Request
import http.Response

mock_send = |request|
	if Request.method(request) == GET {
		response0 = Response.from_status(200)
		response1 = Response.add_header(response0, "Content-Type", "text/plain")
		Response.with_body(response1, Str.to_utf8("mock response for ${Request.uri(request)}"))
	} else {
		Response.from_status(405)
	}

main! = |_args| {
	request0 = Request.from_method(GET)
	request = Request.with_uri(request0, "https://example.com/offline")
	response = mock_send(request)

	Stdout.line!("mock status: ${Response.status(response).to_str()}")
	Ok({})
}
