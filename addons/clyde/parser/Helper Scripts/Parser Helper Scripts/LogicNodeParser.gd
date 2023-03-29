class_name LogicNodeParser
extends RefCounted

var nodeFactory : NodeFactory = NodeFactory.new()


func _logic_element(tokenWalker : TokenWalker):
	if tokenWalker.peek(TokenArray.set):
		var assignments = _assignments(tokenWalker)
		return assignments


	if tokenWalker.peek(TokenArray.trigger):
		var events = _events(tokenWalker)
		return events

	if tokenWalker.peek(TokenArray.when):
		tokenWalker.consume(TokenArray.when)

	var condition = _condition(tokenWalker)
	return condition


func _nested_logic_block(tokenWalker : TokenWalker):
	var root
	var wrapper
	while tokenWalker.current_token.name == Syntax.TOKEN_BRACE_OPEN:
		if not root:
			root = _logic_block(tokenWalker)
			wrapper = root
		else:
			var next = _logic_block(tokenWalker)
			wrapper.content = [next]
			wrapper = next

		if tokenWalker.peek(TokenArray.braceOpen):
			tokenWalker.consume(TokenArray.braceOpen)

	return {
		"root": root,
		"wrapper": wrapper
	}


func _logic_block(tokenWalker : TokenWalker):
	if tokenWalker.peek(TokenArray.set):
		var assignments = _assignments(tokenWalker)
		return nodeFactory.CreateNode(NodeFactory.NODE_TYPES.ACTION_CONTENT,{"action"= [assignments]})

	if tokenWalker.peek(TokenArray.trigger):
		var events = _events(tokenWalker)
		return nodeFactory.CreateNode(NodeFactory.NODE_TYPES.ACTION_CONTENT,{"action"= events})

	if tokenWalker.peek(TokenArray.when):
		tokenWalker.consume(TokenArray.when)

	var condition = _condition(tokenWalker)
	return nodeFactory.CreateNode(NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT, {"conditions" = condition})


func _events(tokenWalker : TokenWalker):
	tokenWalker.consume(TokenArray.trigger)
	tokenWalker.consume(TokenArray.identifier)
	var eventsNode : EventsNode = nodeFactory.CreateNode(NodeFactory.NODE_TYPES.EVENTS, 
		{"events" = [nodeFactory.CreateNode(NodeFactory.NODE_TYPES.EVENT, {name = tokenWalker.current_token.value})]})

	while tokenWalker.peek(TokenArray.comma):
		tokenWalker.consume(TokenArray.comma)
		tokenWalker.consume(TokenArray.identifier)
		eventsNode.events.push_back(nodeFactory.CreateNode(NodeFactory.NODE_TYPES.EVENT, {name = tokenWalker.current_token.value}))

	tokenWalker.consume(TokenArray.braceClose)

	return eventsNode


func _conditional_line(tokenWalker : TokenWalker):
	var expression : NamedNode = _condition(tokenWalker)
	var content

	if tokenWalker.peek(TokenArray.divert):
		content = MiscNodeParser.new()._divert(tokenWalker)
	elif tokenWalker.peek(TokenArray.lineBreak):
		tokenWalker.consume(TokenArray.lineBreak)
		tokenWalker.consume(TokenArray.indent)
		content = MiscNodeParser.new()._lines(tokenWalker)
		tokenWalker.consume(TokenArray.end)
	elif tokenWalker.peek(TokenArray.braceOpen):
		tokenWalker.consume(TokenArray.braceOpen)
		content = _line_with_action(tokenWalker)
	else:
		tokenWalker.consume(TokenArray.dialogue)
		content = DialogueNodeParser.new()._dialogue_line(tokenWalker)
		if tokenWalker.peek(TokenArray.braceOpen):
			tokenWalker.consume(TokenArray.braceOpen)
			content = _line_with_action(tokenWalker, content)

	if(typeof(content) == TYPE_ARRAY):
		return nodeFactory.CreateNode(NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT, {"conditions" = expression, "content" = content})
	return nodeFactory.CreateNode(NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT, {"conditions" = expression, "content" = [content]})


func _condition(tokenWalker : TokenWalker):
	var token = tokenWalker.peek([
		Syntax.TOKEN_IDENTIFIER,
		Syntax.TOKEN_NOT,
	])
	var expression
	if token:
		expression = _expression(tokenWalker)

	tokenWalker.consume(TokenArray.braceClose)
	return expression


func _assignments(tokenWalker : TokenWalker):
	tokenWalker.consume(TokenArray.set)
	var assignments = [_assignment_expression(tokenWalker)]
	while tokenWalker.peek(TokenArray.comma):
		tokenWalker.consume(TokenArray.comma)
		assignments.push_back(_assignment_expression(tokenWalker))

	tokenWalker.consume(TokenArray.braceClose)
	if(typeof(assignments) == TYPE_ARRAY):
		return nodeFactory.CreateNode(NodeFactory.NODE_TYPES.ASSIGNMENTS,{"assignments"= assignments})
	return nodeFactory.CreateNode(NodeFactory.NODE_TYPES.ASSIGNMENTS,{"assignments"= [assignments]})

func _assignment_expression(tokenWalker : TokenWalker):
	var assignment = _assignment_expression_internal(tokenWalker)

	if assignment is VariableNode:
		return nodeFactory.CreateNode(NodeFactory.NODE_TYPES.ASSIGNMENT, {"variable" = assignment, 
		"operation"= Syntax.TOKEN_ASSIGN, 
		"value" = nodeFactory.CreateNode(NodeFactory.NODE_TYPES.BOOLEANLITERAL,{"value"= 'true'})})
	else:
		return assignment


func _assignment_expression_internal(tokenWalker : TokenWalker):
	tokenWalker.consume(TokenArray.identifier)
	var variable = nodeFactory.CreateNode(NodeFactory.NODE_TYPES.VARIABLE, {"name" : tokenWalker.current_token.value})

	if tokenWalker.peek(TokenArray.braceClose):
		return variable


	tokenWalker.consume(TokenArray.operator_assignments)

	if tokenWalker.peek(TokenArray.identifier) && tokenWalker.peek(TokenArray.operatorsAndBracketClose, 1):
		return nodeFactory.CreateNode(NodeFactory.NODE_TYPES.ASSIGNMENT, 
			{"variable" = variable,"operation"= tokenWalker.current_token.name,"value" = _assignment_expression_internal(tokenWalker)})
	return nodeFactory.CreateNode(NodeFactory.NODE_TYPES.ASSIGNMENT, 
		{"variable" = variable,"operation"= tokenWalker.current_token.name,"value" = _expression(tokenWalker)})


func _expression(tokenWalker : TokenWalker,min_precedence = 1):
	var lhs = _operand(tokenWalker)

	if !tokenWalker.peek(TokenArray.operator_mathamatic_symbols):
		return lhs

	tokenWalker.consume(TokenArray.operator_mathamatic_symbols)

	while true:
		if !TokenArray.operator_mathamatic_symbols.has(tokenWalker.current_token.name):
			break

		var operator = tokenWalker.current_token.name
		var precedence = ParserOperators.operators[tokenWalker.current_token.name].precedence
		var associative = ParserOperators.operators[tokenWalker.current_token.name].associative

		if precedence < min_precedence:
			break

		var next_min_precedence = precedence + 1 if associative == 'LEFT' else precedence
		var rhs = _expression(tokenWalker, next_min_precedence)
		lhs = _operator(operator, lhs, rhs)

	return lhs


func _operand(tokenWalker : TokenWalker):
	tokenWalker.consume(TokenArray.operator_literals)

	match tokenWalker.current_token.name:
		Syntax.TOKEN_NOT:
			return nodeFactory.CreateNode(NodeFactory.NODE_TYPES.EXPRESSION,{"name"=tokenWalker.current_token.value,"elements"= [_operand(tokenWalker)]})
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
	return nodeFactory.CreateNode(NodeFactory.NODE_TYPES.EXPRESSION,{"name"= operator,"elements"= [lhs, rhs] })


func _line_with_action(tokenWalker: TokenWalker, line = null):
	var token = tokenWalker.peek(TokenArray.setTrigger)
	var expression = _logic_element(tokenWalker)

	if line:
		var content = line

		if tokenWalker.peek(TokenArray.braceOpen):
			tokenWalker.consume(TokenArray.braceOpen)
			content = _line_with_action(tokenWalker, line)

		if tokenWalker.peek(TokenArray.lineBreak):
			tokenWalker.consume(TokenArray.lineBreak)

		if !token || token.name == Syntax.TOKEN_KEYWORD_WHEN:
			return nodeFactory.CreateNode(NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT, {"conditions" = expression, "content" = [content]})

		return nodeFactory.CreateNode(NodeFactory.NODE_TYPES.ACTION_CONTENT,{"action"= [expression], "content"= [content]})

	if tokenWalker.peek(TokenArray.lineBreak):
		tokenWalker.consume(TokenArray.lineBreak)
		return expression

	if tokenWalker.peek(TokenArray.eof):
		return  expression

	if tokenWalker.peek(TokenArray.braceOpen):
		tokenWalker.consume(TokenArray.braceOpen)
		if !token:
			return nodeFactory.CreateNode(NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT, {"conditions" = expression, "content" = [_line_with_action(tokenWalker)]})
		return nodeFactory.CreateNode(NodeFactory.NODE_TYPES.ACTION_CONTENT,{"action"= [expression], "content"= [_line_with_action(tokenWalker)]})

	tokenWalker.consume(TokenArray.dialogue)

	if !token:
		return nodeFactory.CreateNode(NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT, {"conditions" = expression, "content" = [DialogueNodeParser.new()._dialogue_line(tokenWalker)]})
	return nodeFactory.CreateNode(NodeFactory.NODE_TYPES.ACTION_CONTENT,{"action"= expression, "content"= [DialogueNodeParser.new()._dialogue_line(tokenWalker)]})
