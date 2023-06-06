class_name BBCodeParser
extends LinePartParser


func line_part_with_bb_code(line : ClydeNode = null, content_node : ContentNode = null) -> ClydeNode:

	if(content_node == null):
		content_node = ContentNode.new()
	var line_part : LinePartNode = LinePartNode.new()
	
	var bb_code_value = _get_bb_code_value()


	if line != null:
		content_node.content.append(node_factory.create_node(node_factory.NODE_TYPES.LINE_PART,
			{"part" = line}))

	if token_walker.peek(TokenArray.dialogue):
		token_walker.consume(TokenArray.dialogue)
		line_part.part = parser.line_parser.dialogue_line()
		line_part.part.bb_code_before_line = bb_code_value
		
	elif(token_walker.peek(TokenArray.tag_and_id)):
		line_part.part = parser.line_parser._text_line()
		line_part.part.bb_code_before_line = bb_code_value

	if token_walker.peek(TokenArray.lineBreak):
		token_walker.consume(TokenArray.lineBreak)
		line_part.end_line = true
	
	if token_walker.peek(TokenArray.eof):
		line_part.end_line = true
	

	return _update_line_parts(content_node, line_part)


func _get_bb_code_value() -> String:
	var bb_open_value : String = token_walker.current_token.name
	var bb_code_value : String = token_walker.consume(TokenArray.bb_code).value
	var bb_end_value : String = token_walker.consume(TokenArray.bb_code_close).name
	return bb_open_value + bb_code_value + bb_end_value
