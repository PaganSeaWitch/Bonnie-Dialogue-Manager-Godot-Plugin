class_name MiscNodeParser
extends RefCounted

var nodeFactory : NodeFactory = NodeFactory.new()



func document(tokenWalker : TokenWalker) -> DocumentNode:

	var nextToken : Token = tokenWalker.peek(TokenArray.expected)

	if nextToken == null:
		tokenWalker._wrong_token_error(nextToken, TokenArray.expected)
		return
	match(nextToken.name):
		Syntax.TOKEN_EOF:
			return nodeFactory.create_node(nodeFactory.NODE_TYPES.DOCUMENT, {})
		
		Syntax.TOKEN_BLOCK, Syntax.TOKEN_RANDOM_BLOCK:
			return nodeFactory.create_node(nodeFactory.NODE_TYPES.DOCUMENT,
				{"content"= [], "blocks"= _blocks(tokenWalker)})
		
		Syntax.TOKEN_RANDOM_FALLBACK_BLOCK, Syntax.TOKEN_RANDOM_STICKY_BLOCK:
			return nodeFactory.create_node(nodeFactory.NODE_TYPES.DOCUMENT,
				{"content"= [], "blocks"= _blocks(tokenWalker)})

	var result =  nodeFactory.create_node(nodeFactory.NODE_TYPES.DOCUMENT, 
		{"content" = lines(tokenWalker)})

	if tokenWalker.peek(TokenArray.block_types):
		result.blocks = _blocks(tokenWalker)

	return result


func _blocks(tokenWalker : TokenWalker) -> Array[BlockNode]:
	var token : Token = tokenWalker.consume(TokenArray.block_types)
	var node = BlockNode

	if(token.name == Syntax.TOKEN_BLOCK):
		node = nodeFactory.create_node(nodeFactory.NODE_TYPES.BLOCK, 
			{"block_name" = tokenWalker.current_token.value, "content" = lines(tokenWalker)})
	else:
		node = nodeFactory.create_node(nodeFactory.NODE_TYPES.RANDOM_BLOCK, 
			{"mode" = SyntaxDictionaries.random_block_types[token.name], 
			"block_name" = tokenWalker.current_token.value, "content" = lines(tokenWalker)})

	var blocks : Array[BlockNode] =  [node]
	while tokenWalker.peek(TokenArray.block) != null:
		blocks.append_array(_blocks(tokenWalker))

	return blocks


func lines(tokenWalker : TokenWalker) -> Array[ClydeNode]:

	var lines : Array[ClydeNode]
	var tk  : Token= tokenWalker.peek(TokenArray.acceptable_next)

	if tk == null:
		return []
	
	match(tk.name):
		Syntax.TOKEN_SPEAKER, Syntax.TOKEN_TEXT:
			tokenWalker.consume(TokenArray.dialogue)
			var line  : DialogueNode = DialogueNodeParser.new().dialogue_line(tokenWalker)
			if tokenWalker.peek(TokenArray.brace_open):
				tokenWalker.consume(TokenArray.brace_open)
				lines = [LogicNodeParser.new().line_with_action(tokenWalker, line)]
			else:
				lines = [line]
				
		Syntax.TOKEN_OPTION, Syntax.TOKEN_STICKY_OPTION, Syntax.TOKEN_FALLBACK_OPTION:
			lines = [DialogueNodeParser.new().options(tokenWalker)]
			
		Syntax.TOKEN_DIVERT, Syntax.TOKEN_DIVERT_PARENT:
			lines = [divert(tokenWalker)]
#			
		Syntax.TOKEN_BRACKET_OPEN:
			tokenWalker.consume(TokenArray.bracket_open)
			lines = [variations(tokenWalker)]
			
		Syntax.TOKEN_LINE_BREAK, Syntax.TOKEN_BRACE_OPEN:
			if tk.name == Syntax.TOKEN_LINE_BREAK:
				tokenWalker.consume(TokenArray.lineBreak)
				
			tokenWalker.consume(TokenArray.brace_open)
	
			if tokenWalker.peek(TokenArray.set_trigger) != null:
				lines = [LogicNodeParser.new().line_with_action(tokenWalker)]
				
			else:
				if tokenWalker.peek(TokenArray.when) != null:
					tokenWalker.consume(TokenArray.when)
				lines = [LogicNodeParser.new().conditional_line(tokenWalker)]

	if tokenWalker.peek(TokenArray.acceptable_next) != null:
		lines.append_array(lines(tokenWalker))

	return lines


func divert(tokenWalker : TokenWalker) -> ClydeNode:
	tokenWalker.consume(TokenArray.divert)
	var divertToken : Token = tokenWalker.current_token

	var node : ClydeNode
	match divertToken.name:
		Syntax.TOKEN_DIVERT:
			node = nodeFactory.create_node(NodeFactory.NODE_TYPES.DIVERT, 
				{"target" = divertToken.value})
		Syntax.TOKEN_DIVERT_PARENT:
			node = nodeFactory.create_node(NodeFactory.NODE_TYPES.DIVERT, 
				{"target" = '<parent>'})

	if tokenWalker.peek(TokenArray.lineBreak) != null:
		tokenWalker.consume(TokenArray.lineBreak)
		return node

	if tokenWalker.peek(TokenArray.eof) != null:
		return  node

	if tokenWalker.peek(TokenArray.brace_open) != null:
		tokenWalker.consume(TokenArray.brace_open)
		node = LogicNodeParser.new().line_with_action(tokenWalker,node)

	return node


func variations(tokenWalker : TokenWalker) -> VariationsNode:
	var variations : VariationsNode = nodeFactory.create_node(NodeFactory.NODE_TYPES.VARIATIONS, 
		{mode ='sequence'})

	if tokenWalker.peek(TokenArray.variations) != null:
		var mode : Token = tokenWalker.consume(TokenArray.variations)
		if !Syntax.variations_modes.has(mode.value):
			printerr("Wrong variation mode set \"%s\" checked line %s column %s. Valid modes: %s." % [
				mode.value,
				tokenWalker.current_token.line,
				tokenWalker.current_token.column,
				Syntax.variations_modes
			])
			return

		variations.mode = mode.value

	while tokenWalker.peek(TokenArray.indent_minus) != null:
		if tokenWalker.peek(TokenArray.indent) != null:
			tokenWalker.consume(TokenArray.indent)
			continue

		tokenWalker.consume(TokenArray.minus)

		var starts_next_line: bool = false
		if tokenWalker.peek(TokenArray.indent) != null:
			tokenWalker.consume(TokenArray.indent)
			starts_next_line = true


		variations.content.append(lines(tokenWalker))

		
		if starts_next_line:
			var lastVariation : Array = variations.content[variations.content.size() - 1]
			var lastContent : ClydeNode= lastVariation[lastVariation.size() - 1]
			if !(lastContent is OptionsNode):
				tokenWalker.consume(TokenArray.dedent)

		if tokenWalker.peek(TokenArray.dedent) != null:
			tokenWalker.consume(TokenArray.dedent)

	tokenWalker.consume(TokenArray.bracket_close)

	return variations
