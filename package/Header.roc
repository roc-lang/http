Header := {
	name : Str,
	value : Str,
}.{

	## Convert a header to the wire-format `Name: value` string.
	to_str : Header -> Str
	to_str = |{ name, value }| "${name}: ${value}"

	## Compare two headers by name and value.
	is_eq : Header, Header -> Bool
	is_eq = |left, right| left.name == right.name and left.value == right.value
}
