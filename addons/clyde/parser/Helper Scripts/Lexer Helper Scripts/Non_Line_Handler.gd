class_name NonLineHandler
extends RefCounted


# Consumes line breaks and returns nothing
func handle_line_breaks(lexer : Lexer) -> Array[Token]:
	
	while (MiscLexerFunctions.is_valid_position(lexer.input, lexer.position) 
	&& lexer.input[lexer.position] == '\n'):
		lexer.line += 1
		
		# Move position forward and reset column
		MiscLexerFunctions.increase_lexer_position(lexer, 1, lexer.column * -1)
		if lexer.is_current_mode(Syntax.MODE_OPTION):
			lexer.pop_mode()
	return []


# Consumes a space and returns nothing
func handle_space(lexer : Lexer) -> Array[Token]:
	while lexer.input[lexer.position] == ' ':
		MiscLexerFunctions.increase_lexer_position(lexer)
	return []


# Consume a rogue tab and returns nothing
func handle_rogue_tab(lexer : Lexer) -> Array[Token]:
	var tab : RegEx = RegEx.new()
	tab.compile("[\t]")
	
	while tab.search(lexer.input[lexer.position]) != null:
		MiscLexerFunctions.increase_lexer_position(lexer)
	
	return []


# Consumes and returns indent or dedent or nothing
func handle_indent(lexer : Lexer) -> Array[Token]:
	var setup_dict : Dictionary = MiscLexerFunctions.internal_setup(lexer)
	var indentation : int = 0
	
	while (MiscLexerFunctions.is_valid_position(lexer.input, lexer.position) 
	&& MiscLexerFunctions.is_tab_char(lexer.input[lexer.position])):
		indentation += 1
		MiscLexerFunctions.increase_lexer_position(lexer, 1, 0)

	# Rule : if current indentation is greater then previous indentation,
	# consume and return indent
	if indentation > lexer.indent[0]:
		var previous_indent : int = lexer.indent[0]
		MiscLexerFunctions.increase_lexer_position(lexer,0, indentation)
		lexer.indent.push_front(indentation)
		return [Token.new(Syntax.TOKEN_INDENT, setup_dict["initial_line"], previous_indent)]

	# Rule : if current indentation level is equal to a previous indentation level,
	# consume and return nothing
	if indentation == lexer.indent[0]:
		MiscLexerFunctions.increase_lexer_position(lexer,0, lexer.indent[0])
		return []

	var tokens : Array[Token]= []
	
	# Rule : if current indentation is lesser then previous indentation,
	# consume and return dedent
	while indentation < lexer.indent[0]:
		lexer.indent.pop_front()
		lexer.column = lexer.indent[0]
		tokens.push_back(Token.new(Syntax.TOKEN_DEDENT, lexer.line, lexer.column))

	return tokens


# Consume and return block
func handle_block(lexer : Lexer) -> Array[Token]:
	var setup_dict : Dictionary = MiscLexerFunctions.internal_setup(lexer)
	MiscLexerFunctions.increase_lexer_position(lexer,2,2)

	while  (MiscLexerFunctions.is_valid_position(lexer.input, lexer.position) 
	&& MiscLexerFunctions.is_identifier(lexer.input[lexer.position])):
		setup_dict["values"] += lexer.input[lexer.position]
		MiscLexerFunctions.increase_lexer_position(lexer)
	
	return [Token.new(Syntax.TOKEN_BLOCK, lexer.line, 
		setup_dict["initial_column"], setup_dict["values"].strip_edges())]


# Consume and returns divert and linebreak if one exists
func handle_divert(lexer : Lexer) -> Array[Token]:
	var setup_dict : Dictionary = MiscLexerFunctions.internal_setup(lexer)
	MiscLexerFunctions.increase_lexer_position(lexer,2,2)

	while  (MiscLexerFunctions.is_valid_position(lexer.input, lexer.position) 
	&& MiscLexerFunctions.is_identifier(lexer.input[lexer.position])):
		setup_dict["values"] += lexer.input[lexer.position]
		MiscLexerFunctions.increase_lexer_position(lexer)

	var token : Token =  Token.new(Syntax.TOKEN_DIVERT, lexer.line, 
		setup_dict["initial_column"], setup_dict["values"].strip_edges())

	var linebreak : Token =  MiscLexerFunctions.get_following_line_break(
		lexer.input, lexer.line, lexer.column, lexer.position)
	
	if linebreak:
		return [token, linebreak]

	return [token]


# Consume and return Divert parent and linebreak if one exists
func handle_divert_parent(lexer : Lexer) -> Array[Token]:
	var setup_dict : Dictionary = MiscLexerFunctions.internal_setup(lexer)
	MiscLexerFunctions.increase_lexer_position(lexer, 2, 2)

	var token : Token = Token.new(Syntax.TOKEN_DIVERT_PARENT,
		lexer.line, setup_dict["initial_column"])

	var linebreak =  MiscLexerFunctions.get_following_line_break(lexer.input, 
		lexer.line, lexer.column, lexer.position)
	
	if linebreak:
		return [token, linebreak]

	return [token]


# Consume Bracket open and variations mode if no value and start varaitons mode
func handle_start_variations(lexer : Lexer) -> Array[Token]:
	var setup_dict : Dictionary = MiscLexerFunctions.internal_setup(lexer)
	MiscLexerFunctions.increase_lexer_position(lexer)
	lexer.stack_mode(Syntax.MODE_VARIATIONS)

	var identifier : RegEx = RegEx.new()
	identifier.compile("[A-Z|a-z| ]")

	while (MiscLexerFunctions.is_valid_position(lexer.input, lexer.position) 
	&& identifier.search(lexer.input[lexer.position]) != null):
		setup_dict["values"] += lexer.input[lexer.position]
		MiscLexerFunctions.increase_lexer_position(lexer)

	var tokens : Array[Token]= [Token.new(Syntax.TOKEN_BRACKET_OPEN,
			lexer.line, setup_dict["initial_column"])]

	var value = setup_dict["values"].strip_edges()

	if value.length() > 0:
		tokens.push_back(Token.new(Syntax.TOKEN_VARIATIONS_MODE, lexer.line, 
			setup_dict["initial_column"] + 2, value))

	return tokens


# Consume and return bracket close
func handle_stop_variations(lexer : Lexer) -> Array[Token]:
	var setup_dict : Dictionary = MiscLexerFunctions.internal_setup(lexer)
	MiscLexerFunctions.increase_lexer_position(lexer)
	lexer.pop_mode()
	return [Token.new(Syntax.TOKEN_BRACKET_CLOSE, 
		lexer.line, setup_dict["initial_column"])]


# Consume variation item as a minus token
# This will be used correctly due to previous variations mode token
func handle_variation_item(lexer : Lexer) -> Array[Token]:
	var setup_dict : Dictionary = MiscLexerFunctions.internal_setup(lexer)
	MiscLexerFunctions.increase_lexer_position(lexer)
	return [Token.new(Syntax.TOKEN_MINUS, 
		lexer.line, setup_dict["initial_column"])]
