class_name DialogueNodeParser
extends RefCounted

var nodeFactory : NodeFactory = NodeFactory.new()


var option_types = {
	Syntax.TOKEN_OPTION: 'once',
	Syntax.TOKEN_STICKY_OPTION: 'sticky',
	Syntax.TOKEN_FALLBACK_OPTION: 'fallback',
}


func _dialogue_line(tokenWalker : TokenWalker) -> DialogueNode:
	match tokenWalker.current_token.name:
		Syntax.TOKEN_SPEAKER:
			return _line_with_speaker(tokenWalker)
		Syntax.TOKEN_TEXT:
			return _text_line(tokenWalker)
	return null


func _line_with_speaker(tokenWalker : TokenWalker) -> DialogueNode:
	var value = tokenWalker.current_token.value
	tokenWalker.consume(TokenArray.text)
	var line = _dialogue_line(tokenWalker)
	line.speaker =  value
	return line


func _text_line(tokenWalker : TokenWalker) -> DialogueNode:
	var value = tokenWalker.current_token.value
	var next = tokenWalker.peek(TokenArray.tagAndId)
	var line : DialogueNode =  DialogueNode.new()

	if next:
		tokenWalker.consume(TokenArray.tagAndId)
		line = _line_with_metadata(tokenWalker)
		line.value = value
	else:
		line = nodeFactory.CreateNode(NodeFactory.NODE_TYPES.LINE, {"value"=value}) as LineNode


	if tokenWalker._is_multiline_enabled && tokenWalker.peek(TokenArray.indent):
		tokenWalker.consume(TokenArray.indent)

		if tokenWalker.peek(TokenArray.options):
			var options = _options(tokenWalker)
			options.id = line.id
			options.name = line.value
			options.tags = line.tags
			options.id_suffixes = line.id_suffixes
			line = options
		else:
			while !tokenWalker.peek(TokenArray.end):
				tokenWalker.consume(TokenArray.text)
				var next_line = _text_line(tokenWalker)
				line.value += " %s" % next_line.value
				if next_line.id:
					line.id = next_line.id
					line.id_suffixes = next_line.id_suffixes

				if next_line.tags:
					line.tags = next_line.tags

			tokenWalker.consume(TokenArray.end)

	return line


func _line_with_metadata(tokenWalker : TokenWalker) -> LineNode:
	match tokenWalker.current_token.name:
		Syntax.TOKEN_LINE_ID:
			return _line_with_id(tokenWalker)
		Syntax.TOKEN_TAG:
			return _line_with_tags(tokenWalker)
	return null;


func _line_with_id(tokenWalker : TokenWalker) -> LineNode:
	var tokenValue = tokenWalker.current_token.value
	var suffixes : Array[String] = []

	if tokenWalker.peek(TokenArray.idSuffixes):
		suffixes = _id_suffixes(tokenWalker)


	if tokenWalker.peek(TokenArray.tag):
		tokenWalker.consume(TokenArray.tag)
		var line = _line_with_tags(tokenWalker)
		line.id = tokenValue
		line.id_suffixes = suffixes
		return line

	return nodeFactory.CreateNode(NodeFactory.NODE_TYPES.LINE, {"id" =tokenValue,"id_suffixes"= suffixes}) as LineNode


func _id_suffixes(tokenWalker : TokenWalker) -> Array[String]:
	var suffixes : Array[String] = []
	while tokenWalker.peek(TokenArray.idSuffixes):
		var token : Token = tokenWalker.consume(TokenArray.idSuffixes)
		suffixes.push_back(token.value)
	return suffixes


func _line_with_tags(tokenWalker : TokenWalker) -> LineNode:
	var value = tokenWalker.current_token.value
	var next = tokenWalker.peek(TokenArray.tagAndId)
	if next:
		tokenWalker.consume(TokenArray.tagAndId)
		var line = _line_with_metadata(tokenWalker)

		line.tags.push_front(value)
		return line

	return nodeFactory.CreateNode(NodeFactory.NODE_TYPES.LINE,{"tags"=[value]})


func _options(tokenWalker : TokenWalker) -> OptionsNode:
	var options = nodeFactory.CreateNode(NodeFactory.NODE_TYPES.OPTIONS, {})

	while tokenWalker.peek(TokenArray.options):
		options.content.push_back(_option(tokenWalker))

	if tokenWalker.peek(TokenArray.dedent):
		tokenWalker.consume(TokenArray.dedent)

	return options


func _option(tokenWalker : TokenWalker) -> ClydeNode:
	tokenWalker.consume(TokenArray.options)
	var type = option_types[tokenWalker.current_token.name]
	var acceptable_next = TokenArray.optionsAcceptableNext
	var lines = []
	var main_item : LineNode = LineNode.new()
	var include_label_as_content = false
	var root
	var wrapper

	tokenWalker.consume(acceptable_next)
	if tokenWalker.current_token.name == Syntax.TOKEN_ASSIGN:
		include_label_as_content = true
		tokenWalker.consume(acceptable_next)
		
	if tokenWalker.current_token.name == Syntax.TOKEN_BRACE_OPEN:
		var block = LogicNodeParser.new()._nested_logic_block(tokenWalker)
		root = block.root
		wrapper = block.wrapper
		tokenWalker.consume(acceptable_next)

	if tokenWalker.current_token.name == Syntax.TOKEN_SPEAKER or tokenWalker.current_token.name == Syntax.TOKEN_TEXT:
		tokenWalker._is_multiline_enabled = false
		main_item = DialogueNodeParser.new()._dialogue_line(tokenWalker)
		tokenWalker._is_multiline_enabled = true
		if include_label_as_content:
			lines.push_back(main_item)

	if tokenWalker.peek(TokenArray.braceOpen):
		tokenWalker.consume(TokenArray.braceOpen)
		var block = LogicNodeParser.new()._nested_logic_block(tokenWalker)

		if not root:
			root = block.root
			wrapper = block.wrapper
		else:
			wrapper.content = [block.wrapper]
			wrapper = block.wrapper

		tokenWalker.consume(TokenArray.lineBreak)


	if tokenWalker.current_token.name == Syntax.TOKEN_INDENT || tokenWalker.peek(TokenArray.indent):
		if tokenWalker.current_token.name != Syntax.TOKEN_INDENT:
			tokenWalker.consume(TokenArray.indent)

		lines.append_array(MiscNodeParser.new()._lines(tokenWalker))
		if !main_item:
			main_item = lines[0]

		tokenWalker.consume(TokenArray.end)


	var node : OptionNode = nodeFactory.CreateNode(NodeFactory.NODE_TYPES.OPTION,{
		"content" = lines,
		"mode" = type,
		"name" = main_item.value,
		"id" = main_item.id,
		"speaker" = main_item.speaker,
		"tags" = main_item.tags,
		"id_suffixes" = main_item.id_suffixes})

	if root:
		wrapper.content = [node]
		return root

	return node

