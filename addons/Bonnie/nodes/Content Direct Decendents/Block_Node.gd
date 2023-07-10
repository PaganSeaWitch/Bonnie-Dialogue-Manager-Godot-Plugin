class_name BlockNode
extends ContentNode


var block_name : String
var block_requirements : Array
var block_not_requirements : Array
var conditions : Array

func get_node_class() -> String:
	return "BlockNode"
