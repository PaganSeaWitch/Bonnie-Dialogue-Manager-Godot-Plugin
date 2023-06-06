class_name DependentParser
extends LinePartParser


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
	
	if(token_walker.peek(TokenArray.tag_and_id)):
		line_part.part.content = [parser.line_parser._text_line()]

	if token_walker.peek(TokenArray.lineBreak):
		token_walker.consume(TokenArray.lineBreak)
		line_part.end_line = true
	
	if token_walker.peek(TokenArray.eof):
		line_part.end_line = true
	

	return _update_line_parts(content_node, line_part)
