class_name DependentParser
extends LinePartParser


func line_part_with_action(line : BonnieNode = null, content_node : ContentNode = null) -> BonnieNode:
	var token = token_walker.peek(TokenArray.set_trigger)
	if(content_node == null):
		content_node = ContentNode.new()
	var expression : BonnieNode = parser.logic_parser.logic_element()
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
		var new_line = parser.line_parser.dialogue_line()
		if token_walker.peek(TokenArray.bb_code_open):
			token_walker.consume(TokenArray.bb_code_open)
			var inner_line_part : LinePartNode = LinePartNode.new()
			inner_line_part.part = new_line
			line_part.part.content.append(inner_line_part)
			line_part.part.content.append_array(parser.bb_code_parser.inner_line_part_with_bb_code())
		else:
			line_part.part.content = [new_line]


	if token_walker.peek(TokenArray.bb_code_open):
		token_walker.consume(TokenArray.bb_code_open)
		line_part.part.content = parser.bb_code_parser.inner_line_part_with_bb_code()

	if(token_walker.peek(TokenArray.tag_and_id)):
		line_part.part.content = [parser.line_parser._text_line()]


	return _update_line_parts(content_node, line_part)
