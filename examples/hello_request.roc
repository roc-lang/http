app [main!] {
	http: "../package/main.roc",
}

import http.Method
import http.Request

main! = |_| {
	request = Request.from_method(GET)
		.with_uri("https://example.com/widgets")

	echo!("${request.method_str()} ${request.uri()}\n")
	Ok({})
}
