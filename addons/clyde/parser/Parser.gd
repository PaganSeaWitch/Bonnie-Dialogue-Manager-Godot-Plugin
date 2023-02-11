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
	var keys = NODE_TYPE_DICTIONARY.keys()

	for key in keys:
		if(doc is key):
			json_dictionary["type"] = NODE_TYPE_DICTIONARY[key]
			break

	for property in doc.get_property_list():
		if(property.name == "value"):
			pass
		match(property.type):
			28:
				var array : Array = []
				if(property.name != "tags" && property.name != "id_suffixes"):
					for node in doc[property.name]:
						array.append(to_JSON_object(node))
					json_dictionary[property.name] = array
				#elif(typeof(doc[property.name]) == 28):
				#		for node in doc[property.name]:
				#			array.append(to_JSON_object(node))
				#			json_dictionary[property.name] = array
				else:
					json_dictionary[property.name] = doc[property.name]
			24:
				if(property.name != "script"):
					json_dictionary[property.name] = to_JSON_object(doc[property.name])
			4, 1, 3:
				json_dictionary[property.name] = doc[property.name]
			0:
				if((property.name == "value"|| property.name == "variable" )&& json_dictionary["type"] == "ASSIGNMENT"):
					json_dictionary[property.name] = to_JSON_object(doc[property.name])
				elif(property.name != "RefCounted" && !property.name.ends_with(".gd")):
					json_dictionary[property.name] = doc[property.name]
			
	return json_dictionary

