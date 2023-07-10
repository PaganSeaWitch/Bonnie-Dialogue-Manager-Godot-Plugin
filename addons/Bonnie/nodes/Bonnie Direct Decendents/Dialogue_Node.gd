class_name DialogueNode
extends BonnieNode


var id : String
var speaker : String

var tags : Array
var id_suffixes : Array

var bb_code_before_line : String


func get_node_class() -> String:
	return "DialogueNode"
