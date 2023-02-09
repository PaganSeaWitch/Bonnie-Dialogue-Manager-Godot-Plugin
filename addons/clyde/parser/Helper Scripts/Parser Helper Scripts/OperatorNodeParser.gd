class_name OperatorNodeParser
extends RefCounted

var nodeFactory : NodeFactory = NodeFactory.new()

func _assignments(tokenWalker : TokenWalker):
	tokenWalker.consume(TokenArray.set)
	var assignments = [_assignment_expression(tokenWalker)]
	while tokenWalker.peek(TokenArray.comma):
		tokenWalker.consume(TokenArray.comma)
		assignments.push_back(_assignment_expression(tokenWalker))

	tokenWalker.consume(TokenArray.braceClose)
	return nodeFactory.CreateNode(NodeFactory.NODE_TYPES.ACTION_CONTENT,{"action"= assignments})


func _assignment_expression(tokenWalker : TokenWalker):
	var assignment = _assignment_expression_internal(tokenWalker)

	if assignment.type == "variable":
		return nodeFactory.CreateNode(NodeFactory.NODE_TYPES.ASSIGNMENT, {"variable" = assignment, 
		"operation"= ParserOperators._assignment_operators[Syntax.TOKEN_ASSIGN], 
		"value" = nodeFactory.CreateNode(NodeFactory.NODE_TYPES.BOOLEANLITERAL,{"value"= 'true'})})
	else:
		return assignment


func _assignment_expression_internal(tokenWalker : TokenWalker):
	tokenWalker.consume(TokenArray.identifier)
	var variable = nodeFactory.CreateNode(NodeFactory.NODE_TYPES.VARIABLE, {"name" : tokenWalker.current_token.value})

	if tokenWalker.peek(TokenArray.braceClose):
		return variable

	var operators = ParserOperators._assignment_operators.keys()

	tokenWalker.consume(operators)

	if tokenWalker.peek(TokenArray.identifier) && tokenWalker.peek(operators + TokenArray.braceClose, 1):
		return nodeFactory.CreateNode(NodeFactory.NODE_TYPES.ASSIGNMENT, 
			{"variable" = variable,"operation"= ParserOperators._assignment_operators[tokenWalker.current_token.token],"value" = _assignment_expression_internal(tokenWalker)})
	return nodeFactory.CreateNode(NodeFactory.NODE_TYPES.ASSIGNMENT, 
		{"variable" = variable,"operation"= ParserOperators._assignment_operators[tokenWalker.current_token.token],"value" = _expression(tokenWalker)})


func _expression(tokenWalker : TokenWalker,min_precedence = 1):
	var operatortokenWalker = ParserOperators.operators.keys()

	var lhs = _operand(tokenWalker)

	if !tokenWalker.peek(operatortokenWalker):
		return lhs

	tokenWalker.consume(operatortokenWalker)

	while true:
		if !operatortokenWalker.has(tokenWalker.current_token.token):
			break

		var operator = tokenWalker.current_token.token

		var precedence = ParserOperators.operators[tokenWalker.current_token.token].precedence
		var associative = ParserOperators.operators[tokenWalker.current_token.token].associative

		if precedence < min_precedence:
			break

		var next_min_precedence = precedence + 1 if associative == 'LEFT' else precedence
		var rhs = _expression(next_min_precedence)
		lhs = _operator(operator, lhs, rhs)

	return lhs


func _operand(tokenWalker : TokenWalker):
	tokenWalker.consume(ParserOperators.operator_literals)

	match tokenWalker.current_token.token:
		Syntax.TOKEN_NOT:
			return nodeFactory.CreateNode(NodeFactory.NODE_TYPES.EXPRESSION,{"name"='not',"elements"= [_operand(tokenWalker)]})
		Syntax.TOKEN_IDENTIFIER:
			return nodeFactory.CreateNode(NodeFactory.NODE_TYPES.VARIABLE, {"name" = tokenWalker.current_token.value})
		Syntax.TOKEN_NUMBER_LITERAL:
			return nodeFactory.CreateNode(NodeFactory.NODE_TYPES.NUMBERLITERAL, {"value" = tokenWalker.current_token.value})
		Syntax.TOKEN_STRING_LITERAL:
			return nodeFactory.CreateNode(NodeFactory.NODE_TYPES.STRINGLITERAL, {"value" =tokenWalker.current_token.value})
		Syntax.TOKEN_BOOLEAN_LITERAL:
			return nodeFactory.CreateNode(NodeFactory.NODE_TYPES.BOOLEANLITERAL, {"value" =tokenWalker.current_token.value})
		Syntax.TOKEN_NULL_TOKEN:
			return nodeFactory.CreateNode(NodeFactory.NODE_TYPES.NULL, {})


func _operator(operator, lhs, rhs):
	return nodeFactory.CreateNode(NodeFactory.NODE_TYPES.EXPRESSION,{"name"= ParserOperators.operator_labels[operator],"elements"= [lhs, rhs]})

