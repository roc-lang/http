app [main!] {
	pf: platform "https://github.com/lukewilliamboswell/roc-platform-template-zig/releases/download/0.7/DuRUyJh31Gt41YArMcVcvybLa2bCWboccWQ7Zq1KZPZ6.tar.zst",
	http: "../package/main.roc",
}

import pf.Stdout
import http.Method
import http.Request

timeout_to_str = |request|
	match Request.timeout(request) {
		NoTimeout => "no timeout"
		TimeoutMilliseconds(ms) => "${ms.to_str()}ms"
	}

main! = |_args| {
	base = Request.from_method(GET)
	no_timeout = Request.with_uri(base, "https://example.com/stream")
	bounded = Request.with_timeout(no_timeout, TimeoutMilliseconds(1500))

	Stdout.line!("default: ${timeout_to_str(no_timeout)}")
	Stdout.line!("bounded: ${timeout_to_str(bounded)}")
	Ok({})
}
