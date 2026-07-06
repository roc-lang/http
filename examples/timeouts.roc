app [main!] {
	pf: platform "https://github.com/lukewilliamboswell/roc-platform-template-zig/releases/download/1.0.0/AnZoxzoGPtSGQ15EQh6pBeeaHJ7aizP9MQhK81dES3Uq.tar.zst",
	http: "../package/main.roc",
}

import pf.Stdout
import http.Method
import http.Request

timeout_to_str : Request -> Str
timeout_to_str = |request|
	match request.timeout() {
		NoTimeout => "no timeout"
		TimeoutMilliseconds(ms) => "${ms.to_str()}ms"
	}

main! : List(Str) => Try({}, [Exit(I32), StdoutErr(Str), ..])
main! = |_args| {
	no_timeout = Request.from_method(GET)
		.with_uri("https://example.com/stream")
	bounded = no_timeout.with_timeout(TimeoutMilliseconds(1500))

	Stdout.line!("default: ${timeout_to_str(no_timeout)}")?
	Stdout.line!("bounded: ${timeout_to_str(bounded)}")?

	Ok({})
}
