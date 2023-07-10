class_name LogicParser
extends MiscParser


func logic_element() -> BonnieNode:
	if token_walker.peek(TokenArray.set):
		var assignments = _assignments()
		return assignments


	if token_walker.peek(TokenArray.trigger):
		var events = _events()
		return events

	if token_walker.peek(TokenArray.when):
		token_walker.consume(TokenArray.when)

	var condition = _condition()
	return condition


func nested_logic_block() -> Dictionary:
	var root : BonnieNode
	var wrapper : BonnieNode
	while token_walker.current_token.name == Syntax.TOKEN_PLACEMENT_INDEPENENT_OPEN:
		if root == null:
			root = _logic_block()
			wrapper = root
		else:
			var next = _logic_block()
			wrapper.content = [next]
			wrapper = next

		if token_walker.peek(TokenArray.curly_brace_open):
			token_walker.consume(TokenArray.curly_brace_open)

	return {
		"root": root,
		"wrapper": wrapper
	}


func _logic_block() -> BonnieNode:
	if token_walker.peek(TokenArray.set) != null:
		var assignments : AssignmentsNode = _assignments()
		return node_factory.create_node(node_factory.NODE_TYPES.ACTION_CONTENT,
			{"actions"= [assignments]})

	if token_walker.peek(TokenArray.trigger) != null:
		var events : EventsNode = _events()
		return node_factory.create_node(node_factory.NODE_TYPES.ACTION_CONTENT,
			{"actions"= [events]})

	if token_walker.peek(TokenArray.when) != null:
		token_walker.consume(TokenArray.when)

	var condition : BonnieNode = _condition()
	return node_factory.create_node(node_factory.NODE_TYPES.CONDITIONAL_CONTENT,
		{"conditions" = condition})


func _events() -> EventsNode:
	token_walker.consume(TokenArray.trigger)
	token_walker.consume(TokenArray.identifier)
	var eventsNode : EventsNode = node_factory.create_node(node_factory.NODE_TYPES.EVENTS, 
		{"events" = [node_factory.create_node(node_factory.NODE_TYPES.EVENT, 
			{name = token_walker.current_token.value})]})

	while token_walker.peek(TokenArray.comma):
		token_walker.consume(TokenArray.comma)
		token_walker.consume(TokenArray.identifier)
		eventsNode.events.push_back(node_factory.create_node(node_factory.NODE_TYPES.EVENT, 
			{name = token_walker.current_token.value}))

	token_walker.consume(TokenArray.logic_close)

	return eventsNode


func conditional_line() -> ConditionalContentNode :
	var expression : NamedNode = _condition()
	var content

	if token_walker.peek(TokenArray.divert):
		content = parser.misc_parser.divert()
	elif token_walker.peek(TokenArray.lineBreak):
		token_walker.consume(TokenArray.lineBreak)
		token_walker.consume(TokenArray.indent)
		content = parser.misc_parser.lines()
		token_walker.consume(TokenArray.end)
	elif token_walker.peek(TokenArray.brace_open):
		token_walker.consume(TokenArray.brace_open)
		content = parser.dependent_parser.line_part_with_action()
	elif token_walker.peek(TokenArray.curly_brace_open):
		token_walker.consume(TokenArray.curly_brace_open)
		content = line_with_action()
	else:
		token_walker.consume(TokenArray.dialogue)
		content = parser.line_parser.dialogue_line()
		if token_walker.peek(TokenArray.curly_brace_open):
			token_walker.consume(TokenArray.curly_brace_open)
			content = line_with_action(content)
		elif token_walker.peek(TokenArray.brace_open):
			token_walker.consume(TokenArray.brace_open)
			content = parser.dependent_parser.line_part_with_action(content)
			
	if(typeof(content) == TYPE_ARRAY):
		return node_factory.create_node(node_factory.NODE_TYPES.CONDITIONAL_CONTENT, 
			{"conditions" = expression, "content" = content})
	return node_factory.create_node(node_factory.NODE_TYPES.CONDITIONAL_CONTENT, 
		{"conditions" = expression, "content" = [content]})


func _condition() -> BonnieNode:
	var token : Token = token_walker.peek([
		Syntax.TOKEN_IDENTIFIER,
		Syntax.TOKEN_NOT,
	])
	var expression : BonnieNode
	if token != null:
		expression = _expression()

	token_walker.consume(TokenArray.logic_close)
	return expression


func _assignments() -> AssignmentsNode:
	token_walker.consume(TokenArray.set)
	var assignments : Array[AssignmentNode] = [_assignment_expression()]
	while token_walker.peek(TokenArray.comma) != null:
		token_walker.consume(TokenArray.comma)
		assignments.push_back(_assignment_expression())

	token_walker.consume(TokenArray.logic_close)
	if(typeof(assignments) == TYPE_ARRAY):
		return node_factory.create_node(node_factory.NODE_TYPES.ASSIGNMENTS,
			{"assignments"= assignments})
	return node_factory.create_node(node_factory.NODE_TYPES.ASSIGNMENTS,
		{"assignments"= [assignments]})


func _assignment_expression() -> AssignmentNode:
	var assignment : BonnieNode = _assignment_expression_internal()

	if assignment is VariableNode:
		return node_factory.create_node(node_factory.NODE_TYPES.ASSIGNMENT, 
			{"variable" = assignment, 
			"operation"= Syntax.TOKEN_ASSIGN, 
			"value" = node_factory.create_node(node_factory.NODE_TYPES.BOOLEAN_LITERAL,
				{"value"= 'true'})})
	if assignment is AssignmentNode:
		return assignment
	
	assert(false, 'Expected AssignmentNode instead got : ' +assignment.get_node_class())
	return null
	


func _assignment_expression_internal() -> BonnieNode:
	token_walker.consume(TokenArray.identifier)
	var variable : VariableNode = node_factory.create_node(node_factory.NODE_TYPES.VARIABLE, 
		{"name" : token_walker.current_token.value})

	if token_walker.peek(TokenArray.logic_close) != null:
		return variable


	token_walker.consume(TokenArray.operator_assignments)

	if (token_walker.peek(TokenArray.identifier) != null
	&& token_walker.peek(TokenArray.operators_and_bracket_close, 1) != null):
		return node_factory.create_node(node_factory.NODE_TYPES.ASSIGNMENT, 
			{"variable" = variable,"operation"= token_walker.current_token.name,
			"value" = _assignment_expression_internal()})
	
	return node_factory.create_node(node_factory.NODE_TYPES.ASSIGNMENT, 
		{"variable" = variable,"operation"= token_walker.current_token.name,
		"value" = _expression()})


func _expression(min_precedence : int = 1) -> BonnieNode:
	var lhs : BonnieNode = _operand()

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
		var rhs = _expression(next_min_precedence)
		lhs = _operator(operator_name, lhs, rhs)

	return lhs


func _operand() -> BonnieNode:
	token_walker.consume(TokenArray.operator_literals)

	match token_walker.current_token.name:
		Syntax.TOKEN_NOT:
			return node_factory.create_node(node_factory.NODE_TYPES.EXPRESSION, 
				{"name"=token_walker.current_token.name,"elements"= [_operand()]})
		Syntax.TOKEN_IDENTIFIER:
			return node_factory.create_node(node_factory.NODE_TYPES.VARIABLE, 
				{"name" = token_walker.current_token.value})
		Syntax.TOKEN_NUMBER_LITERAL:
			return node_factory.create_node(node_factory.NODE_TYPES.NUMBER_LITERAL, 
				{"value" = token_walker.current_token.value})
		Syntax.TOKEN_STRING_LITERAL:
			return node_factory.create_node(node_factory.NODE_TYPES.STRING_LITERAL, 
				{"value" =token_walker.current_token.value})
		Syntax.TOKEN_BOOLEAN_LITERAL:
			return node_factory.create_node(node_factory.NODE_TYPES.BOOLEAN_LITERAL, 
				{"value" =token_walker.current_token.value})
		Syntax.TOKEN_NULL_TOKEN:
			return node_factory.create_node(node_factory.NODE_TYPES.NULL, {})
	assert(false, 'Token type not found : ' + token_walker.current_token.name)
	return null

func _operator(operator, lhs, rhs) -> ExpressionNode:
	return node_factory.create_node(node_factory.NODE_TYPES.EXPRESSION,
		{"name"= operator,"elements"= [lhs, rhs] })


func line_with_action(line : BonnieNode = null, from_dependent_logic : bool = false) -> ContentNode:
	var token = token_walker.peek(TokenArray.set_trigger)
	var expression : BonnieNode = logic_element()

	if line != null:
		var content : BonnieNode = line
		
		if token_walker.peek(TokenArray.dialogue) != null && from_dependent_logic:
			token_walker.consume(TokenArray.dialogue)
			if(content.content.back().part is ConditionalContentNode || content.content.back().part is ActionContentNode):
				content.content.back().part.content.append(parser.line_parser.dialogue_line())
			else:
				content.content.append(node_factory.create_node(node_factory.NODE_TYPES.LINE_PART,
					{"part" = parser.line_parser.dialogue_line()}))
		
		if token_walker.peek(TokenArray.brace_open) != null:
			token_walker.consume(TokenArray.brace_open)
			if(from_dependent_logic):
				content = parser.dependent_parser.line_part_with_action(null, line)
			else:
				content = parser.dependent_parser.line_part_with_action(line)
		if token_walker.peek(TokenArray.curly_brace_open) != null:
			token_walker.consume(TokenArray.curly_brace_open)
			content = line_with_action(line,from_dependent_logic)

		if token_walker.peek(TokenArray.lineBreak) != null:
			token_walker.consume(TokenArray.lineBreak)
			if(from_dependent_logic && 
			(content is ActionContentNode ==  false) && (content is ConditionalContentNode == false)):
				content.content.back().end_part = true
		if token_walker.peek(TokenArray.eof) != null:
			if(from_dependent_logic && 
			(content is ActionContentNode ==  false) && (content is ConditionalContentNode == false)):
				content.content.back().end_line = true
		
		if token == null || token.name == Syntax.TOKEN_KEYWORD_WHEN:
			return node_factory.create_node(node_factory.NODE_TYPES.CONDITIONAL_CONTENT, 
				{"conditions" = expression, "content" = [content]})

		return node_factory.create_node(node_factory.NODE_TYPES.ACTION_CONTENT, 
			{"actions"= [expression], "content"= [content]})

	if token_walker.peek(TokenArray.lineBreak) != null:
		token_walker.consume(TokenArray.lineBreak)
		return expression

	if token_walker.peek(TokenArray.eof) != null:
		return  expression

	if token_walker.peek(TokenArray.curly_brace_open) != null:
		token_walker.consume(TokenArray.curly_brace_open)
		if !token:
			return node_factory.create_node(node_factory.NODE_TYPES.CONDITIONAL_CONTENT, 
				{"conditions" = expression, "content" = [line_with_action()]})
		return node_factory.create_node(node_factory.NODE_TYPES.ACTION_CONTENT,
			{"actions"= [expression], "content"= [line_with_action()]})

	if token_walker.peek(TokenArray.brace_open) != null:
		token_walker.consume(TokenArray.brace_open)
		if !token:
			return node_factory.create_node(node_factory.NODE_TYPES.CONDITIONAL_CONTENT, 
					{"conditions" = expression, "content" = [parser.dependent_parser.line_part_with_action()]})
		return node_factory.create_node(node_factory.NODE_TYPES.ACTION_CONTENT,
			{"actions"= [expression], "content"= [parser.dependent_parser.line_part_with_action()]})
	
	token_walker.consume(TokenArray.dialogue)

	if token == null:
		return node_factory.create_node(node_factory.NODE_TYPES.CONDITIONAL_CONTENT, 
			{"conditions" = expression, "content" = [parser.line_parser.dialogue_line()]})
	return node_factory.create_node(node_factory.NODE_TYPES.ACTION_CONTENT,
		{"actions"= [expression], "content"= [parser.line_parser.dialogue_line()]})
