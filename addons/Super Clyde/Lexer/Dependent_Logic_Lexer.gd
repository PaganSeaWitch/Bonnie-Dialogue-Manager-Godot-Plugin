class_name DependentLogicLexer
extends MiscLexer

# Consume brace open and start logic mode
func handle_dependent_logic_block_start() -> Array[Token]:
	lexer.stack_mode(Syntax.MODE_LOGIC)
	return handle_dependent_logic_block_stop_and_start(Syntax.TOKEN_PLACEMENT_DEPENENT_OPEN)


# Consume brace close and end logic mode
func handle_dependent_logic_block_stop()-> Array[Token]:
	lexer.pop_mode()
	return handle_dependent_logic_block_stop_and_start(Syntax.TOKEN_PLACEMENT_DEPENENT_CLOSE)


# Consume brace and return brace with linebreak if exists
func handle_dependent_logic_block_stop_and_start(syntax_token : String) -> Array[Token]:
	var setup_dict : Dictionary = LexerHelperFunctions.internal_setup(lexer)
	LexerHelperFunctions.increase_lexer_position(lexer, 2)
	
	var token : Token = Token.new(syntax_token, 
		lexer.line, setup_dict["initial_column"])
	
	lexer.line_in_parts = lexer.line

	return [token]

