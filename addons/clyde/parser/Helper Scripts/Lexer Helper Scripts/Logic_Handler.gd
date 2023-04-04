class_name LogicHandler
extends RefCounted

# Consume brace open and start logic mode
func handle_logic_block_start(lexer : Lexer) -> Array[Token]:
	lexer.stack_mode(Syntax.MODE_LOGIC)
	return handle_logic_block_stop_and_start(lexer, Syntax.TOKEN_BRACE_OPEN)


# Consume brace close and end logic mode
func handle_logic_block_stop(lexer : Lexer)-> Array[Token]:
	lexer.pop_mode()
	return handle_logic_block_stop_and_start(lexer, Syntax.TOKEN_BRACE_CLOSE)


# Consume brace and return brace with linebreak if exists
func handle_logic_block_stop_and_start(lexer : Lexer,
syntax_token : String) -> Array[Token]:
	var setup_dict : Dictionary = MiscLexerFunctions.internal_setup(lexer)
	MiscLexerFunctions.increase_lexer_position(lexer)
	var token : Token = Token.new(syntax_token, 
		lexer.line, setup_dict["initial_column"])
	var linebreak : Token = null
	
	if(syntax_token == Syntax.TOKEN_BRACE_CLOSE):
		linebreak = MiscLexerFunctions.get_following_line_break(lexer.input,
			lexer.line, lexer.column, lexer.position)
	
	if(syntax_token == Syntax.TOKEN_BRACE_OPEN):
		linebreak = MiscLexerFunctions.get_leading_line_break(lexer.input,
			lexer.line, lexer.position)
	
	if linebreak != null:
		if (syntax_token == Syntax.TOKEN_BRACE_CLOSE):
			return [ token, linebreak ] 
		return [ linebreak, token ] 
	return [token]


# Consume logic, can return nothing
func handle_logic_block(lexer : Lexer) -> Array[Token]:
	if (lexer.input[lexer.position] == '"' 
	|| lexer.input[lexer.position] == "'"):
		if lexer._current_quote.is_empty():
			lexer._current_quote = lexer.input[lexer.position]
		return handle_logic_string(lexer)
	
	# Rule : if } in logic block, end logic block
	if lexer.input[lexer.position] == '}':
		return handle_logic_block_stop(lexer)
	
	# Rule : if number in logic block, return number
	if lexer.input[lexer.position].is_valid_int():
		return handle_logic_number(lexer)
	
	# Rule : if a logic operatior in logic block, return it
	for i in range(SyntaxDictionaries.MAX_VALUE_LENGTH, 0, -1):
		if(SyntaxDictionaries.logic_symbol_tokens_operators_with_side_effects.has(
		lexer.input.substr(lexer.position,i).to_lower())):
			var token_dict : Dictionary = (SyntaxDictionaries.
				logic_symbol_tokens_operators_with_side_effects.get(
				lexer.input.substr(lexer.position,i)))
			return handle_logic_operator(lexer, token_dict["token"], token_dict["length"])
			
		if(SyntaxDictionaries.logic_symbol_tokens_side_operator_without_side_effects.has(
		lexer.input.substr(lexer.position,i).to_lower())):
			var token_dict : Dictionary = (SyntaxDictionaries.
				logic_symbol_tokens_side_operator_without_side_effects.get(
				lexer.input.substr(lexer.position,i)))
			return [MiscLexerFunctions.create_simple_token(lexer, 
				token_dict["token"], token_dict["length"])]
	
	# Rule : if ! in logic block, consume logic not
	
	if lexer.input[lexer.position] == '!':
		return handle_logic_not(lexer)
	
	var identifier : RegEx = RegEx.new()
	identifier.compile("[A-Z|a-z]")
	if identifier.search(lexer.input[lexer.position]) != null:
		return handle_logic_identifier(lexer)
	return []


# Consume logic identifier
func handle_logic_identifier(lexer : Lexer) -> Array[Token]:
	var setup_dict : Dictionary= MiscLexerFunctions.internal_setup(lexer)
	
	# Get logic identifier
	while (MiscLexerFunctions.is_valid_position(lexer.input, lexer.position) 
	&& MiscLexerFunctions.is_identifier(lexer.input[lexer.position])):
		setup_dict["values"] += lexer.input[lexer.position]
		MiscLexerFunctions.increase_lexer_position(lexer)

	# Rule : if logic identifier is descriptive operator, consume it as that
	if Syntax.keywords.has(setup_dict["values"].to_lower()):
		return handle_logic_descriptive_operator(lexer, 
			setup_dict["values"].to_lower(), setup_dict["initial_column"])
	return [Token.new(Syntax.TOKEN_IDENTIFIER, lexer.line, 
		setup_dict["initial_column"], setup_dict["values"].strip_edges())]


# Consume logic descriptive operator
func handle_logic_descriptive_operator(lexer : Lexer, 
value : String, initial_column : int) -> Array[Token]:
	if(SyntaxDictionaries.logic_descriptive_tokens.has(value)):
		
		# Rule : if operator is boolean, return its value as well
		if(value == 'true' || value == 'false'):
			return [Token.new(SyntaxDictionaries.logic_descriptive_tokens.get(value), 
				lexer.line, initial_column,value)]
		return [Token.new(SyntaxDictionaries.logic_descriptive_tokens.get(value),
			lexer.line, initial_column)]
	return []


# Consume logical not
func handle_logic_not(lexer : Lexer) -> Array[Token]:
	var setup_dict : Dictionary = MiscLexerFunctions._internal_setup(lexer)
	
	#move past !
	MiscLexerFunctions._increase_lexer_position(lexer)
	return [Token.new(Syntax.TOKEN_NOT, lexer.line, setup_dict["initial_column"])]


# Consume logic operator
func handle_logic_operator(lexer : Lexer, tokenName : String,
length: int) -> Array[Token]:
	var setup_dict : Dictionary = MiscLexerFunctions.internal_setup(lexer)
	
	# move past operator
	MiscLexerFunctions.increase_lexer_position(lexer, length, length)
	return [Token.new(tokenName, lexer.line, setup_dict["initial_column"])]


# Consume number
func handle_logic_number(lexer : Lexer) -> Array[Token]:
	var setup_dict : Dictionary = MiscLexerFunctions.internal_setup(lexer)

	# Get Number
	while (MiscLexerFunctions.is_valid_position(lexer.input, lexer.position) 
	&& (lexer.input[lexer.position] == '.' # Decimal case
	|| lexer.input[lexer.position].is_valid_int())): # numerical case
		setup_dict["values"] += lexer.input[lexer.position]
		MiscLexerFunctions.increase_lexer_position(lexer)

	return [Token.new(Syntax.TOKEN_NUMBER_LITERAL, lexer.line, 
		setup_dict["initial_column"], setup_dict["values"])]


# Consume String
func handle_logic_string(lexer : Lexer) -> Array[Token]:
	var setup_dict : Dictionary = MiscLexerFunctions.internal_setup(lexer)
	MiscLexerFunctions.increase_lexer_position(lexer)
	
	# Get text until end of quote
	var tokens : Array[Token]= LineHandler.new().handle_qtext(lexer)
	MiscLexerFunctions.increase_lexer_position(lexer)

	tokens[0].name = Syntax.TOKEN_STRING_LITERAL
	tokens[0].column = setup_dict["initial_column"]

	return tokens
