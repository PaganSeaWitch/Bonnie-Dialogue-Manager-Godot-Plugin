class_name MiscParser
extends RefCounted

var node_factory : NodeFactory
var token_walker : TokenWalker
var parser : BonnieParser


func init(_parser : BonnieParser, _token_walker : TokenWalker):
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

		Syntax.TOKEN_BLOCK, Syntax.TOKEN_RANDOM_BLOCK, Syntax.TOKEN_KEYWORD_BLOCK_REQ:
			return node_factory.create_node(node_factory.NODE_TYPES.DOCUMENT,
				{"content"= [], "blocks"= _blocks()})
		
		Syntax.TOKEN_RANDOM_FALLBACK_BLOCK, Syntax.TOKEN_RANDOM_STICKY_BLOCK:
			return node_factory.create_node(node_factory.NODE_TYPES.DOCUMENT,
				{"content"= [], "blocks"= _blocks()})

	var result =  node_factory.create_node(node_factory.NODE_TYPES.DOCUMENT, 
		{"content" = lines()})

	if token_walker.peek(TokenArray.blocks_and_reqs):
		result.blocks = _blocks()

	return result


func _block_with_requirements() -> BlockNode:
	token_walker.consume(TokenArray.block_req)
	var req_block_names : Array[String] = []
	var req_not_block_names : Array[String] = []
	var condtions : Array[NamedNode] = []
	var next_token : Token = token_walker.peek(TokenArray.acceptable_req)
	if next_token == null:
		token_walker._wrong_token_error(next_token, TokenArray.acceptable_req)
		return null
	var getting_req = true

	while(getting_req):
		getting_req = false
		match (next_token.name):
			Syntax.TOKEN_IDENTIFIER:
				req_block_names.append(next_token.value)
				token_walker.consume(TokenArray.acceptable_req)
				
			Syntax.TOKEN_NOT:
				token_walker.consume(TokenArray.logical_not)
				var token = token_walker.consume(TokenArray.identifier)
				req_not_block_names.append(token.value)

			
			Syntax.TOKEN_PLACEMENT_INDEPENENT_OPEN:
				token_walker.consume(TokenArray.logic_open)
				if token_walker.peek(TokenArray.when) != null:
					token_walker.consume(TokenArray.when)
				condtions.append(parser.logic_parser._condition())
		
		if(token_walker.peek(TokenArray.comma)):
			token_walker.consume(TokenArray.comma)
			getting_req = true
		if(token_walker.peek(TokenArray.lineBreak)):
			token_walker.consume(TokenArray.lineBreak)

		if(token_walker.peek(TokenArray.block_req)):
			token_walker.consume(TokenArray.block_req)
			getting_req = true

		next_token = token_walker.peek(TokenArray.acceptable_req)
		if next_token == null && getting_req:
			token_walker._wrong_token_error(next_token, TokenArray.acceptable_req)
			return null
		
	var block : BlockNode = _get_block();
	if(block is RandomBlockNode):
		if(block.mode == "fallback"):
			assert(false,"tried to put requirement on fallback block!")
			return null
	block.block_requirements = req_block_names
	block.conditions = condtions
	block.block_not_requirements = req_not_block_names
	return block


func _get_block() -> BlockNode:
	var token : Token = token_walker.consume(TokenArray.block_types)
	var node = BlockNode

	if(token.name == Syntax.TOKEN_BLOCK):
		node = node_factory.create_node(node_factory.NODE_TYPES.BLOCK, 
			{"block_name" = token_walker.current_token.value, "content" = lines()})
	else:
		node = node_factory.create_node(node_factory.NODE_TYPES.RANDOM_BLOCK, 
			{"mode" = SyntaxDictionaries.random_block_types[token.name], 
			"block_name" = token_walker.current_token.value, "content" = lines()})
	
	return node


func _blocks() -> Array[BlockNode]:
	var blocks : Array[BlockNode] = []

	while token_walker.peek(TokenArray.blocks_and_reqs) != null:
		if(token_walker.peek(TokenArray.block_req)):
			blocks.append(_block_with_requirements())
		else:
			blocks.append(_get_block())

	return blocks


func lines() -> Array[BonnieNode]:

	var lines : Array[BonnieNode]
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
			elif (token_walker.peek(TokenArray.bb_code_open)):
				token_walker.consume(TokenArray.bb_code_open)
				lines = [parser.bb_code_parser.line_part_with_bb_code(line)]
			else:
				lines = [line]
				
		Syntax.TOKEN_OPTION, Syntax.TOKEN_STICKY_OPTION, Syntax.TOKEN_FALLBACK_OPTION:
			lines = [parser.options_parser.options()]
			
		Syntax.TOKEN_DIVERT, Syntax.TOKEN_DIVERT_PARENT:
			lines = [divert()]
			
		Syntax.TOKEN_BEGINNING_BB_CODE_OPEN, Syntax.TOKEN_ENDING_BB_CODE_OPEN:
			token_walker.consume(TokenArray.bb_code_open)
			lines = [parser.bb_code_parser.line_part_with_bb_code()]
		
		
		Syntax.TOKEN_BRACKET_OPEN:
			token_walker.consume(TokenArray.bracket_open)
			lines = [parser.variations_parser.variations()]
			
		Syntax.TOKEN_LINE_BREAK:
			token_walker.consume(TokenArray.lineBreak)

		Syntax.TOKEN_PLACEMENT_INDEPENENT_OPEN:
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


func divert() -> BonnieNode:
	token_walker.consume(TokenArray.divert)
	var divertToken : Token = token_walker.current_token

	var node : BonnieNode
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



