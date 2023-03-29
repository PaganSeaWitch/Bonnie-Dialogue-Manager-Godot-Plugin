class_name NodeFactory
extends RefCounted

enum NODE_TYPES 
{ ASSIGNMENT, EXPRESSION, DOCUMENT, DIVERT, OPTION, OPTIONS, 
LINE, BLOCK, VARIATIONS, VARIABLE,
LITERAL, NULL, ASSIGNMENTS, CONDITIONAL_CONTENT, 
ACTION_CONTENT, EVENTS, EVENT, CONTENT, STRINGLITERAL, NUMBERLITERAL, BOOLEANLITERAL}


var NodeFactoryDictionary : Dictionary = {
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
	NODE_TYPES.CONTENT : ContentNode
}

var NodeFactoryDictionaryReverse : Dictionary = {
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
	ContentNode : NODE_TYPES.CONTENT
}

func CreateNode(type : NODE_TYPES, args : Dictionary) -> ClydeNode:
	var node = NodeFactoryDictionary.get(type).new();
	
	var properties = node.get_property_list()
	for property in node.get_property_list():
		if(args.has(property.name)):
			var value = args.get(property.name , node[property.name])
			node[property.name] = value


	if(node is DivertNode):
		return Divert(node)
	if(node is NumberNode):
		return NumberLiteral(node)
	if(node is	BooleanNode):
		return BooleanLiteral(node)
	return node

func CreateNodeTree(jsonDictionary : Dictionary) -> ClydeNode:
	var node = NodeFactoryDictionary.get(jsonDictionary["type"] as NodeFactory.NODE_TYPES).new()
	var properties = node.get_property_list()
	
	for property in node.get_property_list():
		if(jsonDictionary.has(property.name)):
			var currentVal = jsonDictionary.get(property.name)
			
			match(typeof(currentVal)):
				
				TYPE_ARRAY:
					var array : Array = []
					if(!currentVal.is_empty() && typeof(currentVal[0]) == TYPE_DICTIONARY):
						for dic in currentVal:
							array.append(CreateNodeTree(dic))
						node[property.name] = array
					else:
						node[property.name] = currentVal
				
				TYPE_DICTIONARY:
					if(currentVal.size() != 0):
						node[property.name] = CreateNodeTree(currentVal)
				
				TYPE_STRING, TYPE_BOOL, TYPE_FLOAT:
					node[property.name] = currentVal
	return node


func Divert(divertNode: DivertNode) -> DivertNode:
	if divertNode.target == 'END':
		divertNode.target = '<end>'

	return divertNode


func NumberLiteral(numNode : NumberNode) -> NumberNode:
	numNode.value =  float(numNode.value) if numNode.value.is_valid_float() else int(numNode.value)
	return numNode


func BooleanLiteral(boolNode : BooleanNode) -> BooleanNode:
	boolNode.value = boolNode.value == 'true'
	return boolNode

