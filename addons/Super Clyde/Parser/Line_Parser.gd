class_name LineParser
extends MiscParser


func dialogue_line() -> DialogueNode:
	match token_walker.current_token.name:
		Syntax.TOKEN_SPEAKER:
			return _line_with_speaker()
		Syntax.TOKEN_TEXT:
			return _text_line()
	return null


func _line_with_speaker():
	var token_value : String = token_walker.current_token.value
	if(token_walker.peek(TokenArray.bb_code_open) || token_walker.peek(TokenArray.brace_open)):
		var line : DialogueNode = LineNode.new()
		line.speaker = token_value
		return line

	token_walker.consume(TokenArray.text)
	var line : DialogueNode = dialogue_line()
	line.speaker =  token_value
	return line


func _text_line() -> DialogueNode:
	var token_value : String = token_walker.current_token.value
	var next_token : Token = token_walker.peek(TokenArray.tag_and_id)
	var line : DialogueNode =  DialogueNode.new()

	# Rule : If there is a tag or id token after line token, add values to line
	if next_token != null:
		token_walker.consume(TokenArray.tag_and_id)
		line = _line_with_metadata()
		line.value = token_value
	
	else:
		line = node_factory.create_node(node_factory.NODE_TYPES.LINE, 
			{"value" = token_value}) as LineNode


	if token_walker.is_multiline_enabled && (token_walker.peek(TokenArray.indent) 
	|| ( token_walker.peek(TokenArray.lineBreak) && token_walker.peek(TokenArray.indent, 1))):
		
		if(token_walker.peek(TokenArray.lineBreak)):
			token_walker.consume(TokenArray.lineBreak)
		
		token_walker.consume(TokenArray.indent)

		if token_walker.peek(TokenArray.options):
			var options : OptionsNode = parser.options_parser.options()
			options.id = line.id
			options.value = line.value
			options.tags = line.tags
			options.id_suffixes = line.id_suffixes
			line = options
		else:
			while !token_walker.peek(TokenArray.end):
				token_walker.consume(TokenArray.text)
				var next_line : DialogueNode = _text_line()
				line.value += " %s" % next_line.value
				
				if next_line.id:
					line.id = next_line.id
					line.id_suffixes = next_line.id_suffixes

				if next_line.tags:
					line.tags = next_line.tags

			token_walker.consume(TokenArray.end)

	return line


func _line_with_metadata() -> LineNode:
	match token_walker.current_token.name:
		Syntax.TOKEN_LINE_ID:
			return _line_with_id()
		Syntax.TOKEN_TAG:
			return _line_with_tags()
	return null;


func _line_with_id() -> LineNode:
	var token_value : String = token_walker.current_token.value
	var suffixes : Array[String] = []

	if token_walker.peek(TokenArray.id_suffixes):
		suffixes = _id_suffixes()


	if token_walker.peek(TokenArray.tag):
		token_walker.consume(TokenArray.tag)
		var line = _line_with_tags()
		line.id = token_value
		line.id_suffixes = suffixes
		return line

	return node_factory.create_node(node_factory.NODE_TYPES.LINE,
		{"id" = token_value,"id_suffixes"= suffixes}) as LineNode


func _id_suffixes() -> Array[String]:
	var suffixes : Array[String] = []
	while token_walker.peek(TokenArray.id_suffixes):
		var token : Token = token_walker.consume(TokenArray.id_suffixes)
		suffixes.push_back(token.value)
	return suffixes


func _line_with_tags() -> LineNode:
	
	var token_value : String = token_walker.current_token.value
	var next_token : Token = token_walker.peek(TokenArray.tag_and_id)
	
	if next_token:
		token_walker.consume(TokenArray.tag_and_id)
		var line = _line_with_metadata()

		line.tags.push_front(token_value)
		return line

	return node_factory.create_node(node_factory.NODE_TYPES.LINE,
		{"tags"=[token_value]})
