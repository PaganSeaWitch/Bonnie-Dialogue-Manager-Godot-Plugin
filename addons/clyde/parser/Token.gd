class_name Token
extends RefCounted

var token : String

var value : String

var line : int

var column : int

func _init(_token, _line, _column, _value = null):
	token = _token
	value = _value
	line = _line
	column = _column

