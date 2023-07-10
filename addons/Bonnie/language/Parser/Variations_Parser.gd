class_name VariationsParser
extends MiscParser


func variations() -> VariationsNode:
	var variations : VariationsNode = node_factory.create_node(node_factory.NODE_TYPES.VARIATIONS, 
		{mode ='sequence'})

	if token_walker.peek(TokenArray.variations) != null:
		var mode : Token = token_walker.consume(TokenArray.variations)
		if !Syntax.variations_modes.has(mode.value):
			printerr("Wrong variation mode set \"%s\" checked line %s column %s. Valid modes: %s." % [
				mode.value,
				token_walker.current_token.line,
				token_walker.current_token.column,
				Syntax.variations_modes
			])
			return

		variations.mode = mode.value

	while token_walker.peek(TokenArray.indent_minus) != null:
		if token_walker.peek(TokenArray.indent) != null:
			token_walker.consume(TokenArray.indent)
			continue

		token_walker.consume(TokenArray.minus)

		var starts_next_line: bool = false
		if token_walker.peek(TokenArray.indent) != null:
			token_walker.consume(TokenArray.indent)
			starts_next_line = true


		variations.content.append(lines())

		
		if starts_next_line:
			var lastVariation : Array = variations.content[variations.content.size() - 1]
			var lastContent : BonnieNode= lastVariation[lastVariation.size() - 1]
			if !(lastContent is OptionsNode):
				token_walker.consume(TokenArray.dedent)

		if token_walker.peek(TokenArray.dedent) != null:
			token_walker.consume(TokenArray.dedent)
	if(token_walker.peek(TokenArray.lineBreak)):
		token_walker.consume(TokenArray.lineBreak)
	
	token_walker.consume(TokenArray.bracket_close)

	return variations
