class_name BBCodeParser
extends LinePartParser

func get_line_part_with_bb_code(content_node : ContentNode = null):
	var line_part : LinePartNode = LinePartNode.new()
	var bb_code_value = _get_bb_code_value()
	
	var line : DialogueNode = LineNode.new()
	
	if token_walker.peek(TokenArray.dialogue):
		token_walker.consume(TokenArray.dialogue)
		line = parser.line_parser.dialogue_line()

		
	elif(token_walker.peek(TokenArray.tag_and_id)):
		line = parser.line_parser._text_line()

	line.bb_code_before_line = bb_code_value
	line_part.part = line
	
	if token_walker.peek(TokenArray.lineBreak):
		line_part.end_line = true

	if token_walker.peek(TokenArray.eof):
		line_part.end_line = true
	
	return line_part

func inner_line_part_with_bb_code():
	
	var line_part_array : Array[LinePartNode] = []
	line_part_array.append(get_line_part_with_bb_code())
	while(token_walker.peek(TokenArray.bb_code_open)):
		token_walker.consume(TokenArray.bb_code_open)
		line_part_array.append(get_line_part_with_bb_code())
	
	return line_part_array

func line_part_with_bb_code(line : BonnieNode = null, content_node : ContentNode = null) -> BonnieNode:

	if(content_node == null):
		content_node = ContentNode.new()

	if line != null:
		content_node.content.append(node_factory.create_node(node_factory.NODE_TYPES.LINE_PART,
			{"part" = line}))

	var bb_code_line = get_line_part_with_bb_code(content_node)
	
	return _update_line_parts(content_node, bb_code_line)


func _get_bb_code_value() -> String:
	var bb_open_value : String = token_walker.current_token.name
	var bb_code_value : String = token_walker.consume(TokenArray.bb_code).value
	var bb_end_value : String = token_walker.consume(TokenArray.bb_code_close).name
	return bb_open_value + bb_code_value + bb_end_value
