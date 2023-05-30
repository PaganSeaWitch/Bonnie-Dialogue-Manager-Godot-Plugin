class_name MiscParser
extends RefCounted

var node_factory : NodeFactory
var token_walker : TokenWalker
var parser : Parser


func init(_parser : Parser, _token_walker : TokenWalker):
	token_walker = _token_walker
	parser = _parser
	node_factory = NodeFactory.new()


func document() -> DocumentNode:

	var nextToken : Token = token_walker.peek(TokenArray.expected)

	if nextToken == null:
		token_walker._wrong_token_error(nextToken, TokenArray.expected)
		return
	match(nextToken.name):
		Syntax.TOKEN_EOF:
			return node_factory.create_node(node_factory.NODE_TYPES.DOCUMENT, {})
		
		Syntax.TOKEN_BLOCK, Syntax.TOKEN_RANDOM_BLOCK:
			return node_factory.create_node(node_factory.NODE_TYPES.DOCUMENT,
				{"content"= [], "blocks"= _blocks()})
		
		Syntax.TOKEN_RANDOM_FALLBACK_BLOCK, Syntax.TOKEN_RANDOM_STICKY_BLOCK:
			return node_factory.create_node(node_factory.NODE_TYPES.DOCUMENT,
				{"content"= [], "blocks"= _blocks()})

	var result =  node_factory.create_node(node_factory.NODE_TYPES.DOCUMENT, 
		{"content" = lines()})

	if token_walker.peek(TokenArray.block_types):
		result.blocks = _blocks()

	return result


func _blocks() -> Array[BlockNode]:
	var token : Token = token_walker.consume(TokenArray.block_types)
	var node = BlockNode

	if(token.name == Syntax.TOKEN_BLOCK):
		node = node_factory.create_node(node_factory.NODE_TYPES.BLOCK, 
			{"block_name" = token_walker.current_token.value, "content" = lines()})
	else:
		node = node_factory.create_node(node_factory.NODE_TYPES.RANDOM_BLOCK, 
			{"mode" = SyntaxDictionaries.random_block_types[token.name], 
			"block_name" = token_walker.current_token.value, "content" = lines()})

	var blocks : Array[BlockNode] =  [node]
	while token_walker.peek(TokenArray.block) != null:
		blocks.append_array(_blocks())

	return blocks


func lines() -> Array[ClydeNode]:

	var lines : Array[ClydeNode]
	var tk  : Token= token_walker.peek(TokenArray.acceptable_next)

	if tk == null:
		return []
	
	match(tk.name):
		Syntax.TOKEN_SPEAKER, Syntax.TOKEN_TEXT:
			token_walker.consume(TokenArray.dialogue)
			var line  : DialogueNode = parser.line_parser.dialogue_line()
			
			if token_walker.peek(TokenArray.curly_brace_open):
				token_walker.consume(TokenArray.curly_brace_open)
				lines = [parser.logic_parser.line_with_action(line)]
			
			elif token_walker.peek(TokenArray.brace_open):
				token_walker.consume(TokenArray.brace_open)
				lines = [parser.dependent_parser.line_part_with_action(line)]
			else:
				lines = [line]
				
		Syntax.TOKEN_OPTION, Syntax.TOKEN_STICKY_OPTION, Syntax.TOKEN_FALLBACK_OPTION:
			lines = [parser.options_parser.options()]
			
		Syntax.TOKEN_DIVERT, Syntax.TOKEN_DIVERT_PARENT:
			lines = [divert()]
#			
		Syntax.TOKEN_BRACKET_OPEN:
			token_walker.consume(TokenArray.bracket_open)
			lines = [parser.variations_parser.variations()]
			
		Syntax.TOKEN_LINE_BREAK, Syntax.TOKEN_PLACEMENT_INDEPENENT_OPEN:
			if tk.name == Syntax.TOKEN_LINE_BREAK:
				token_walker.consume(TokenArray.lineBreak)
				
			token_walker.consume(TokenArray.curly_brace_open)
	
			if token_walker.peek(TokenArray.set_trigger) != null:
				lines = [parser.logic_parser.line_with_action()]
				
			else:
				if token_walker.peek(TokenArray.when) != null:
					token_walker.consume(TokenArray.when)
				lines = [parser.logic_parser.conditional_line()]
		Syntax.TOKEN_PLACEMENT_DEPENENT_OPEN:
			token_walker.consume(TokenArray.brace_open)
			lines = [parser.dependent_parser.line_part_with_action()]
	
	if token_walker.peek(TokenArray.acceptable_next) != null:
		lines.append_array(lines())

	return lines


func divert() -> ClydeNode:
	token_walker.consume(TokenArray.divert)
	var divertToken : Token = token_walker.current_token

	var node : ClydeNode
	match divertToken.name:
		Syntax.TOKEN_DIVERT:
			node = node_factory.create_node(node_factory.NODE_TYPES.DIVERT, 
				{"target" = divertToken.value})
		Syntax.TOKEN_DIVERT_PARENT:
			node = node_factory.create_node(node_factory.NODE_TYPES.DIVERT, 
				{"target" = '<parent>'})

	if token_walker.peek(TokenArray.lineBreak) != null:
		token_walker.consume(TokenArray.lineBreak)
		return node

	if token_walker.peek(TokenArray.eof) != null:
		return  node

	if token_walker.peek(TokenArray.curly_brace_open) != null:
		token_walker.consume(TokenArray.curly_brace_open)
		node = parser.logic_parser.line_with_action(node)

	return node



