class_name Token
extends RefCounted

# The name of the token, identifies for the parser how to deal with it
var name : String

# The value of the token
var value : String

# The line of the file where the token's value can be found
var line : int

# The column of the file where the token's vlaue can be found
var column : int


func _init(_name, _line, _column, _value = ""):
	name = _name
	value = _value
	line = _line
	column = _column

static func to_JSON_object(token : Token) -> Dictionary:
	return { "name": token.name, "value": token.value, "line": token.line, "column": token.column, }
