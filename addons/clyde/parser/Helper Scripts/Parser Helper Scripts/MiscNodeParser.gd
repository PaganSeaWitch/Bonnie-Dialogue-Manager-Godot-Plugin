class_name MiscNodeParser
extends RefCounted

var nodeFactory : NodeFactory = NodeFactory.new()


const _variations_modes = ['sequence', 'once', 'cycle', 'shuffle', 'shuffle sequence', 'shuffle once', 'shuffle cycle' ]


func _document(tokenWalker : TokenWalker) -> DocumentNode:

	var next = tokenWalker.peek(TokenArray.expected)

	if next == null:
		tokenWalker._wrong_token_error(next, TokenArray.expected)
		return
	match(next.token):
		Syntax.TOKEN_EOF:
			return nodeFactory.CreateNode(nodeFactory.NODE_TYPES.DOCUMENT, {}) as DocumentNode
		Syntax.TOKEN_BLOCK:
			return nodeFactory.CreateNode(nodeFactory.NODE_TYPES.DOCUMENT,{"content"= [], "blocks"= _blocks(tokenWalker)}) as DocumentNode

	var result =  nodeFactory.CreateNode(nodeFactory.NODE_TYPES.DOCUMENT, {"content" = _lines(tokenWalker)}) as DocumentNode

	if tokenWalker.peek(TokenArray.block):
		result.blocks = _blocks(tokenWalker)

	return result


func _blocks(tokenWalker : TokenWalker) -> Array[BlockNode]:
	tokenWalker.consume(TokenArray.block)
	var blocks : Array[BlockNode] =  [
		nodeFactory.CreateNode(nodeFactory.NODE_TYPES.BLOCK, {"blockName" =tokenWalker.current_token.value, "content"= _lines(tokenWalker)}) as BlockNode]

	while tokenWalker.peek(TokenArray.block):
		blocks.append_array(_blocks(tokenWalker))

	return blocks


func _lines(tokenWalker : TokenWalker) -> Array[ClydeNode]:

	var lines : Array[ClydeNode]
	var tk = tokenWalker.peek(TokenArray.acceptable_next)

	if !tk:
		return []
	
	match(tk.token):
		Syntax.TOKEN_SPEAKER, Syntax.TOKEN_TEXT:
			tokenWalker.consume(TokenArray.dialogue)
			var line = DialogueNodeParser.new()._dialogue_line(tokenWalker)
			if tokenWalker.peek(TokenArray.braceOpen):
				tokenWalker.consume(TokenArray.braceOpen)
				lines = [LogicNodeParser.new()._line_with_action(tokenWalker, line)]
			else:
				lines = [line]
				
		Syntax.TOKEN_OPTION, Syntax.TOKEN_STICKY_OPTION, Syntax.TOKEN_FALLBACK_OPTION:
			lines = [DialogueNodeParser.new()._options(tokenWalker)]
			
		Syntax.TOKEN_DIVERT, Syntax.TOKEN_DIVERT_PARENT:
			lines = [_divert(tokenWalker)]
#			
		Syntax.TOKEN_BRACKET_OPEN:
			tokenWalker.consume(TokenArray.bracketOpen)
			lines = [_variations(tokenWalker)]
			
		Syntax.TOKEN_LINE_BREAK, Syntax.TOKEN_BRACE_OPEN:
			if tk.token == Syntax.TOKEN_LINE_BREAK:
				tokenWalker.consume(TokenArray.lineBreak)
				
			tokenWalker.consume(TokenArray.braceOpen)
	
			if tokenWalker.peek(TokenArray.setTrigger):
				lines = [LogicNodeParser.new()._line_with_action(tokenWalker)]
				
			else:
				if tokenWalker.peek(TokenArray.when):
					tokenWalker.consume(TokenArray.when)
				lines = [LogicNodeParser.new()._conditional_line(tokenWalker)]

	if tokenWalker.peek(TokenArray.acceptable_next):
		lines.append_array(_lines(tokenWalker))

	return lines


func _divert(tokenWalker : TokenWalker) -> ClydeNode:
	tokenWalker.consume(TokenArray.divert)
	var divert = tokenWalker.current_token

	var token : ClydeNode
	match divert.token:
		Syntax.TOKEN_DIVERT:
			token = nodeFactory.CreateNode(NodeFactory.NODE_TYPES.DIVERT, {"target" = divert.value})
		Syntax.TOKEN_DIVERT_PARENT:
			token = nodeFactory.CreateNode(NodeFactory.NODE_TYPES.DIVERT, {"target" = '<parent>'})

	if tokenWalker.peek(TokenArray.lineBreak):
		tokenWalker.consume(TokenArray.lineBreak)
		return token

	if tokenWalker.peek(TokenArray.eof):
		return  token

	if tokenWalker.peek(TokenArray.braceOpen):
		tokenWalker.consume(TokenArray.braceOpen)
		token = LogicNodeParser.new()._line_with_action(tokenWalker,token)

	return token


func _variations(tokenWalker : TokenWalker) -> VariationsNode:
	var variations = nodeFactory.CreateNode(NodeFactory.NODE_TYPES.VARIATIONS, {mode ='sequence'}) as VariationsNode

	if tokenWalker.peek(TokenArray.variations):
		var mode = tokenWalker.consume(TokenArray.variations)
		if !_variations_modes.has(mode.value):
			printerr("Wrong variation mode set \"%s\" checked line %s column %s. Valid modes: %s." % [
				mode.value,
				tokenWalker.current_token.line,
				tokenWalker.current_token.column,
				_variations_modes
			])
			return

		variations.mode = mode.value

	while tokenWalker.peek(TokenArray.indentMinus):
		if tokenWalker.peek(TokenArray.indent):
			tokenWalker.consume(TokenArray.indent)
			continue

		tokenWalker.consume(TokenArray.minus)

		var starts_next_line = false
		if tokenWalker.peek(TokenArray.indent):
			tokenWalker.consume(TokenArray.indent)
			starts_next_line = true


		variations.content.append(NodeFactory.new().CreateNode(NodeFactory.NODE_TYPES.CONTENT, {"content" = _lines(tokenWalker)}))
		if starts_next_line:
			var lastVariation = variations.content[variations.content.size() - 1].content
			var lastContent = lastVariation[lastVariation.size() - 1]
			if !(lastContent is OptionsNode):
				tokenWalker.consume(TokenArray.dedent)

		if tokenWalker.peek(TokenArray.dedent):
			tokenWalker.consume(TokenArray.dedent)

	tokenWalker.consume(TokenArray.bracketClose)

	return variations
