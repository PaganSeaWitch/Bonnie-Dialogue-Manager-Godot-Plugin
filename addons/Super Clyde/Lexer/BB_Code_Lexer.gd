class_name BBCodelexer
extends MiscLexer

# Consume brace open and start logic mode
func handle_BB_block_start(token :String) -> Array[Token]:
	lexer.stack_mode(Syntax.MODE_BB_CODE)
	return handle_BB_block_stop_and_start(token)


# Consume brace close and end logic mode
func handle_BB_block_stop()-> Array[Token]:
	lexer.pop_mode()
	return handle_BB_block_stop_and_start(Syntax.TOKEN_BB_CODE_CLOSE)
 

func handle_BB_block_stop_and_start(syntax_token : String) -> Array[Token]:
	var setup_dict : Dictionary = LexerHelperFunctions.internal_setup(lexer)
	LexerHelperFunctions.increase_lexer_position(lexer, syntax_token.length())
	
	var token : Token = Token.new(syntax_token, 
		lexer.line, setup_dict["initial_column"])
	

	return [token]

func handle_BB_block() -> Array[Token]:
	var setup_dict : Dictionary = LexerHelperFunctions.internal_setup(lexer)
	lexer.line_in_parts = lexer.line
	while lexer.position < lexer.input.length():
		var current_char : String = lexer.input[lexer.position]

		if current_char == ']':
			var token : Token = Token.new(Syntax.TOKEN_BB_CODE, lexer.line, setup_dict["initial_column"], setup_dict["values"].strip_edges())
			var array : Array[Token]  = [token]
			array.append_array(handle_BB_block_stop())
			return array
		setup_dict["values"] += current_char
		LexerHelperFunctions.increase_lexer_position(lexer)

	return []
