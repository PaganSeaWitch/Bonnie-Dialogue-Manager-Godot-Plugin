class_name AssignmentNode
extends ClydeNode

func get_node_class() -> String:
	return "AssignmentNode"

var variable : VariableNode

var operation

var value : ClydeNode
