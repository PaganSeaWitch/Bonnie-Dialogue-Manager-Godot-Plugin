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

func CreateNode(type : NODE_TYPES, args : Dictionary) -> ClydeNode:
	var node = NodeFactoryDictionary.get(type).new();
	
	for property in node.get_property_list():
		node[property] = args[property]
	
	match(node.type):
		DivertNode:
			return Divert(node)
		NumberNode:
			return NumberLiteral(node)
		BooleanNode:
			return BooleanLiteral(node)
		_:
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

