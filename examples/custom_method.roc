app [main!] {
	http: "../package/main.roc",
}

import http.Method
import http.Request

main! = |_| {
	request = Request.from_method(Unknown("PROPFIND"))
		.with_uri("https://dav.example.com/docs")

	echo!("custom method: ${request.method_str()}\n")

	Ok({})
}
