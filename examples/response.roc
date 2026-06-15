app [main!] {
	pf: platform "https://github.com/lukewilliamboswell/roc-platform-template-zig/releases/download/0.8/8qf28cxTaxwA16Xe3VBR7YSP2KLVUqDHiPpFYgyikEa1.tar.zst",
	http: "../package/main.roc",
}

import pf.Stdout
import http.Response

main! = |_args| {
	response0 = Response.from_status(404)
	response1 = Response.add_header(response0, "Content-Type", "text/plain")
	response = Response.with_body(response1, Str.to_utf8("not found"))

	Stdout.line!("status: ${Response.status(response).to_str()}")
	Stdout.line!("headers: ${Response.headers(response).len().to_str()}")
	Stdout.line!("body bytes: ${Response.body(response).len().to_str()}")
	Ok({})
}
