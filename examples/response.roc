app [main!] {
	http: "../package/main.roc",
}

import http.Response

main! = |_| {
	response = Response.from_status(404)
		.add_header("Content-Type", "text/plain")
		.with_body("not found".to_utf8())

	echo!("status: ${response.status().to_str()}\n")
	echo!("headers: ${response.headers().len().to_str()}\n")
	echo!("body bytes: ${response.body().len().to_str()}\n")

	Ok({})
}
