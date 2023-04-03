class_name NodeFactory
extends RefCounted


enum NODE_TYPES 
{ ASSIGNMENT, EXPRESSION, DOCUMENT, DIVERT, OPTION, OPTIONS, 
LINE, BLOCK, VARIATIONS, VARIABLE,
LITERAL, NULL, ASSIGNMENTS, CONDITIONAL_CONTENT, 
ACTION_CONTENT, EVENTS, EVENT, CONTENT, 
STRINGLITERAL, NUMBERLITERAL, BOOLEANLITERAL}


var node_factory_dictionary : Dictionary = {
	NODE_TYPES.DOCUMENT : DocumentNode,
	NODE_TYPES.DIVERT : DivertNode,
	NODE_TYPES.OPTION : OptionNode,
	NODE_TYPES.OPTIONS : OptionsNode,
	NODE_TYPES.LINE : LineNode,
	NODE_TYPES.BLOCK : BlockNode,
	NODE_TYPES.VARIATIONS : VariationsNode,
	NODE_TYPES.VARIABLE : VariableNode,
	NODE_TYPES.STRINGLITERAL : StringNode,
	NODE_TYPES.NUMBERLITERAL : NumberNode,
	NODE_TYPES.BOOLEANLITERAL : BooleanNode,
	NODE_TYPES.NULL : NullTokenNode,
	NODE_TYPES.ASSIGNMENTS : AssignmentsNode,
	NODE_TYPES.EXPRESSION : ExpressionNode,
	NODE_TYPES.ASSIGNMENT : AssignmentNode,
	NODE_TYPES.CONDITIONAL_CONTENT : ConditionalContentNode,
	NODE_TYPES.ACTION_CONTENT : ActionContentNode,
	NODE_TYPES.EVENTS : EventsNode,
	NODE_TYPES.EVENT : EventNode,
	NODE_TYPES.CONTENT : ContentNode }


var node_factory_dictionary_reverse : Dictionary = {
	DocumentNode : NODE_TYPES.DOCUMENT,
	DivertNode : NODE_TYPES.DIVERT,
	OptionNode: NODE_TYPES.OPTION,
	OptionsNode : NODE_TYPES.OPTIONS,
	LineNode : NODE_TYPES.LINE,
	BlockNode : NODE_TYPES.BLOCK,
	VariationsNode : NODE_TYPES.VARIATIONS,
	VariableNode: NODE_TYPES.VARIABLE,
	StringNode : NODE_TYPES.STRINGLITERAL,
	NumberNode : NODE_TYPES.NUMBERLITERAL,
	BooleanNode : NODE_TYPES.BOOLEANLITERAL,
	NullTokenNode : NODE_TYPES.NULL,
	AssignmentsNode : NODE_TYPES.ASSIGNMENTS,
	ExpressionNode : NODE_TYPES.EXPRESSION,
	AssignmentNode : NODE_TYPES.ASSIGNMENT,
	ConditionalContentNode : NODE_TYPES.CONDITIONAL_CONTENT,
	ActionContentNode : NODE_TYPES.ACTION_CONTENT,
	EventsNode : NODE_TYPES.EVENTS,
	EventNode : NODE_TYPES.EVENT,
	ContentNode : NODE_TYPES.CONTENT }


func create_node(type : NODE_TYPES, args : Dictionary) -> ClydeNode:
	var node = node_factory_dictionary.get(type).new();
	
	
	for property in node.get_property_list():
		if(args.has(property.name)):
			var value = args.get(property.name , node[property.name])
			node[property.name] = value


	if(node is DivertNode):
		return _divert(node)
	if(node is NumberNode):
		return _number_literal(node)
	if(node is	BooleanNode):
		return _boolean_literal(node)
	return node



func create_node_tree(json_dictionary : Dictionary) -> ClydeNode:
	var node = node_factory_dictionary.get(
		json_dictionary["type"] as NodeFactory.NODE_TYPES).new()
	
	var properties = node.get_property_list()
	
	for property in node.get_property_list():
		if(json_dictionary.has(property.name)):
			var current_val = json_dictionary.get(property.name)
			
			match(typeof(current_val)):
				
				TYPE_ARRAY:
					var array : Array = []
					if(!current_val.is_empty() 
					&& typeof(current_val[0]) == TYPE_DICTIONARY):
						for dic in current_val:
							array.append(create_node_tree(dic))
						node[property.name] = array
					else:
						node[property.name] = current_val
				
				TYPE_DICTIONARY:
					if(current_val.size() != 0):
						node[property.name] = create_node_tree(current_val)
				
				TYPE_STRING, TYPE_BOOL, TYPE_FLOAT:
					node[property.name] = current_val
	return node


func _divert(divert_node: DivertNode) -> DivertNode:
	if divert_node.target == 'END':
		divert_node.target = '<end>'

	return divert_node


func _number_literal(num_node : NumberNode) -> NumberNode:
	num_node.value =  (float(num_node.value) 
		if num_node.value.is_valid_float() else int(num_node.value))
	
	return num_node


func _boolean_literal(bool_node : BooleanNode) -> BooleanNode:
	bool_node.value = bool_node.value == 'true'
	return bool_node

