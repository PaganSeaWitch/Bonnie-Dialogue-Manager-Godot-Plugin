class_name ClydeNode
extends RefCounted

var index : int = -1


func get_node_class(): return "ClydeNode"


func is_node_class(className : String ) -> bool:
	return get_node_class().to_lower() == className.to_lower()

func _to_string() -> String:
	var string = Parser.new().to_JSON_object(self, true)
	print(string)
	return "" 
