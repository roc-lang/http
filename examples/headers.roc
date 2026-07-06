app [main!] {
	pf: platform "https://github.com/lukewilliamboswell/roc-platform-template-zig/releases/download/0.9/8GdFEvQYS3TeAZxKvTzCLVdQiomweGtXcdZkXNDEeABq.tar.zst",
	http: "../package/main.roc",
}

import pf.Stdout
import http.Method
import http.Request

main! = |_args| {
	request = Request.from_method(GET)
		.with_uri("https://api.example.com/items")
		.with_headers(
			[
				{ name: "Accept", value: "application/json" },
				{ name: "X-Trace-Id", value: "demo-123" },
				{ name: "X-Trace-Id", value: "demo-456" },
			],
		)

	Stdout.line!(Str.inspect(request.headers()))
	Ok({})
}
