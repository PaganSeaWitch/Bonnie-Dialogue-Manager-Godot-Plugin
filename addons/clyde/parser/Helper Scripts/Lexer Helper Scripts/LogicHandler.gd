class_name LogicHandler
extends RefCounted


func _handle_logic_block_start(lexer : Lexer) -> Array[Token]:
	lexer._stack_mode(Syntax.MODE_LOGIC)
	return _handle_logic_block_stop_and_start(lexer, Syntax.TOKEN_BRACE_OPEN)


func _handle_logic_block_stop(lexer : Lexer)-> Array[Token]:
	lexer._pop_mode()
	return _handle_logic_block_stop_and_start(lexer, Syntax.TOKEN_BRACE_CLOSE)


func _handle_logic_block_stop_and_start(lexer : Lexer, syntaxToken : String)-> Array[Token]:
	var setupDict : Dictionary= MiscLexerFunctions._internal_setup(lexer)
	MiscLexerFunctions._increase_lexer_position(lexer)
	var token :Token = Token.new(syntaxToken, lexer._line, setupDict["initial_column"])
	

	var linebreak : Token = null
	if(syntaxToken == Syntax.TOKEN_BRACE_CLOSE):
		linebreak = MiscLexerFunctions._get_following_line_break(lexer._input,lexer._line, lexer._column, lexer._position)
	if(syntaxToken == Syntax.TOKEN_BRACE_OPEN):
		linebreak = MiscLexerFunctions._get_leading_line_break(lexer._input,lexer._line, lexer._position)
	
	
	if linebreak != null:
		if (syntaxToken == Syntax.TOKEN_BRACE_CLOSE):
			return [ token, linebreak ] 
		return [ linebreak, token ] 

	return [token]


func _handle_logic_block(lexer : Lexer) -> Array[Token]:
	if lexer._input[lexer._position] == '"' || lexer._input[lexer._position] == "'":
		if lexer._current_quote.is_empty():
			lexer._current_quote = lexer._input[lexer._position]
		return _handle_logic_string(lexer)
	
	if lexer._input[lexer._position] == '}':
		return _handle_logic_block_stop(lexer)
	
	if lexer._input[lexer._position].is_valid_int():
		return _handle_logic_number(lexer)
	
	for i in range(SyntaxDictionaries.MAX_VALUE_LENGTH, 0, -1):
		if(SyntaxDictionaries.logicSymbolTokensOperatorsWithSideEffects.has(MiscLexerFunctions._get_sequence(lexer._input, lexer._position,i))):
			var tokenDict = SyntaxDictionaries.logicSymbolTokensOperatorsWithSideEffects.get(MiscLexerFunctions._get_sequence(lexer._input, lexer._position,i))
			return _handle_logic_operator(lexer, tokenDict["token"], tokenDict["length"])
			
		if(SyntaxDictionaries.logicSymbolTokensSideOperatorWithoutSideEffects.has(MiscLexerFunctions._get_sequence(lexer._input, lexer._position,i))):
			var tokenDict = SyntaxDictionaries.logicSymbolTokensSideOperatorWithoutSideEffects.get(MiscLexerFunctions._get_sequence(lexer._input, lexer._position,i))
			return [MiscLexerFunctions._create_simple_token(lexer, tokenDict["token"], tokenDict["length"])]
	
	if lexer._input[lexer._position] == '!':
		return _handle_logic_not(lexer)
	
	var identifier : RegEx = RegEx.new()
	identifier.compile("[A-Z|a-z]")
	if identifier.search(lexer._input[lexer._position]) != null:
		return _handle_logic_identifier(lexer)
	return []


func _handle_logic_identifier(lexer : Lexer) -> Array[Token]:
	var setupDict : Dictionary= MiscLexerFunctions._internal_setup(lexer)
	
	while MiscLexerFunctions._is_valid_position(lexer._input, lexer._position) and MiscLexerFunctions._is_identifier(lexer._input[lexer._position]):
		setupDict["values"] += lexer._input[lexer._position]
		MiscLexerFunctions._increase_lexer_position(lexer)

	if Syntax._keywords.has(setupDict["values"].to_lower()):
		return _handle_logic_descpritive_operator(lexer, setupDict["values"], setupDict["initial_column"])
	return [Token.new(Syntax.TOKEN_IDENTIFIER, lexer._line, setupDict["initial_column"], setupDict["values"].strip_edges())]


func _handle_logic_descpritive_operator(lexer : Lexer, value : String, initial_column : int) -> Array[Token]:
	if(SyntaxDictionaries.logicDescriptiveTokens.has(value)):
		if(value == 'true' || value == 'false'):
			return [Token.new(SyntaxDictionaries.logicDescriptiveTokens.get(value), lexer._line, initial_column,value)]
		return [Token.new(SyntaxDictionaries.logicDescriptiveTokens.get(value), lexer._line, initial_column)]
	return []


func _handle_logic_not(lexer : Lexer) -> Array[Token]:
	var setupDict : Dictionary= MiscLexerFunctions._internal_setup(lexer)
	MiscLexerFunctions._increase_lexer_position(lexer)
	return [Token.new(Syntax.TOKEN_NOT, lexer._line, setupDict["initial_column"])]


func _handle_logic_operator(lexer : Lexer, tokenName : String, length: int) -> Array[Token]:
	var setupDict : Dictionary = MiscLexerFunctions._internal_setup(lexer)
	MiscLexerFunctions._increase_lexer_position(lexer, length, length)
	return [Token.new(tokenName, lexer._line, setupDict["initial_column"])]


func _handle_logic_number(lexer : Lexer) -> Array[Token]:
	var setupDict : Dictionary = MiscLexerFunctions._internal_setup(lexer)

	while MiscLexerFunctions._is_valid_position(lexer._input, lexer._position) and (lexer._input[lexer._position] == '.' or lexer._input[lexer._position].is_valid_int()):
		setupDict["values"] += lexer._input[lexer._position]
		MiscLexerFunctions._increase_lexer_position(lexer)

	return [Token.new(Syntax.TOKEN_NUMBER_LITERAL, lexer._line, setupDict["initial_column"], setupDict["values"])]


func _handle_logic_string(lexer : Lexer) -> Array[Token]:
	var setupDict : Dictionary = MiscLexerFunctions._internal_setup(lexer)
	MiscLexerFunctions._increase_lexer_position(lexer)
	var tokens : Array[Token]= LineHandler.new()._handle_qtext(lexer)
	MiscLexerFunctions._increase_lexer_position(lexer)

	tokens[0].token = Syntax.TOKEN_STRING_LITERAL
	tokens[0].column = setupDict["initial_column"]

	return tokens
