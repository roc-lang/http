app [main!] {
	pf: platform "https://github.com/lukewilliamboswell/roc-platform-template-zig/releases/download/0.9/8GdFEvQYS3TeAZxKvTzCLVdQiomweGtXcdZkXNDEeABq.tar.zst",
	http: "../package/main.roc",
}

import pf.Stdout
import http.Method
import http.Request

main! : List(Str) => Try({}, [Exit(I32)])
main! = |_args| {
	request = Request.from_method(GET)
		.with_uri("https://example.com/widgets")

	Stdout.line!("${request.method_str()} ${request.uri()}")
	Ok({})
}
