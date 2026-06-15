app [main!] {
	pf: platform "https://github.com/lukewilliamboswell/roc-platform-template-zig/releases/download/0.8/8qf28cxTaxwA16Xe3VBR7YSP2KLVUqDHiPpFYgyikEa1.tar.zst",
	http: "../package/main.roc",
}

import pf.Stdout
import http.Method
import http.Request

main! = |_args| {
	request0 = Request.from_method(GET)
	request = Request.with_uri(request0, "https://example.com/widgets")

	Stdout.line!("${Request.method_str(request)} ${Request.uri(request)}")
	Ok({})
}
