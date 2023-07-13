class_name LogicLexer
extends MiscLexer

# Consume brace open and start logic mode
func handle_logic_block_start() -> Array[Token]:
	lexer.stack_mode(Syntax.MODE_LOGIC)
	return handle_logic_block_stop_and_start(Syntax.TOKEN_PLACEMENT_INDEPENENT_OPEN)


# Consume brace close and end logic mode
func handle_logic_block_stop()-> Array[Token]:
	lexer.pop_mode()
	return handle_logic_block_stop_and_start(Syntax.TOKEN_PLACEMENT_INDEPENENT_CLOSE)


# Consume brace and return brace with linebreak if exists
func handle_logic_block_stop_and_start(syntax_token : String) -> Array[Token]:
	var setup_dict : Dictionary = LexerHelperFunctions.internal_setup(lexer)
	LexerHelperFunctions.increase_lexer_position(lexer)
	var token : Token = Token.new(syntax_token, 
		lexer.line, setup_dict["initial_column"])
	var linebreak : Token = null
	
	if(syntax_token == Syntax.TOKEN_PLACEMENT_INDEPENENT_CLOSE) && lexer.line != lexer.line_in_parts:
		linebreak = LexerHelperFunctions.get_following_line_break(lexer.input,
			lexer.line, lexer.column, lexer.position)
	
	if((syntax_token == Syntax.TOKEN_PLACEMENT_INDEPENENT_OPEN) 
	&& lexer.line != lexer.line_in_parts):
		if(lexer.added_space):
			lexer.added_space = false
		else:
			linebreak = LexerHelperFunctions.get_leading_line_break(lexer.input,
				lexer.line, lexer.position)
	
	if linebreak != null:
		if (syntax_token == Syntax.TOKEN_PLACEMENT_INDEPENENT_CLOSE):
			return [ token, linebreak ] 
		return [ linebreak, token ] 
	return [token]


# Consume logic, can return nothing
func handle_logic_block() -> Array[Token]:
	if (lexer.input[lexer.position] == '"' 
	|| lexer.input[lexer.position] == "'"):
		if lexer.current_quote.is_empty():
			lexer.current_quote = lexer.input[lexer.position]
		return handle_logic_string()

	if lexer.input.substr(lexer.position, 2) == '}]':
		return lexer.dependent_logic_lexer.handle_dependent_logic_block_stop()

	# Rule : if } in logic block, end logic block
	if lexer.input[lexer.position] == '}':
		return handle_logic_block_stop()
	

	
	# Rule : if number in logic block, return number
	if lexer.input[lexer.position].is_valid_int():
		return handle_logic_number()
	
	# Rule : if a logic operatior in logic block, return it
	for i in range(SyntaxDictionaries.MAX_VALUE_LENGTH, 0, -1):
		if(SyntaxDictionaries.logic_symbol_tokens_operators_with_side_effects.has(
		lexer.input.substr(lexer.position,i).to_lower())):
			var token_dict : Dictionary = (SyntaxDictionaries.
				logic_symbol_tokens_operators_with_side_effects.get(
				lexer.input.substr(lexer.position,i)))
			return handle_logic_operator(token_dict["token"], token_dict["length"])
			
		if(SyntaxDictionaries.logic_symbol_tokens_side_operator_without_side_effects.has(
		lexer.input.substr(lexer.position,i).to_lower())):
			var token_dict : Dictionary = (SyntaxDictionaries.
				logic_symbol_tokens_side_operator_without_side_effects.get(
				lexer.input.substr(lexer.position,i)))
			return [LexerHelperFunctions.create_simple_token(lexer, 
				token_dict["token"], token_dict["length"], token_dict["length"])]
	
	# Rule : if ! in logic block, consume logic not
	
	if lexer.input[lexer.position] == '!':
		return handle_logic_not()
	
	var identifier : RegEx = RegEx.new()
	if(lexer.is_current_mode(Syntax.MODE_BLOCK_REQ)):
		identifier.compile("[A-Z|a-z|0-9|_|.]")
	else:
		identifier.compile("[A-Z|a-z|@|_|.]")
	if identifier.search(lexer.input[lexer.position]) != null:
		return handle_logic_identifier()
	return []


# Consume logic identifier
func handle_logic_identifier() -> Array[Token]:
	var setup_dict : Dictionary= LexerHelperFunctions.internal_setup(lexer)
	
	# Get logic identifier
	if(lexer.is_current_mode(Syntax.MODE_BLOCK_REQ)):
		while  (LexerHelperFunctions.is_valid_position(lexer.input, lexer.position) 
		&& LexerHelperFunctions.is_block_identifier(lexer.input[lexer.position])):
			setup_dict["values"] += lexer.input[lexer.position]
			LexerHelperFunctions.increase_lexer_position(lexer)
	else:
		while (LexerHelperFunctions.is_valid_position(lexer.input, lexer.position) 
		&& LexerHelperFunctions.is_identifier(lexer.input[lexer.position])):
			setup_dict["values"] += lexer.input[lexer.position]
			LexerHelperFunctions.increase_lexer_position(lexer)

	if(setup_dict["values"].strip_edges() != ""):
		# Rule : if logic identifier is descriptive operator, consume it as that
		if Syntax.keywords.has(setup_dict["values"].to_lower()):
			return handle_logic_descriptive_operator( 
				setup_dict["values"].to_lower(), setup_dict["initial_column"])
		return [Token.new(Syntax.TOKEN_IDENTIFIER, lexer.line, 
			setup_dict["initial_column"], setup_dict["values"].strip_edges())]
	return []


# Consume logic descriptive operator
func handle_logic_descriptive_operator(value : String, initial_column : int) -> Array[Token]:
	if(SyntaxDictionaries.logic_descriptive_tokens.has(value)):
		
		# Rule : if operator is boolean, return its value as well
		if(value == 'true' || value == 'false'):
			return [Token.new(SyntaxDictionaries.logic_descriptive_tokens.get(value), 
				lexer.line, initial_column,value)]
		return [Token.new(SyntaxDictionaries.logic_descriptive_tokens.get(value),
			lexer.line, initial_column)]
	return []


# Consume logical not
func handle_logic_not() -> Array[Token]:
	var setup_dict : Dictionary = LexerHelperFunctions.internal_setup(lexer)
	
	# move past !
	LexerHelperFunctions.increase_lexer_position(lexer)
	return [Token.new(Syntax.TOKEN_NOT, lexer.line, setup_dict["initial_column"])]


# Consume logic operator
func handle_logic_operator(tokenName : String,
length: int) -> Array[Token]:
	var setup_dict : Dictionary = LexerHelperFunctions.internal_setup(lexer)
	
	# move past operator
	LexerHelperFunctions.increase_lexer_position(lexer, length, length)
	return [Token.new(tokenName, lexer.line, setup_dict["initial_column"])]


# Consume number
func handle_logic_number() -> Array[Token]:
	var setup_dict : Dictionary = LexerHelperFunctions.internal_setup(lexer)

	# Get Number
	while (LexerHelperFunctions.is_valid_position(lexer.input, lexer.position) 
	&& (lexer.input[lexer.position] == '.' # Decimal case
	|| lexer.input[lexer.position].is_valid_int())): # numerical case
		setup_dict["values"] += lexer.input[lexer.position]
		LexerHelperFunctions.increase_lexer_position(lexer)

	return [Token.new(Syntax.TOKEN_NUMBER_LITERAL, lexer.line, 
		setup_dict["initial_column"], setup_dict["values"])]


# Consume String
func handle_logic_string() -> Array[Token]:
	var setup_dict : Dictionary = LexerHelperFunctions.internal_setup(lexer)
	LexerHelperFunctions.increase_lexer_position(lexer)
	
	# Get text until end of quote
	var tokens : Array[Token]= lexer.line_lexer.handle_qtext()
	LexerHelperFunctions.increase_lexer_position(lexer)

	tokens[0].name = Syntax.TOKEN_STRING_LITERAL
	tokens[0].column = setup_dict["initial_column"]

	return tokens
