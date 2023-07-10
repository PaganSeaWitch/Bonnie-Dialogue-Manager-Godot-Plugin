class_name OptionsParser
extends MiscParser



func options() -> OptionsNode:
	var options : OptionsNode = node_factory.create_node(node_factory.NODE_TYPES.OPTIONS, {})

	while token_walker.peek(TokenArray.options):
		options.content.push_back(_option())

	if token_walker.peek(TokenArray.dedent):
		token_walker.consume(TokenArray.dedent)

	return options


func _option() -> BonnieNode:
	token_walker.consume(TokenArray.options)
	var type : String = SyntaxDictionaries.option_types[token_walker.current_token.name]
	var acceptable_next : Array[String]= TokenArray.options_acceptable_next
	var lines : Array= []
	var main_item : LineNode
	var include_label_as_content : bool = false
	var root : BonnieNode
	var wrapper : BonnieNode

	token_walker.consume(acceptable_next)
	if token_walker.current_token.name == Syntax.TOKEN_ASSIGN:
		include_label_as_content = true
		token_walker.consume(acceptable_next)
		
	if token_walker.current_token.name == Syntax.TOKEN_PLACEMENT_INDEPENENT_OPEN:
		var block : Dictionary = parser.logic_parser.nested_logic_block()
		root = block.root
		wrapper = block.wrapper
		token_walker.consume(acceptable_next)

	if (token_walker.current_token.name == Syntax.TOKEN_SPEAKER 
	|| token_walker.current_token.name == Syntax.TOKEN_TEXT):
		token_walker.is_multiline_enabled = false
		main_item = parser.line_parser.dialogue_line()
		token_walker.is_multiline_enabled = true
		if include_label_as_content:
			lines.push_back(main_item)

	if token_walker.peek(TokenArray.curly_brace_open):
		token_walker.consume(TokenArray.curly_brace_open)
		var block = parser.logic_parser.nested_logic_block()

		if root == null:
			root = block.root
			wrapper = block.wrapper
		else:
			wrapper.content = [block.wrapper]
			wrapper = block.wrapper

	if(token_walker.peek(TokenArray.lineBreak)):
		token_walker.consume(TokenArray.lineBreak)


	if (token_walker.current_token.name == Syntax.TOKEN_INDENT 
	|| token_walker.peek(TokenArray.indent)):
		if token_walker.current_token.name != Syntax.TOKEN_INDENT:
			token_walker.consume(TokenArray.indent)

		lines.append_array(parser.misc_parser.lines())
		if main_item == null:
			main_item = lines[0]

		token_walker.consume(TokenArray.end)


	var node : OptionNode = node_factory.create_node(
		node_factory.NODE_TYPES.OPTION,{
		"content" = lines,
		"mode" = type,
		"value" = main_item.value,
		"id" = main_item.id,
		"speaker" = main_item.speaker,
		"tags" = main_item.tags,
		"id_suffixes" = main_item.id_suffixes})

	if root:
		wrapper.content = [node]
		return root

	return node
