app [main!] {
	pf: platform "https://github.com/lukewilliamboswell/roc-platform-template-zig/releases/download/0.7/DuRUyJh31Gt41YArMcVcvybLa2bCWboccWQ7Zq1KZPZ6.tar.zst",
	http: "../package/main.roc",
}

import pf.Stdout
import http.Method
import http.Request

main! = |_args| {
	request0 = Request.from_method(Unknown("PROPFIND"))
	request = Request.with_uri(request0, "https://dav.example.com/docs")

	Stdout.line!("custom method: ${Request.method_str(request)}")
	Ok({})
}
