class_name NonLineHandler
extends RefCounted


static func _handle_line_breaks(lexer : Lexer) -> Array[Token]:
	while MiscLexerFunctions._is_valid_position(lexer._input, lexer._position) and lexer._input[lexer._position] == '\n':
		lexer._line += 1
		MiscLexerFunctions._increase_lexer_position(lexer, 1, 0)
		if MiscLexerFunctions._is_current_mode(Syntax.MODE_OPTION):
			lexer._pop_mode()
	return []


static func _handle_space(lexer : Lexer) -> Array[Token]:
	while lexer._input[lexer._position] == ' ':
		MiscLexerFunctions._increase_lexer_position(lexer)
	return []


static func _handle_rogue_tab(lexer : Lexer):
	var tab : RegEx = RegEx.new()
	tab.compile("[\t]")
	while tab.search(lexer._input[lexer._position]) != null:
		MiscLexerFunctions._increase_lexer_position(lexer)


static func _handle_indent(lexer : Lexer) -> Array[Token]:
	var setupDict : Dictionary = MiscLexerFunctions._internal_setup(lexer)

	var indentation = 0
	while MiscLexerFunctions._is_valid_position(lexer._input, lexer._position) and MiscLexerFunctions._is_tab_char(lexer._input[lexer._position]):
		indentation += 1
		MiscLexerFunctions._increase_lexer_position(lexer, 1, 0)

	if indentation > lexer._indent[0]:
		var previous_indent : int = lexer._indent[0]
		MiscLexerFunctions._increase_lexer_position(lexer,0, indentation )
		return Token.init(Syntax.TOKEN_INDENT, setupDict["initial_line"], previous_indent)

	if indentation == lexer._indent[0]:
		MiscLexerFunctions._increase_lexer_position(lexer,0, lexer._indent[0] )
		return []

	var tokens : Array[Token]= []
	while indentation < lexer._indent[0]:
		lexer._indent.pop_front()
		MiscLexerFunctions._increase_lexer_position(lexer,0, lexer._indent[0] )
		tokens.push_back(Token.init(Syntax.TOKEN_DEDENT, lexer._line, lexer._column))

	return tokens


static func _handle_block(lexer : Lexer) -> Array[Token]:
	var setupDict : Dictionary = MiscLexerFunctions._internal_setup(lexer)
	MiscLexerFunctions._increase_lexer_position(lexer,2,2)

	while  MiscLexerFunctions._is_valid_position(lexer._input, lexer._position) and MiscLexerFunctions._is_block_identifier(lexer._input[lexer._position]):
		setupDict["values"] += lexer._input[lexer._position]
		MiscLexerFunctions._increase_lexer_position(lexer)
	return [Token.init(Syntax.TOKEN_BLOCK, lexer._line, setupDict["initial_column"],setupDict["values"].strip_edges())]


static func _handle_divert(lexer : Lexer) -> Array[Token]:
	var setupDict : Dictionary = MiscLexerFunctions._internal_setup(lexer)
	MiscLexerFunctions._increase_lexer_position(lexer,2,2)

	while  MiscLexerFunctions._is_valid_position(lexer._input, lexer._position) and MiscLexerFunctions._is_block_identifier(lexer._input[lexer._position]):
		setupDict["values"] += lexer._input[lexer._position]
		MiscLexerFunctions._increase_lexer_position(lexer)

	var token =  Token.init(Syntax.TOKEN_DIVERT, lexer._line, setupDict["initial_column"],setupDict["values"].strip_edges())

	var linebreak =  MiscLexerFunctions._get_following_line_break(lexer._input,lexer._line, lexer._column, lexer._position)
	if linebreak:
		return [ token, linebreak ]

	return [token]


static func _handle_divert_parent(lexer : Lexer) -> Array[Token]:
	var setupDict : Dictionary = MiscLexerFunctions._internal_setup(lexer)
	MiscLexerFunctions._increase_lexer_position(lexer, 2, 2)

	var token = Token.init(Syntax.TOKEN_DIVERT_PARENT, lexer._line, setupDict["initial_column"])

	var linebreak =  MiscLexerFunctions._get_following_line_break(lexer._input,lexer._line, lexer._column, lexer._position)
	if linebreak:
		return [ token, linebreak ]

	return [token]


static func _handle_start_variations(lexer : Lexer) -> Array[Token]:
	var setupDict : Dictionary = MiscLexerFunctions._internal_setup(lexer)
	MiscLexerFunctions._increase_lexer_position(lexer)
	lexer._stack_mode(Syntax.MODE_VARIATIONS)

	var identifier = RegEx.new()
	identifier.compile("[A-Z|a-z| ]")

	while MiscLexerFunctions._is_valid_position(lexer._input, lexer._position) and lexer.identifier.search(lexer._input[lexer._position]) != null:
		setupDict["values"] += lexer._input[lexer._position]
		MiscLexerFunctions._increase_lexer_position(lexer)

	var tokens = [
		Token.init(Syntax.TOKEN_BRACKET_OPEN, lexer._line, setupDict["initial_column"])
	]

	var value = MiscLexerFunctions._array_join(setupDict["values"]).strip_edges()

	if value.length() > 0:
		tokens.push_back(Token.init(Syntax.TOKEN_VARIATIONS_MODE, lexer._line, setupDict["initial_column"] + 2, value))

	return tokens


static func _handle_stop_variations(lexer : Lexer) -> Array[Token]:
	var setupDict : Dictionary = MiscLexerFunctions._internal_setup(lexer)
	MiscLexerFunctions._increase_lexer_position(lexer)
	lexer._pop_mode()
	return Token.init(Syntax.TOKEN_BRACKET_CLOSE, lexer._line, setupDict["initial_column"])


static func _handle_variation_item(lexer : Lexer):
	var setupDict : Dictionary = MiscLexerFunctions._internal_setup(lexer)
	MiscLexerFunctions._increase_lexer_position(lexer)
	return Token.init(Syntax.TOKEN_MINUS, lexer._line, setupDict["initial_column"])
