app [main!] {
	http: "../package/main.roc",
}

import http.Method
import http.Request
import http.Response

mock_send : Request -> Response
mock_send = |request|
	if request.method() == GET {
		Response.from_status(200)
			.add_header("Content-Type", "text/plain")
			.with_body("mock response for ${request.uri()}".to_utf8())
	} else {
		Response.from_status(405)
	}

main! = |_| {
	request = Request.from_method(GET)
		.with_uri("https://example.com/offline")

	response = mock_send(request)

	echo!("mock status: ${response.status().to_str()}\n")

	Ok({})
}
