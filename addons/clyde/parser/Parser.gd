class_name Parser
extends RefCounted

var lexer : Lexer = Lexer.new()


func parse(doc):
	var tokenWalker = TokenWalker.new()
	tokenWalker.setLexer(lexer.init(doc))

#	var l = Syntax.new()
#	print(l.init(doc).get_all())

	var result : DocumentNode = MiscNodeParser.new()._document(tokenWalker)
	if tokenWalker.peek():
		tokenWalker.consume(TokenArray.eof)

	return result


var NODE_TYPE_DICTIONARY : Dictionary = {
	DocumentNode : "DOCUMENT",
	DivertNode   : "DIVERT",
	OptionNode   : "OPTION",
	OptionsNode  : "OPTIONS",
	LineNode     : "LINE",
	BlockNode    : "BLOCK",
	VariationsNode : "VARIATIONS",
	VariableNode   : "VARIABLE",
	StringNode     : "STRING",
	NumberNode     : "NUMBER",
	BooleanNode    : "BOOLEAN",
	NullTokenNode  : "NULL",
	AssignmentsNode : "ASSIGNMENTS",
	ExpressionNode  : "EXPRESSION",
	AssignmentNode  : "ASSIGNMENT",
	ConditionalContentNode  : "CONDITIONAL_CONTENT",
	ActionContentNode : "ACTION_CONTENT",
	EventsNode : "EVENTS",
	EventNode : "EVENT",
	ContentNode : "CONTENT"
}


func to_JSON_object(doc : ClydeNode) -> Dictionary:
	var json_dictionary : Dictionary = {}
	var keys : Array = NodeFactory.new().NodeFactoryDictionaryReverse.keys()
	if(doc == null):
		return {}
	for key in keys:
		if is_instance_of(doc, key):
			var number : int = NodeFactory.new().NodeFactoryDictionaryReverse[key]
			json_dictionary["type"] = number
			break
	if(!json_dictionary.has("type")):
		return {}

	for property in doc.get_property_list():
		match(property.type):
			TYPE_ARRAY:
				var array : Array = []
				if(property.name != "tags" && property.name != "id_suffixes"):
					for node in doc[property.name]:
						array.append(to_JSON_object(node))
					json_dictionary[property.name] = array
				else:
					json_dictionary[property.name] = doc[property.name]
			TYPE_OBJECT:
				if(property.name != "script"):
					json_dictionary[property.name] = to_JSON_object(doc[property.name])
			TYPE_STRING, TYPE_BOOL, TYPE_FLOAT:
				json_dictionary[property.name] = doc[property.name]
			TYPE_NIL:
				if((property.name == "value"|| property.name == "variable" )&& json_dictionary["type"] == NodeFactory.NODE_TYPES.ASSIGNMENT):
					json_dictionary[property.name] = to_JSON_object(doc[property.name])
				elif(property.name != "RefCounted" && !property.name.ends_with(".gd")):
					json_dictionary[property.name] = doc[property.name]
			
	return json_dictionary


func to_Document_node(jsonDictionary : Dictionary) -> ClydeNode:
	if(validate_json_object(jsonDictionary)):
		return NodeFactory.new().CreateNodeTree(jsonDictionary);
	return null


func validate_json_object(jsonDictionary : Dictionary) -> bool:
	var isNotBroken : bool = true
	var keys  : Array = NodeFactory.new().NodeFactoryDictionary.keys()
	
	if(!jsonDictionary.keys().has("type") || !keys.has(jsonDictionary["type"] as NodeFactory.NODE_TYPES)):
		return false
	
	for value in jsonDictionary.values():
		match(typeof(value)):
			TYPE_ARRAY:
				if(!value.is_empty() && typeof(value[0]) == TYPE_DICTIONARY):
					for dic in value:
						isNotBroken = isNotBroken && validate_json_object(dic)

			TYPE_DICTIONARY:
				if(value.size() != 0):
					isNotBroken = isNotBroken && validate_json_object(value)
	return isNotBroken
