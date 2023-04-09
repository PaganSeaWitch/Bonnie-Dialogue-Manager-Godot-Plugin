class_name DialogueNodeParser
extends RefCounted

var node_factory : NodeFactory = NodeFactory.new()





func dialogue_line(token_walker : TokenWalker) -> DialogueNode:
	match token_walker.current_token.name:
		Syntax.TOKEN_SPEAKER:
			return _line_with_speaker(token_walker)
		Syntax.TOKEN_TEXT:
			return _text_line(token_walker)
	return null


func _line_with_speaker(token_walker : TokenWalker) -> DialogueNode:
	var token_value : String = token_walker.current_token.value
	token_walker.consume(TokenArray.text)
	var line : DialogueNode = dialogue_line(token_walker)
	line.speaker =  token_value
	return line


func _text_line(token_walker : TokenWalker) -> DialogueNode:
	var token_value : String = token_walker.current_token.value
	var next_token : Token = token_walker.peek(TokenArray.tag_and_id)
	var line : DialogueNode =  DialogueNode.new()

	# Rule : If there is a tag or id token after linetoken, add values to line
	if next_token != null:
		token_walker.consume(TokenArray.tag_and_id)
		line = _line_with_metadata(token_walker)
		line.value = token_value
	
	else:
		line = node_factory.create_node(node_factory.NODE_TYPES.LINE, 
			{"value" = token_value}) as LineNode


	if token_walker.is_multiline_enabled && token_walker.peek(TokenArray.indent):
		token_walker.consume(TokenArray.indent)

		if token_walker.peek(TokenArray.options):
			var options : OptionsNode = options(token_walker)
			options.id = line.id
			options.name = line.value
			options.tags = line.tags
			options.id_suffixes = line.id_suffixes
			line = options
		else:
			while !token_walker.peek(TokenArray.end):
				token_walker.consume(TokenArray.text)
				var next_line : DialogueNode = _text_line(token_walker)
				line.value += " %s" % next_line.value
				
				if next_line.id:
					line.id = next_line.id
					line.id_suffixes = next_line.id_suffixes

				if next_line.tags:
					line.tags = next_line.tags

			token_walker.consume(TokenArray.end)

	return line


func _line_with_metadata(token_walker : TokenWalker) -> LineNode:
	match token_walker.current_token.name:
		Syntax.TOKEN_LINE_ID:
			return _line_with_id(token_walker)
		Syntax.TOKEN_TAG:
			return _line_with_tags(token_walker)
	return null;


func _line_with_id(token_walker : TokenWalker) -> LineNode:
	var token_value : String = token_walker.current_token.value
	var suffixes : Array[String] = []

	if token_walker.peek(TokenArray.id_suffixes):
		suffixes = _id_suffixes(token_walker)


	if token_walker.peek(TokenArray.tag):
		token_walker.consume(TokenArray.tag)
		var line = _line_with_tags(token_walker)
		line.id = token_value
		line.id_suffixes = suffixes
		return line

	return node_factory.create_node(node_factory.NODE_TYPES.LINE,
		{"id" = token_value,"id_suffixes"= suffixes}) as LineNode


func _id_suffixes(token_walker : TokenWalker) -> Array[String]:
	var suffixes : Array[String] = []
	while token_walker.peek(TokenArray.id_suffixes):
		var token : Token = token_walker.consume(TokenArray.id_suffixes)
		suffixes.push_back(token.value)
	return suffixes


func _line_with_tags(token_walker : TokenWalker) -> LineNode:
	
	var token_value : String = token_walker.current_token.value
	var next_token : Token = token_walker.peek(TokenArray.tag_and_id)
	
	if next_token:
		token_walker.consume(TokenArray.tag_and_id)
		var line = _line_with_metadata(token_walker)

		line.tags.push_front(token_value)
		return line

	return node_factory.create_node(node_factory.NODE_TYPES.LINE,
		{"tags"=[token_value]})


func options(token_walker : TokenWalker) -> OptionsNode:
	var options : OptionsNode = node_factory.create_node(node_factory.NODE_TYPES.OPTIONS, {})

	while token_walker.peek(TokenArray.options):
		options.content.push_back(_option(token_walker))

	if token_walker.peek(TokenArray.dedent):
		token_walker.consume(TokenArray.dedent)

	return options


func _option(token_walker : TokenWalker) -> ClydeNode:
	token_walker.consume(TokenArray.options)
	var type : String = SyntaxDictionaries.option_types[token_walker.current_token.name]
	var acceptable_next : Array[String]= TokenArray.options_acceptable_next
	var lines : Array= []
	var main_item : LineNode = LineNode.new()
	var include_label_as_content : bool = false
	var root : ClydeNode
	var wrapper : ClydeNode

	token_walker.consume(acceptable_next)
	if token_walker.current_token.name == Syntax.TOKEN_ASSIGN:
		include_label_as_content = true
		token_walker.consume(acceptable_next)
		
	if token_walker.current_token.name == Syntax.TOKEN_BRACE_OPEN:
		var block : Dictionary = LogicNodeParser.new().nested_logic_block(token_walker)
		root = block.root
		wrapper = block.wrapper
		token_walker.consume(acceptable_next)

	if (token_walker.current_token.name == Syntax.TOKEN_SPEAKER 
	|| token_walker.current_token.name == Syntax.TOKEN_TEXT):
		token_walker.is_multiline_enabled = false
		main_item = DialogueNodeParser.new().dialogue_line(token_walker)
		token_walker.is_multiline_enabled = true
		if include_label_as_content:
			lines.push_back(main_item)

	if token_walker.peek(TokenArray.brace_open):
		token_walker.consume(TokenArray.brace_open)
		var block = LogicNodeParser.new().nested_logic_block(token_walker)

		if root == null:
			root = block.root
			wrapper = block.wrapper
		else:
			wrapper.content = [block.wrapper]
			wrapper = block.wrapper

		token_walker.consume(TokenArray.lineBreak)


	if (token_walker.current_token.name == Syntax.TOKEN_INDENT 
	|| token_walker.peek(TokenArray.indent)):
		if token_walker.current_token.name != Syntax.TOKEN_INDENT:
			token_walker.consume(TokenArray.indent)

		lines.append_array(MiscNodeParser.new().lines(token_walker))
		if !main_item:
			main_item = lines[0]

		token_walker.consume(TokenArray.end)


	var node : OptionNode = node_factory.create_node(
		node_factory.NODE_TYPES.OPTION,{
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

