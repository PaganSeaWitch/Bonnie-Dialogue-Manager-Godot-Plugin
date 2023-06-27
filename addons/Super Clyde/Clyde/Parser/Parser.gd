class_name ClydeParser
extends RefCounted

var _lexer : ClydeLexer = ClydeLexer.new()
var misc_parser : MiscParser = MiscParser.new()
var logic_parser : LogicParser = LogicParser.new()
var line_parser : LineParser = LineParser.new()
var variations_parser : VariationsParser = VariationsParser.new()
var options_parser : OptionsParser = OptionsParser.new()
var dependent_parser : DependentParser = DependentParser.new()
var bb_code_parser : BBCodeParser = BBCodeParser.new()


# Parses given string data into a DocumentNode
func parse(doc : String) -> DocumentNode:
	var token_walker = TokenWalker.new()
	token_walker.set_lexer(_lexer.init(doc))
	misc_parser.init(self, token_walker)
	logic_parser.init(self, token_walker)
	line_parser.init(self, token_walker)
	variations_parser.init(self, token_walker)
	options_parser.init(self, token_walker)
	dependent_parser.init(self, token_walker)
	bb_code_parser.init(self, token_walker)
	var result : DocumentNode = misc_parser.document()
	if token_walker.peek() != null:
		token_walker.consume(TokenArray.eof)

	return result


# Transforms a ClydeNode into a JSON dictionary
func to_JSON_object(node : ClydeNode, to_print : bool = false) -> Dictionary:
	var json_dictionary : Dictionary = {}
	
	# Get all node types
	var keys : Array = NodeFactory.new().node_factory_dictionary_reverse.keys()
	if(node == null):
		return {}
		
	# Set the type in the JSON dictionary based on the node type as a ENUM number
	for key in keys:
		if is_instance_of(node, key):
			if(to_print):
				json_dictionary["type"] = key.new().get_node_class().replace("Node", "")
			else:
				var number : int = NodeFactory.new().node_factory_dictionary_reverse[key]
				json_dictionary["type"] = number
			break
	if(!json_dictionary.has("type")):
		return {}

	# For every property in the current node check its type
	# and add it to the JSON dictionary if it a usable type
	for property in node.get_property_list():
		var name : String = property.name
		match(property.type):
			TYPE_ARRAY:
				var array : Array = []
				if(name != "tags" && name != "id_suffixes" 
				&& name != "block_requirements" && name != "block_not_requirements"):
					for val in node[name]:
						if(val is ClydeNode):
							array.append(to_JSON_object(val,to_print))
						if(val is Array):
							var inner_array = []
							for second_val in val:
								inner_array.append((to_JSON_object(second_val,to_print)))
							array.append(inner_array)
					json_dictionary[name] = array
				else:
					json_dictionary[name] = node[name]
			TYPE_OBJECT:
				if(name != "script"):
					json_dictionary[name] = to_JSON_object(node[name],to_print)
			TYPE_STRING, TYPE_BOOL, TYPE_FLOAT:
				json_dictionary[name] = node[name]
			TYPE_NIL:
				if(name != "RefCounted" 
				&& !name.ends_with(".gd")):
					json_dictionary[name] = node[name]
			
	return json_dictionary


# Turns a JSON object into a ClydeNode
func to_node(json_dictionary : Dictionary) -> ClydeNode:
	if(_validate_json_object(json_dictionary)):
		return NodeFactory.new().create_node_tree(json_dictionary);
	return null


# Validates that a json object has a correct type
func _validate_json_object(json_dictionary : Dictionary) -> bool:
	var is_not_broken : bool = true
	var keys  : Array = NodeFactory.new().node_factory_dictionary.keys()
	
	if(!json_dictionary.keys().has("type") || 
	!keys.has(json_dictionary["type"] as NodeFactory.NODE_TYPES)):
		return false
	
	for value in json_dictionary.values():
		match(typeof(value)):
			TYPE_ARRAY:
				if(!value.is_empty()):
					
					for val in value:
						if(val is Dictionary):
							is_not_broken = is_not_broken && _validate_json_object(val)
						
						if(val is Array):
							var inner_array = []
							for second_val in val:
								is_not_broken = is_not_broken && _validate_json_object(second_val)
			TYPE_DICTIONARY:
				if(value.size() != 0):
					is_not_broken = is_not_broken && _validate_json_object(value)
	return is_not_broken
