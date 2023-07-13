class_name BonnieNode
extends RefCounted


var node_index : int = -1

var document_name : String 


func get_node_class() -> String:
	return "BonnieNode"


func is_node_class(className : String ) -> bool:
	return get_node_class().to_lower() == className.to_lower()


func _to_string() -> String:
	var dictionary : Dictionary = BonnieParser.new().to_JSON_object(self, true)
	var indent : int = 0;
	return _to_node_string(dictionary, indent)


func _to_node_string_array(array : Array, indent : int) -> String:
	var result = ""
	for val in array:
		if val is String:
			result += "\t".repeat(indent + 1) + "'" +val+ "'" + "," + "\n"
		if val is Dictionary:
			result = result + _to_node_string(val, indent + 1)
		if val is Array:
			result = result + _to_node_string_array(val, indent + 1)
	return result  + "\t".repeat(indent-1) + "]" + "\n";


func _to_node_string(dictionary : Dictionary, indent : int) -> String:
	var result = "\t".repeat(indent)+ "|" + "---" + "\n"
	var array_result = ""
	var dic_result = ""
	for key in dictionary.keys():
		if(dictionary[key] is Array && !dictionary[key].is_empty()):
			array_result = array_result + "\t".repeat(indent)+ "|" + key + " : " + "[\n"
			array_result = array_result + _to_node_string_array(dictionary[key], indent + 1)
		elif dictionary[key] is Dictionary:
			dic_result = dic_result + "\t".repeat(indent)+ "|" + key + " : " + "\n"
			dic_result = dic_result + _to_node_string(dictionary[key], indent + 1)
		elif dictionary[key] is String && key != "type" && key != "document_name":
			result = result + "\t".repeat(indent)+ "|" + key +" : " + "'" + str(dictionary[key]) + "'" + "\n"
		elif key != "document_name":
			var string = str(dictionary[key])
			if(string == ""):
				string = "null"
			result = result + "\t".repeat(indent)+ "|" + key +" : " +  string  + "\n"
	return result + dic_result + array_result

