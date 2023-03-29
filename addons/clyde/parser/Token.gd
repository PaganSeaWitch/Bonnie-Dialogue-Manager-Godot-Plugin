class_name Token
extends RefCounted

var name : String

var value : String

var line : int

var column : int

func _init(_name, _line, _column, _value = ""):
	name = _name
	value = _value
	line = _line
	column = _column

