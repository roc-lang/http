app [main!] {
	http: "../package/main.roc",
}

import http.Method
import http.Request
import http.Response

main! = |_| {
	request = Request.from_method(POST)
		.with_uri("https://example.com/messages")
		.with_body("hello".to_utf8())

	response = Response.from_status(201)
		.with_body("created".to_utf8())

	echo!("request body: ${Str.inspect(request.body())}\n")

	echo!("response body: ${Str.inspect(response.body())}\n")

	Ok({})
}
