app [main!] {
	pf: platform "https://github.com/lukewilliamboswell/roc-platform-template-zig/releases/download/0.9/8GdFEvQYS3TeAZxKvTzCLVdQiomweGtXcdZkXNDEeABq.tar.zst",
	http: "../package/main.roc",
}

import pf.Stdout
import http.Method
import http.Request

main! = |_args| {
	request0 = Request.from_method(Unknown("PROPFIND"))
	request = Request.with_uri(request0, "https://dav.example.com/docs")

	Stdout.line!("custom method: ${Request.method_str(request)}")
	Ok({})
}
