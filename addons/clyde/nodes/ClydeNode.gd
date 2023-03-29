class_name ClydeNode
extends RefCounted

var _index : int = -1


func get_node_class(): return "ClydeNode"


func is_node_class(className : String ) -> bool:
	return get_node_class().to_lower() == className.to_lower()
