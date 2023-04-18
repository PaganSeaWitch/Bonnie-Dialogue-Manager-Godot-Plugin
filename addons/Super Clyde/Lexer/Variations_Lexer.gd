class_name VariationsLexer
extends MiscLexer


# Consume Bracket open and variations mode if no value and start varaitons mode
func handle_start_variations() -> Array[Token]:
	var setup_dict : Dictionary = LexerHelperFunctions.internal_setup(lexer)
	LexerHelperFunctions.increase_lexer_position(lexer)
	lexer.stack_mode(Syntax.MODE_VARIATIONS)

	var identifier : RegEx = RegEx.new()
	identifier.compile("[A-Z|a-z| ]")

	while (LexerHelperFunctions.is_valid_position(lexer.input, lexer.position) 
	&& identifier.search(lexer.input[lexer.position]) != null):
		setup_dict["values"] += lexer.input[lexer.position]
		LexerHelperFunctions.increase_lexer_position(lexer)

	var tokens : Array[Token]= [Token.new(Syntax.TOKEN_BRACKET_OPEN,
			lexer.line, setup_dict["initial_column"])]

	var value = setup_dict["values"].strip_edges()

	if value.length() > 0:
		tokens.push_back(Token.new(Syntax.TOKEN_VARIATIONS_MODE, lexer.line, 
			setup_dict["initial_column"] + 2, value))

	return tokens


# Consume and return bracket close
func handle_stop_variations() -> Array[Token]:
	var setup_dict : Dictionary = LexerHelperFunctions.internal_setup(lexer)
	LexerHelperFunctions.increase_lexer_position(lexer)
	lexer.pop_mode()
	return [Token.new(Syntax.TOKEN_BRACKET_CLOSE, 
		lexer.line, setup_dict["initial_column"])]


# Consume variation item as a minus token
# This will be used correctly due to previous variations mode token
func handle_variation_item() -> Array[Token]:
	var setup_dict : Dictionary = LexerHelperFunctions.internal_setup(lexer)
	LexerHelperFunctions.increase_lexer_position(lexer)
	return [Token.new(Syntax.TOKEN_MINUS, 
		lexer.line, setup_dict["initial_column"])]
