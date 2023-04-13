class_name AssignmentNode
extends ClydeNode


var operation
var variable : VariableNode
var value : ClydeNode


func get_node_class() -> String:
	return "AssignmentNode"
