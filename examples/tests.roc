app [main!] {
	pf: platform "https://github.com/lukewilliamboswell/roc-platform-template-zig/releases/download/0.8/8qf28cxTaxwA16Xe3VBR7YSP2KLVUqDHiPpFYgyikEa1.tar.zst",
	http: "../package/main.roc",
}

import pf.Stdout
import http.Method
import http.Request
import http.Response

main! = |_args| {
	Stdout.line!("Run `roc test examples/tests.roc` to exercise the http package examples.")
	Ok({})
}

expect {
	request0 = Request.from_method(POST)
	request1 = Request.with_uri(request0, "https://example.com/messages")
	request2 = Request.add_header(request1, "Content-Type", "text/plain")
	request3 = Request.with_body(request2, Str.to_utf8("hello"))
	request = Request.with_timeout(request3, TimeoutMilliseconds(250))

	Request.method(request) == POST
		and Request.method_str(request) == "POST"
			and Request.uri(request) == "https://example.com/messages"
				and Request.headers(request) == [("Content-Type", "text/plain")]
					and Request.body(request) == Str.to_utf8("hello")
						and Request.timeout(request) == TimeoutMilliseconds(250)
}

expect {
	request = Request.from_method(Unknown("PROPFIND"))
	Request.method_str(request) == "PROPFIND"
}

expect {
	response0 = Response.from_status(204)
	response1 = Response.add_header(response0, "X-Test", "yes")
	response = Response.with_body(response1, [])

	Response.status(response) == 204
		and Response.headers(response) == [("X-Test", "yes")]
			and Response.body(response) == []
}
