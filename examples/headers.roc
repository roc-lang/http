app [main!] {
	pf: platform "https://github.com/lukewilliamboswell/roc-platform-template-zig/releases/download/0.8/8qf28cxTaxwA16Xe3VBR7YSP2KLVUqDHiPpFYgyikEa1.tar.zst",
	http: "../package/main.roc",
}

import pf.Stdout
import http.Method
import http.Request

header_to_str = |(name, value)|
	"${name}: ${value}"

headers_to_str = |headers|
	headers.map(header_to_str).join_with("\n")

main! = |_args| {
	request0 = Request.from_method(GET)
	request1 = Request.with_uri(request0, "https://api.example.com/items")
	request2 = Request.add_header(request1, "Accept", "application/json")
	request3 = Request.add_header(request2, "X-Trace-Id", "demo-123")
	request = Request.add_header(request3, "X-Trace-Id", "demo-456")

	Stdout.line!(headers_to_str(Request.headers(request)))
	Ok({})
}
