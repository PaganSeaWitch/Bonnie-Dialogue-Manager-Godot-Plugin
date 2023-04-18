class_name OptionLexer
extends MiscLexer


# Consume option at lexer position, start option mode
func handle_options() -> Array[Token]:
	var tokenName : String
	match lexer.input[lexer.position]:
		'*':
			tokenName = Syntax.TOKEN_OPTION
		'+':
			tokenName = Syntax.TOKEN_STICKY_OPTION
		'>':
			tokenName = Syntax.TOKEN_FALLBACK_OPTION
	
	var setup_dict : Dictionary = LexerHelperFunctions.internal_setup(lexer)
	LexerHelperFunctions.increase_lexer_position(lexer)
	lexer.stack_mode(Syntax.MODE_OPTION)
	return [Token.new(tokenName, lexer.line, setup_dict["initial_column"])]


# Consume assign at lexer position
func handle_option_display_char() -> Array[Token]:
	var setup_dict : Dictionary = LexerHelperFunctions.internal_setup(lexer)
	LexerHelperFunctions.increase_lexer_position(lexer)
	return [Token.new(Syntax.TOKEN_ASSIGN, lexer.line, setup_dict["initial_column"])]
