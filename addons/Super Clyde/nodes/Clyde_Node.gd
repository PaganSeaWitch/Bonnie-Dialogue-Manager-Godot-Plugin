class_name ClydeNode
extends RefCounted


var node_index : int = -1


func get_node_class() -> String:
	return "ClydeNode"


func is_node_class(className : String ) -> bool:
	return get_node_class().to_lower() == className.to_lower()


func _to_string() -> String:
	var dictionary : Dictionary = Parser.new().to_JSON_object(self, true)
	print("###############################")
	var indent : int = 0;
	_to_node_string(dictionary, indent)
	print("###############################")
	return "" 


func _to_node_string(dictionary : Dictionary, indent : int):
	for key in dictionary.keys():
		if(dictionary[key] is Array && !dictionary[key].is_empty()):

			if(dictionary[key][0] is Dictionary):
				print(" ".repeat(indent) + key + " : ")
				for dict in dictionary[key]:
					_to_node_string(dict, indent + 1)
			else:
				var string = ""
				for val in dictionary[key]:
					string =  val +", " +  string
				string = string.substr(0, string.length() - 2)
				print(" ".repeat(indent) + key + " : " + string)

		elif(dictionary[key] is String && !dictionary[key].is_empty()):
			print(" ".repeat(indent) + key +" : " + dictionary[key])
