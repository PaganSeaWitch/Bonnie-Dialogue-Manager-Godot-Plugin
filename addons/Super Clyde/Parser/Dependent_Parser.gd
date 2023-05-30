class_name DependentParser
extends MiscParser


func nested_logic_block() -> Dictionary:
	var root : ClydeNode
	var wrapper : ClydeNode
	while token_walker.current_token.name == Syntax.TOKEN_PLACEMENT_DEPENENT_OPEN:
		if root == null:
			root = _logic_block()
			wrapper = root
		else:
			var next = _logic_block()
			wrapper.content = [next]
			wrapper = next

		if token_walker.peek(TokenArray.brace_open):
			token_walker.consume(TokenArray.brace_open)

	return {
		"root": root,
		"wrapper": wrapper
	}

func _logic_block() -> LinePartNode:
	var line_part : LinePartNode = LinePartNode.new()
	if token_walker.peek(TokenArray.set) != null:
		var assignments : AssignmentsNode = parser.logic_parser._assignments()
		line_part.part = node_factory.create_node(node_factory.NODE_TYPES.ACTION_CONTENT,
			{"actions"= [assignments]})
		return line_part

	if token_walker.peek(TokenArray.trigger) != null:
		var events : EventsNode = parser.logic_parser._events()
		line_part.part = node_factory.create_node(node_factory.NODE_TYPES.ACTION_CONTENT,
			{"actions"= [events]})
		return line_part

	if token_walker.peek(TokenArray.when) != null:
		token_walker.consume(TokenArray.when)

	var condition : ClydeNode = parser.logic_parser._condition()
	line_part.part = node_factory.create_node(node_factory.NODE_TYPES.CONDITIONAL_CONTENT,
		{"conditions" = condition})
	return line_part


func conditional_line_part() -> LinePartNode :
	var expression : NamedNode = parser.logic_parser._condition()
	var line_part : LinePartNode = LinePartNode.new()
	var content

	if token_walker.peek(TokenArray.lineBreak):
		token_walker.consume(TokenArray.lineBreak)
		token_walker.consume(TokenArray.indent)
		content = parser.misc_parser.lines()
		token_walker.consume(TokenArray.end)
		line_part.end_line = true

	elif token_walker.peek(TokenArray.brace_open):
		token_walker.consume(TokenArray.brace_open)
		content = line_part_with_action()
	
	else:
		token_walker.consume(TokenArray.dialogue)
		content = parser.line_parser.dialogue_line()
		
		if token_walker.peek(TokenArray.brace_open):
			token_walker.consume(TokenArray.brace_open)
			content = line_part_with_action(content)

	var conditional_node : ConditionalContentNode
	
	if(typeof(content) == TYPE_ARRAY):
		conditional_node = node_factory.create_node(node_factory.NODE_TYPES.CONDITIONAL_CONTENT, 
			{"conditions" = expression, "content" = content})
	
	else:
		conditional_node = node_factory.create_node(node_factory.NODE_TYPES.CONDITIONAL_CONTENT, 
			{"conditions" = expression, "content" = [content]})
	line_part.part = conditional_node
	
	return line_part


func line_part_with_action(line : ClydeNode = null, content_node : ContentNode = null) -> ClydeNode:
	var token = token_walker.peek(TokenArray.set_trigger)
	if(content_node == null):
		content_node = ContentNode.new()
	var expression : ClydeNode = parser.logic_parser.logic_element()
	var line_part : LinePartNode = LinePartNode.new()

	if line != null:
		content_node.content.append(node_factory.create_node(node_factory.NODE_TYPES.LINE_PART,
			{"part" = line}))


	
	if token == null || token.name == Syntax.TOKEN_KEYWORD_WHEN:
		line_part.part = node_factory.create_node(node_factory.NODE_TYPES.CONDITIONAL_CONTENT, 
			{"conditions" = expression})

	else:
		line_part.part = node_factory.create_node(node_factory.NODE_TYPES.ACTION_CONTENT, 
			{"actions"= [expression]})
	
	if token_walker.peek(TokenArray.dialogue):
		token_walker.consume(TokenArray.dialogue)
		line_part.part.content = [parser.line_parser.dialogue_line()]
	
	if token_walker.peek(TokenArray.lineBreak) != null:
		token_walker.consume(TokenArray.lineBreak)
		line_part.end_line = true
	
	if token_walker.peek(TokenArray.eof) != null:
		line_part.end_line = true
	
	content_node.content.append(line_part)
	if(line_part.end_line == false && token_walker.peek(TokenArray.logic_open) != null):
		if token_walker.peek(TokenArray.brace_open) != null:
			token_walker.consume(TokenArray.brace_open)
			return line_part_with_action(null, content_node)
		if token_walker.peek(TokenArray.curly_brace_open) != null:
			token_walker.consume(TokenArray.curly_brace_open)
			return parser.logic_parser.line_with_action(content_node, true)
	return content_node;
