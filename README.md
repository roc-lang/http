# Work in Progress!

The basic design is:

## Data structures only, no effects

The point of this is just to give types for requests and responses (and related types like
request method). Then platforms can expose primitives like `Http.send!` which work in terms of
the (platform-agnostic) `Request` and `Response` types defined here, and then platform-agnostic
packages which want to do HTTP effects can depend on this package and then just request an
effectful function (supplied either by the platform or a simulated one in tests) for the actual
`send!` operation.

## Opaque Request and Response types

Make these types opaque, and offer functions to get and set methods, header, etc.

The purpose of this is to make them backwards-compatible. If, for example, some new HTTP
spec comes out which introduces some new aspect of a request or a response, we want to be able
to offer that new functionality as a nonbreaking change so the whole ecosystem doesn't have
to coordinate upgrading a major version of such a widely used package.

By keeping the types opaque, we can always add new information behind the scenes and just expose
new functions to work with it. Adding new functions is a nonbreaking change. In contrast, adding
new fields to an exposed record is always a breaking change, because people might now be
constructing them from scratch with missing fields. So if we exposed the records publicly, we would
unavoidably be setting ourselves up for future breaking changes if we ever need to store new
metadata in those records based on new HTTP spec releases.

`Method` should in the future become a non-exhaustive custom tag union, also
for backwards-compatibility. This means if new HTTP spec releases introduce
new relevant methods, we can expand the tag union to include them as a nonbreaking change.
