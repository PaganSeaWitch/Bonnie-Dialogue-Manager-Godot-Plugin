class_name DependentParser
extends MiscParser


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
	
	content_node.content.append(line_part)
	if(line_part.end_line == false && token_walker.peek(TokenArray.logic_open) != null):
		if token_walker.peek(TokenArray.brace_open) != null:
			token_walker.consume(TokenArray.brace_open)
			return line_part_with_action(null, content_node)
		if token_walker.peek(TokenArray.curly_brace_open) != null:
			token_walker.consume(TokenArray.curly_brace_open)
			return parser.logic_parser.line_with_action(content_node, true)
	
	
	var speaker = _get_from_line_part(content_node.content[0].part, "speaker")
	var tags  = _get_from_line_part(content_node.content.back().part, "tags")
	var id  = _get_from_line_part(content_node.content.back().part, "id")
	var id_suffixes = _get_from_line_part(content_node.content.back().part, "id_suffixes")


	for i in range(content_node.content.size()):
		var inner_line_part : LinePartNode = content_node.content[i];
		var part = inner_line_part.part;
		if(part is LineNode):
			if(i == content_node.content.size() - 1):
				inner_line_part.part = add_to_line_part(part, speaker, null, id, null, i)
			else:
				inner_line_part.part = add_to_line_part(part, speaker, tags, id, id_suffixes, i)
		else:
			if(!inner_line_part.part.content.is_empty()):
				if(i == content_node.content.size() - 1):
					inner_line_part.part.content[0] = add_to_line_part(part.content[0], speaker, null, id, null, i)	
				else:
					inner_line_part.part.content[0] = add_to_line_part(part.content[0], speaker, tags, id, id_suffixes, i)	

	content_node.content.back().end_line = true
	return content_node;


func add_to_line_part(line : LineNode, speaker, tags, id, id_suffixes, index : int):
	if(speaker != null):
		line.speaker = speaker
	if(tags != null):
		line.tags.append_array(tags)
	if(id != null && !id.is_empty()):
		line.id = id + "_" + str(index);
	if(id_suffixes != null):
		line.id_suffixes.append_array(id_suffixes)
	return line 
	

func _get_from_line_part(node : ClydeNode, member : String):
	if(node is LineNode):
		return node.get(member)
	else:
		for content in node.content:
			var something = _get_from_line_part(content, member)
			if(something != null):
				return something
		return null
