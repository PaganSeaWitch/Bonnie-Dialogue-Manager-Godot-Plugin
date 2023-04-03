class_name LogicNodeParser
extends RefCounted

var nodeFactory : NodeFactory = NodeFactory.new()


func _logic_element(token_walker : TokenWalker) -> ClydeNode:
	if token_walker.peek(TokenArray.set):
		var assignments = _assignments(token_walker)
		return assignments


	if token_walker.peek(TokenArray.trigger):
		var events = _events(token_walker)
		return events

	if token_walker.peek(TokenArray.when):
		token_walker.consume(TokenArray.when)

	var condition = _condition(token_walker)
	return condition


func nested_logic_block(token_walker : TokenWalker) -> Dictionary:
	var root : ContentNode
	var wrapper : ContentNode
	while token_walker.current_token.name == Syntax.TOKEN_BRACE_OPEN:
		if root == null:
			root = _logic_block(token_walker)
			wrapper = root
		else:
			var next = _logic_block(token_walker)
			wrapper.content = [next]
			wrapper = next

		if token_walker.peek(TokenArray.brace_open):
			token_walker.consume(TokenArray.brace_open)

	return {
		"root": root,
		"wrapper": wrapper
	}


func _logic_block(token_walker : TokenWalker) -> ContentNode:
	if token_walker.peek(TokenArray.set) != null:
		var assignments : AssignmentsNode = _assignments(token_walker)
		return nodeFactory.create_node(NodeFactory.NODE_TYPES.ACTION_CONTENT,
			{"action"= [assignments]})

	if token_walker.peek(TokenArray.trigger) != null:
		var events : EventsNode = _events(token_walker)
		return nodeFactory.create_node(NodeFactory.NODE_TYPES.ACTION_CONTENT,
			{"action"= events})

	if token_walker.peek(TokenArray.when) != null:
		token_walker.consume(TokenArray.when)

	var condition : ClydeNode = _condition(token_walker)
	return nodeFactory.create_node(NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
		{"conditions" = condition})


func _events(token_walker : TokenWalker) -> EventsNode:
	token_walker.consume(TokenArray.trigger)
	token_walker.consume(TokenArray.identifier)
	var eventsNode : EventsNode = nodeFactory.create_node(NodeFactory.NODE_TYPES.EVENTS, 
		{"events" = [nodeFactory.create_node(NodeFactory.NODE_TYPES.EVENT, 
			{name = token_walker.current_token.value})]})

	while token_walker.peek(TokenArray.comma):
		token_walker.consume(TokenArray.comma)
		token_walker.consume(TokenArray.identifier)
		eventsNode.events.push_back(nodeFactory.create_node(NodeFactory.NODE_TYPES.EVENT, 
			{name = token_walker.current_token.value}))

	token_walker.consume(TokenArray.brace_close)

	return eventsNode


func conditional_line(token_walker : TokenWalker) -> ConditionalContentNode :
	var expression : NamedNode = _condition(token_walker)
	var content

	if token_walker.peek(TokenArray.divert):
		content = MiscNodeParser.new().divert(token_walker)
	elif token_walker.peek(TokenArray.lineBreak):
		token_walker.consume(TokenArray.lineBreak)
		token_walker.consume(TokenArray.indent)
		content = MiscNodeParser.new().lines(token_walker)
		token_walker.consume(TokenArray.end)
	elif token_walker.peek(TokenArray.brace_open):
		token_walker.consume(TokenArray.brace_open)
		content = line_with_action(token_walker)
	else:
		token_walker.consume(TokenArray.dialogue)
		content = DialogueNodeParser.new().dialogue_line(token_walker)
		if token_walker.peek(TokenArray.brace_open):
			token_walker.consume(TokenArray.brace_open)
			content = line_with_action(token_walker, content)

	if(typeof(content) == TYPE_ARRAY):
		return nodeFactory.create_node(NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT, 
			{"conditions" = expression, "content" = content})
	return nodeFactory.create_node(NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT, 
		{"conditions" = expression, "content" = [content]})


func _condition(token_walker : TokenWalker) -> ClydeNode:
	var token : Token = token_walker.peek([
		Syntax.TOKEN_IDENTIFIER,
		Syntax.TOKEN_NOT,
	])
	var expression : ClydeNode
	if token != null:
		expression = _expression(token_walker)

	token_walker.consume(TokenArray.brace_close)
	return expression


func _assignments(token_walker : TokenWalker) -> AssignmentsNode:
	token_walker.consume(TokenArray.set)
	var assignments : Array[AssignmentNode] = [_assignment_expression(token_walker)]
	while token_walker.peek(TokenArray.comma) != null:
		token_walker.consume(TokenArray.comma)
		assignments.push_back(_assignment_expression(token_walker))

	token_walker.consume(TokenArray.brace_close)
	if(typeof(assignments) == TYPE_ARRAY):
		return nodeFactory.create_node(NodeFactory.NODE_TYPES.ASSIGNMENTS,
			{"assignments"= assignments})
	return nodeFactory.create_node(NodeFactory.NODE_TYPES.ASSIGNMENTS,
		{"assignments"= [assignments]})


func _assignment_expression(token_walker : TokenWalker) -> AssignmentNode:
	var assignment : ClydeNode = _assignment_expression_internal(token_walker)

	if assignment is VariableNode:
		return nodeFactory.Create_node(NodeFactory.NODE_TYPES.ASSIGNMENT, 
			{"variable" = assignment, 
			"operation"= Syntax.TOKEN_ASSIGN, 
			"value" = nodeFactory.Create_node(NodeFactory.NODE_TYPES.BOOLEANLITERAL,
				{"value"= 'true'})})
	if assignment is AssignmentNode:
		return assignment
	
	assert(false, 'Expected AssignmentNode instead got : ' +assignment.get_node_class())
	return null
	


func _assignment_expression_internal(token_walker : TokenWalker) -> ClydeNode:
	token_walker.consume(TokenArray.identifier)
	var variable : VariableNode = nodeFactory.create_node(NodeFactory.NODE_TYPES.VARIABLE, 
		{"name" : token_walker.current_token.value})

	if token_walker.peek(TokenArray.brace_close) != null:
		return variable


	token_walker.consume(TokenArray.operator_assignments)

	if (token_walker.peek(TokenArray.identifier) != null
	&& token_walker.peek(TokenArray.operators_and_bracket_close, 1) != null):
		return nodeFactory.create_node(NodeFactory.NODE_TYPES.ASSIGNMENT, 
			{"variable" = variable,"operation"= token_walker.current_token.name,
			"value" = _assignment_expression_internal(token_walker)})
	
	return nodeFactory.create_node(NodeFactory.NODE_TYPES.ASSIGNMENT, 
		{"variable" = variable,"operation"= token_walker.current_token.name,
		"value" = _expression(token_walker)})


func _expression(token_walker : TokenWalker, min_precedence : int = 1) -> ClydeNode:
	var lhs : ClydeNode = _operand(token_walker)

	if token_walker.peek(TokenArray.operator_mathamatic_symbols) == null:
		return lhs

	token_walker.consume(TokenArray.operator_mathamatic_symbols)

	while true:
		if !TokenArray.operator_mathamatic_symbols.has(token_walker.current_token.name):
			break

		var operator_name : String = token_walker.current_token.name
		var precedence : int = ParserOperators.operators[token_walker.current_token.name].precedence
		var associative : String = ParserOperators.operators[token_walker.current_token.name].associative

		if precedence < min_precedence:
			break

		var next_min_precedence : int = precedence + 1 if associative == 'LEFT' else precedence
		var rhs = _expression(token_walker, next_min_precedence)
		lhs = _operator(operator_name, lhs, rhs)

	return lhs


func _operand(token_walker : TokenWalker) -> ClydeNode:
	token_walker.consume(TokenArray.operator_literals)

	match token_walker.current_token.name:
		Syntax.TOKEN_NOT:
			return nodeFactory.create_node(NodeFactory.NODE_TYPES.EXPRESSION, 
				{"name"=token_walker.current_token.value,"elements"= [_operand(token_walker)]})
		Syntax.TOKEN_IDENTIFIER:
			return nodeFactory.create_node(NodeFactory.NODE_TYPES.VARIABLE, 
				{"name" = token_walker.current_token.value})
		Syntax.TOKEN_NUMBER_LITERAL:
			return nodeFactory.create_node(NodeFactory.NODE_TYPES.NUMBERLITERAL, 
				{"value" = token_walker.current_token.value})
		Syntax.TOKEN_STRING_LITERAL:
			return nodeFactory.create_node(NodeFactory.NODE_TYPES.STRINGLITERAL, 
				{"value" =token_walker.current_token.value})
		Syntax.TOKEN_BOOLEAN_LITERAL:
			return nodeFactory.create_node(NodeFactory.NODE_TYPES.BOOLEANLITERAL, 
				{"value" =token_walker.current_token.value})
		Syntax.TOKEN_NULL_TOKEN:
			return nodeFactory.create_node(NodeFactory.NODE_TYPES.NULL, {})
	assert(false, 'Token type not found : ' + token_walker.current_token.name)
	return null

func _operator(operator, lhs, rhs) -> ExpressionNode:
	return nodeFactory.create_node(NodeFactory.NODE_TYPES.EXPRESSION,
		{"name"= operator,"elements"= [lhs, rhs] })


func line_with_action(token_walker: TokenWalker, line : ClydeNode = null) -> ContentNode:
	var token = token_walker.peek(TokenArray.set_trigger)
	var expression : ClydeNode = _logic_element(token_walker)

	if line != null:
		var content : ClydeNode = line

		if token_walker.peek(TokenArray.brace_open) != null:
			token_walker.consume(TokenArray.brace_open)
			content = line_with_action(token_walker, line)

		if token_walker.peek(TokenArray.lineBreak) != null:
			token_walker.consume(TokenArray.lineBreak)

		if token == null || token.name == Syntax.TOKEN_KEYWORD_WHEN:
			return nodeFactory.create_node(NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT, 
				{"conditions" = expression, "content" = [content]})

		return nodeFactory.create_node(NodeFactory.NODE_TYPES.ACTION_CONTENT, 
			{"action"= [expression], "content"= [content]})

	if token_walker.peek(TokenArray.lineBreak) != null:
		token_walker.consume(TokenArray.lineBreak)
		return expression

	if token_walker.peek(TokenArray.eof) != null:
		return  expression

	if token_walker.peek(TokenArray.brace_open) != null:
		token_walker.consume(TokenArray.brace_open)
		if !token:
			return nodeFactory.create_node(NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT, 
				{"conditions" = expression, "content" = [line_with_action(token_walker)]})
		return nodeFactory.create_node(NodeFactory.NODE_TYPES.ACTION_CONTENT,
			{"action"= [expression], "content"= [line_with_action(token_walker)]})

	token_walker.consume(TokenArray.dialogue)

	if token == null:
		return nodeFactory.create_node(NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT, 
			{"conditions" = expression, "content" = [DialogueNodeParser.new().dialogue_line(token_walker)]})
	return nodeFactory.create_node(NodeFactory.NODE_TYPES.ACTION_CONTENT,
		{"action"= [expression], "content"= [DialogueNodeParser.new().dialogue_line(token_walker)]})
