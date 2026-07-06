app [main!] {
	pf: platform "https://github.com/lukewilliamboswell/roc-platform-template-zig/releases/download/0.9/8GdFEvQYS3TeAZxKvTzCLVdQiomweGtXcdZkXNDEeABq.tar.zst",
	http: "../package/main.roc",
}

import pf.Stdout
import http.Method
import http.Request

ParsedHeaders : {
	accept : Str,
	content_length : U64,
	x_optional : Try(Str, [Missing]),
	x_trace_id : Str,
}

parse_headers : Str -> Try(ParsedHeaders, Encoding.HttpHeader)
parse_headers = |raw| Encoding.HttpHeader.parse(raw)

main! : List(Str) => Try({}, [Exit(I32)])
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

## Header parsing decodes required fields and missing optional headers.
expect {
	parsed = parse_headers("accept: application/json\r\ncontent-length: 42\r\nx-trace-id: demo-123\r\n")?
	optional = parsed.x_optional ?? "none"

	parsed.accept == "application/json"
		and parsed.content_length == 42
			and parsed.x_trace_id == "demo-123"
				and optional == "none"
}

## Header parsing reports missing required fields.
expect parse_headers("content-length: 42\r\nx-trace-id: demo-123\r\n") == Err(Encoding.HttpHeader.MissingRequired)

## Header parsing reports invalid field values.
expect parse_headers("accept: application/json\r\ncontent-length: nope\r\nx-trace-id: demo-123\r\n") == Err(Encoding.HttpHeader.BadHeader)
