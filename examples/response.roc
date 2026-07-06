app [main!] {
	pf: platform "https://github.com/lukewilliamboswell/roc-platform-template-zig/releases/download/0.9/8GdFEvQYS3TeAZxKvTzCLVdQiomweGtXcdZkXNDEeABq.tar.zst",
	http: "../package/main.roc",
}

import pf.Stdout
import http.Response

main! : List(Str) => Try({}, [Exit(I32)])
main! = |_args| {
	response = Response.from_status(404)
		.add_header("Content-Type", "text/plain")
		.with_body("not found".to_utf8())

	Stdout.line!("status: ${response.status().to_str()}")
	Stdout.line!("headers: ${response.headers().len().to_str()}")
	Stdout.line!("body bytes: ${response.body().len().to_str()}")

	Ok({})
}
