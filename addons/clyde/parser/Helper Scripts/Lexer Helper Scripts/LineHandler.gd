class_name LineHandler
extends RefCounted


func _handle_comments(lexer : Lexer) -> Array[Token]:
	while MiscLexerFunctions._is_valid_position(lexer._input, lexer._position) && lexer._input[lexer._position] != '\n':
		MiscLexerFunctions._increase_lexer_position(lexer, 1, 0)

	MiscLexerFunctions._increase_lexer_position(lexer)
	return []


func _handle_text(lexer : Lexer) -> Array[Token]:
	var setupDict : Dictionary = MiscLexerFunctions._internal_setup(lexer)

	while lexer._position < lexer._input.length():
		var current_char : String = lexer._input[lexer._position]

		if ['\n', '$', '#', '{' ].has(current_char):
			break

		if current_char == "\\" and lexer._input[lexer._position + 1] != 'n':
			setupDict["values"].push_back(lexer._input[lexer._position + 1])
			MiscLexerFunctions._increase_lexer_position(lexer, 2, 2)
			continue

		if current_char == ':':
			MiscLexerFunctions._increase_lexer_position(lexer)
			return [Token.init(Syntax.TOKEN_SPEAKER, setupDict["initial_line"], setupDict["initial_column"], MiscLexerFunctions._array_join(setupDict["values"]).strip_edges())]

		setupDict["values"].push_back(current_char)

		MiscLexerFunctions._increase_lexer_position(lexer)

	return [Token.init(Syntax.TOKEN_TEXT, setupDict["initial_line"], setupDict["initial_column"], MiscLexerFunctions._array_join(setupDict["values"]).strip_edges())]


func _handle_line_id(lexer : Lexer) -> Array[Token]:
	var setupDict : Dictionary = MiscLexerFunctions._internal_setup(lexer)
	MiscLexerFunctions._increase_lexer_position(lexer)
	
	while (MiscLexerFunctions._is_valid_position(lexer._input, lexer._position) && MiscLexerFunctions._is_identifier(lexer._input[lexer._position])):
		setupDict["values"] += lexer._input[lexer._position]
		MiscLexerFunctions._increase_lexer_position(lexer)

	var token : Token = Token.init(Syntax.TOKEN_LINE_ID, lexer._line, setupDict["initial_column"], setupDict["values"])
	var tokens = [token]

	while MiscLexerFunctions._is_valid_position(lexer._input, lexer._position) &&  lexer._input[lexer._position] == '&':
		tokens.push_back(_handle_id_suffix(lexer))

	return tokens


func _handle_tag(lexer : Lexer) -> Array[Token]:
	return _handle_tag_or_id_suffix(lexer, Syntax.TOKEN_TAG)


func _handle_id_suffix(lexer : Lexer)-> Array[Token]:
	return _handle_tag_or_id_suffix(lexer, Syntax.TOKEN_ID_SUFFIX)


func _handle_tag_or_id_suffix(lexer : Lexer, token : String) -> Array[Token]:
	var setupDict : Dictionary = MiscLexerFunctions._internal_setup(lexer)
	MiscLexerFunctions._increase_lexer_position(lexer)
	
	while MiscLexerFunctions._is_valid_position(lexer._input, lexer._position) and MiscLexerFunctions._is_identifier(lexer._input[lexer._position]):
		setupDict["values"] += lexer._input[lexer._position]
		MiscLexerFunctions._increase_lexer_position(lexer)

	return [Token.init(token, lexer._line, setupDict["initial_column"], setupDict["values"])]


func _handle_qtext(lexer : Lexer) -> Array[Token]:
	var setupDict : Dictionary= MiscLexerFunctions._internal_setup(lexer)

	while lexer._position < lexer._input.length():
		var current_char : String = lexer._input[lexer._position]

		if current_char == lexer._current_quote:
			break

		if current_char == '\\' and lexer._input[lexer._position + 1] == lexer._current_quote:
			setupDict["values"] += lexer._input[lexer._position + 1]
			MiscLexerFunctions._increase_lexer_position(lexer, 2, 2)
			continue

		if current_char == '\n':
			lexer._line += 1

		setupDict["values"] += current_char 

		MiscLexerFunctions._increase_lexer_position(lexer)

	return [Token.init(Syntax.TOKEN_TEXT, setupDict["initial_line"], setupDict["initial_column"], setupDict["values"].strip_edges())]


func _handle_quote(lexer : Lexer) -> Array[Token]:
	MiscLexerFunctions._increase_lexer_position(lexer)
	if lexer._is_current_mode(Syntax.MODE_QSTRING):
		lexer._current_quote = ""
		lexer._pop_mode()
	else:
		lexer._stack_mode(Syntax.MODE_QSTRING)
		
	return []


func _handle_options(lexer : Lexer) -> Array[Token]:
	var tokenName : String
	match lexer._input[lexer._position]:
		'*':
			tokenName = Syntax.TOKEN_OPTION
		'+':
			tokenName = Syntax.TOKEN_STICKY_OPTION
		'>':
			tokenName = Syntax.TOKEN_FALLBACK_OPTION
	var setupDict : Dictionary = MiscLexerFunctions._internal_setup(lexer)
	MiscLexerFunctions._increase_lexer_position(lexer)
	lexer._stack_mode(Syntax.MODE_OPTION)
	return [Token.init(tokenName, lexer._line, setupDict["initial_column"])]


func _handle_option_display_char(lexer : Lexer) -> Array[Token]:
	var setupDict : Dictionary = MiscLexerFunctions._internal_setup(lexer)
	MiscLexerFunctions._increase_lexer_position(lexer)
	return [Token.init(Syntax.TOKEN_ASSIGN, lexer._line, setupDict["initial_column"])]
