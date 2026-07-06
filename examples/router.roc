app [main!] {
	pf: platform "https://github.com/lukewilliamboswell/roc-platform-template-zig/releases/download/0.9/8GdFEvQYS3TeAZxKvTzCLVdQiomweGtXcdZkXNDEeABq.tar.zst",
	http: "../package/main.roc",
}

import pf.Stdout
import http.Method
import http.Request
import http.Response

CreateWidget : {
	name : Str,
	quantity : U64,
}

Widget : {
	id : U64,
	name : Str,
	quantity : U64,
}

WidgetsBody : {
	widgets : List(Widget),
}

ErrorBody : {
	error : Str,
}

JsonOkBody : {
	ok : Bool,
}

WidgetRequestError : [BadBodyUtf8, BadBodyJson(Json)]

body_str : Response -> Str
body_str = |response| Str.from_utf8(response.body()) ?? "<invalid utf8>"

json_response : U16, _ -> Try(Response, _)
json_response = |status, body| {
	json = Json.encode(body)?

	Ok(
		Response.from_status(status)
			.add_header("Content-Type", "application/json")
			.with_body(json.to_utf8()),
	)
}

json_error : U16, Str -> Try(Response, _)
json_error = |status, message| {
	body : ErrorBody
	body = { error: message }

	json_response(status, body)
}

list_widgets : () -> Try(Response, _)
list_widgets = || {
	body : WidgetsBody
	body = {
		widgets: [
			{ id: 1, name: "bolt", quantity: 7 },
			{ id: 2, name: "gear", quantity: 3 },
		],
	}

	json_response(200, body)
}

parse_widget_request : Request -> Try(CreateWidget, WidgetRequestError)
parse_widget_request = |request| {
	body = Str.from_utf8(request.body()) ? |_| BadBodyUtf8
	widget = Json.parse(body) ? BadBodyJson

	Ok(widget)
}

create_widget_response : Request -> Try(Response, WidgetRequestError)
create_widget_response = |request| {
	widget = parse_widget_request(request)?

	body : Widget
	body = { id: 3, name: widget.name, quantity: widget.quantity }

	json_response(201, body)
}

widget_error_response : WidgetRequestError -> Try(Response, _)
widget_error_response = |err|
	match err {
		BadBodyUtf8 => json_error(400, "request body must be UTF-8")
		BadBodyJson(_) => json_error(400, "invalid widget json")
	}

create_widget : Request -> Try(Response, _)
create_widget = |request|
	match create_widget_response(request) {
		Ok(response) => Ok(response)
		Err(err) => widget_error_response(err)
	}

internal_error_response : () -> Response
internal_error_response = ||
	Response.from_status(500)
		.add_header("Content-Type", "application/json")
		.with_body("{\"error\":\"json encode failed\"}".to_utf8())

route_result : Request -> Try(Response, _)
route_result = |request| {
	match (request.method(), request.uri()) {
		(GET, "/health") => {
			body : JsonOkBody
			body = { ok: True }

			json_response(200, body)
		}
		(GET, "/widgets") => list_widgets()
		(POST, "/widgets") => create_widget(request)
		_ => json_error(404, "not found")
	}
}

route : Request -> Response
route = |request| route_result(request) ?? internal_error_response()

main! : List(Str) => Try({}, [Exit(I32)])
main! = |_args| {
	request = Request.from_method(POST)
		.with_uri("/widgets")
		.with_body("{\"name\":\"washer\",\"quantity\":5}".to_utf8())

	response = route(request)

	Stdout.line!("route status: ${response.status().to_str()} ${body_str(response)}")

	Ok({})
}

## GET /health returns a JSON success body.
expect {
	response = route(Request.from_method(GET).with_uri("/health"))

	parsed : JsonOkBody
	parsed = Json.parse(body_str(response))?

	response.status() == 200
		and response.headers() == [{ name: "Content-Type", value: "application/json" }]
			and parsed == { ok: True }
}

## POST /widgets creates a widget from valid JSON.
expect {
	request = Request.from_method(POST)
		.with_uri("/widgets")
		.with_body("{\"name\":\"washer\",\"quantity\":5}".to_utf8())
	response = route(request)

	parsed : Widget
	parsed = Json.parse(body_str(response))?

	response.status() == 201 and parsed == { id: 3, name: "washer", quantity: 5 }
}

## POST /widgets rejects malformed JSON.
expect {
	request = Request.from_method(POST)
		.with_uri("/widgets")
		.with_body("not-json".to_utf8())
	response = route(request)

	parsed : ErrorBody
	parsed = Json.parse(body_str(response))?

	response.status() == 400 and parsed == { error: "invalid widget json" }
}

## POST /widgets rejects non-UTF-8 request bodies.
expect {
	request = Request.from_method(POST)
		.with_uri("/widgets")
		.with_body([255])
	response = route(request)

	parsed : ErrorBody
	parsed = Json.parse(body_str(response))?

	response.status() == 400 and parsed == { error: "request body must be UTF-8" }
}

## Unknown routes return a JSON 404 response.
expect {
	response = route(Request.from_method(GET).with_uri("/missing"))

	parsed : ErrorBody
	parsed = Json.parse(body_str(response))?

	response.status() == 404 and parsed == { error: "not found" }
}
