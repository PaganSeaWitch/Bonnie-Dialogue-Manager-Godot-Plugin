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
	LexerHelperFunctions.increase_lexer_position(lexer)
	var token : Token = Token.new(syntax_token, 
		lexer.line, setup_dict["initial_column"])
	var linebreak : Token = null
	
	if(syntax_token == Syntax.TOKEN_PLACEMENT_DEPENENT_CLOSE):
		linebreak = LexerHelperFunctions.get_following_line_break(lexer.input,
			lexer.line, lexer.column, lexer.position)
	
	if(syntax_token == Syntax.TOKEN_PLACEMENT_DEPENENT_OPEN):
		linebreak = LexerHelperFunctions.get_leading_line_break(lexer.input,
			lexer.line, lexer.position)
	
	if linebreak != null:
		if (syntax_token == Syntax.TOKEN_PLACEMENT_DEPENENT_CLOSE):
			return [ token, linebreak ] 
		return [ linebreak, token ] 
	return [token]


func handle_dependent_logic_block():
	if (lexer.input[lexer.position] == '"' 
	|| lexer.input[lexer.position] == "'"):
		if lexer.current_quote.is_empty():
			lexer.current_quote = lexer.input[lexer.position]
		return lexer.logic_lexer.handle_logic_string()
	
	# Rule : if } in logic block, end logic block
	if lexer.input[lexer.position] == ']':
		return handle_dependent_logic_block_stop()
	
	# Rule : if number in logic block, return number
	if lexer.input[lexer.position].is_valid_int():
		return lexer.logic_lexer.handle_logic_number()
	
	# Rule : if a logic operatior in logic block, return it
	for i in range(SyntaxDictionaries.MAX_VALUE_LENGTH, 0, -1):
		if(SyntaxDictionaries.logic_symbol_tokens_operators_with_side_effects.has(
		lexer.input.substr(lexer.position,i).to_lower())):
			var token_dict : Dictionary = (SyntaxDictionaries.
				logic_symbol_tokens_operators_with_side_effects.get(
				lexer.input.substr(lexer.position,i)))
			return lexer.logic_lexer.handle_logic_operator(token_dict["token"], token_dict["length"])
			
		if(SyntaxDictionaries.logic_symbol_tokens_side_operator_without_side_effects.has(
		lexer.input.substr(lexer.position,i).to_lower())):
			var token_dict : Dictionary = (SyntaxDictionaries.
				logic_symbol_tokens_side_operator_without_side_effects.get(
				lexer.input.substr(lexer.position,i)))
			return [LexerHelperFunctions.create_simple_token(lexer, 
				token_dict["token"], token_dict["length"], token_dict["length"])]
	
	# Rule : if ! in logic block, consume logic not
	
	if lexer.input[lexer.position] == '!':
		return lexer.logic_lexer.handle_logic_not()
	
	var identifier : RegEx = RegEx.new()
	identifier.compile("[A-Z|a-z]")
	if identifier.search(lexer.input[lexer.position]) != null:
		return lexer.logic_lexer.handle_logic_identifier()
	return []
