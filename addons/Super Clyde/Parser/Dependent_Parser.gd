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
	
	var speaker : String = _get_from_line_part(content_node.content[0].part, "speaker")
	var tags : Array[String]= _get_from_line_part(content_node.content.back().part, "tags")
	var id : String = _get_from_line_part(content_node.content.back().part, "id")
	var id_suffixes : Array[String] = _get_from_line_part(content_node.content.back().part, "id_suffixes")

	var i = 0;
	for line_part in content_node.content:
		var part = line_part.part;
		if(part is LineNode):
			line_part.part = add_to_line_part(part, speaker, tags, id, id_suffixes, index)
		else:
			line_part.part.content[0] = add_to_line_part(part.content[0], speaker, tags, id, id_suffixes, index)	

	return content_node;


func add_to_line_part(line : LineNode, speaker : String, tags : Array[String], id : String, id_suffixes : Array[String], index : int):
	if(speaker != null)
		line.speaker = speaker
	if(tags != null):
		line.tags.append_array(tags)
	if(!id.is_empty()):
		line.id = id + "_" + str(i);
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
