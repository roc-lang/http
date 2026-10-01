app [main!] {
	http: "../package/main.roc",
}

import http.Method
import http.Request

timeout_to_str : Request -> Str
timeout_to_str = |request|
	match request.timeout() {
		NoTimeout => "no timeout"
		TimeoutMilliseconds(ms) => "${ms.to_str()}ms"
	}

main! = |_| {
	no_timeout = Request.from_method(GET)
		.with_uri("https://example.com/stream")
	bounded = no_timeout.with_timeout(TimeoutMilliseconds(1500))

	echo!("default: ${timeout_to_str(no_timeout)}\n")
	echo!("bounded: ${timeout_to_str(bounded)}\n")

	Ok({})
}
