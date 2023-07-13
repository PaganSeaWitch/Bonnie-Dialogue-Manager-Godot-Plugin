class_name MiscLexer
extends RefCounted

var lexer : BonnieLexer


func init(_lexer : BonnieLexer) -> void:
	lexer = _lexer


# Consumes line breaks and returns nothing
func handle_line_breaks() -> Array[Token]:
	
	var token = Token.new(Syntax.TOKEN_LINE_BREAK, lexer.line, lexer.column)
	while (LexerHelperFunctions.is_valid_position(lexer.input, lexer.position) 
	&& (lexer.input[lexer.position] == '\n' || lexer.input[lexer.position] == '\r')):
		lexer.line += 1
		
		# Move position forward and reset column
		LexerHelperFunctions.increase_lexer_position(lexer, 1, lexer.column * -1)
		if lexer.is_current_mode(Syntax.MODE_OPTION) || lexer.is_current_mode(Syntax.MODE_BLOCK_REQ):
			lexer.pop_mode()
	if(token.line == lexer.line_in_parts):
		lexer.added_space = true
		return [token]
	return []


# Consumes a space and returns nothing
func handle_space() -> Array[Token]:
	while lexer.input[lexer.position] == ' ':
		LexerHelperFunctions.increase_lexer_position(lexer)
	return []


# Consume a rogue tab and returns nothing
func handle_rogue_tab() -> Array[Token]:
	var tab : RegEx = RegEx.new()
	tab.compile("[\t]")
	
	while tab.search(lexer.input[lexer.position]) != null:
		LexerHelperFunctions.increase_lexer_position(lexer)
	
	return []


# Consumes and returns indent or dedent or nothing
func handle_indent() -> Array[Token]:
	var setup_dict : Dictionary = LexerHelperFunctions.internal_setup(lexer)
	var indentation : int = 0
	
	while (LexerHelperFunctions.is_valid_position(lexer.input, lexer.position) 
	&& LexerHelperFunctions.is_tab_char(lexer.input[lexer.position])):
		indentation += 1
		LexerHelperFunctions.increase_lexer_position(lexer, 1, 0)

	# Rule : if current indentation is greater then previous indentation,
	# consume and return indent
	if indentation > lexer.indent[0]:
		var previous_indent : int = lexer.indent[0]
		LexerHelperFunctions.increase_lexer_position(lexer,0, indentation)
		lexer.indent.push_front(indentation)
		return [Token.new(Syntax.TOKEN_INDENT, setup_dict["initial_line"], previous_indent)]

	# Rule : if current indentation level is equal to a previous indentation level,
	# consume and return nothing
	if indentation == lexer.indent[0]:
		LexerHelperFunctions.increase_lexer_position(lexer,0, lexer.indent[0])
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
func handle_block() -> Array[Token]:
	var setup_dict : Dictionary = LexerHelperFunctions.internal_setup(lexer)

	var token_name : String 
	match lexer.input[lexer.position+1]: 
		'*':
			token_name = Syntax.TOKEN_RANDOM_BLOCK
		'+':
			token_name = Syntax.TOKEN_RANDOM_STICKY_BLOCK
		'>':
			token_name = Syntax.TOKEN_RANDOM_FALLBACK_BLOCK
		'=':
			token_name = Syntax.TOKEN_BLOCK
	LexerHelperFunctions.increase_lexer_position(lexer,2,2)

	while  (LexerHelperFunctions.is_valid_position(lexer.input, lexer.position) 
	&& LexerHelperFunctions.is_block_identifier(lexer.input[lexer.position])):
		setup_dict["values"] += lexer.input[lexer.position]
		LexerHelperFunctions.increase_lexer_position(lexer)

	var block_name = setup_dict["values"].strip_edges()
	if(block_name.contains(" ")):
		assert(false, "Cannot have spaces in block names!")
		return []
	
	return [Token.new(token_name, lexer.line, 
		setup_dict["initial_column"], setup_dict["values"].strip_edges())]


func handle_block_requirement() -> Array[Token]:
	var setup_dict : Dictionary = LexerHelperFunctions.internal_setup(lexer)
	LexerHelperFunctions.increase_lexer_position(lexer,4,4)
	lexer.stack_mode(Syntax.MODE_BLOCK_REQ)
	return [Token.new(Syntax.TOKEN_KEYWORD_BLOCK_REQ, lexer.line, 
		setup_dict["initial_column"], "")]


# Consume and returns divert and linebreak if one exists
func handle_divert() -> Array[Token]:
	var setup_dict : Dictionary = LexerHelperFunctions.internal_setup(lexer)
	LexerHelperFunctions.increase_lexer_position(lexer,2,2)

	while  (LexerHelperFunctions.is_valid_position(lexer.input, lexer.position) 
	&& LexerHelperFunctions.is_block_identifier(lexer.input[lexer.position])):
		setup_dict["values"] += lexer.input[lexer.position]
		LexerHelperFunctions.increase_lexer_position(lexer)

	var divert = setup_dict["values"].strip_edges()
	if(divert.contains(" ")):
		assert(false, "Diverts cannot contain spaces!")
		return []
	var token : Token =  Token.new(Syntax.TOKEN_DIVERT, lexer.line, 
		setup_dict["initial_column"], divert)


	var linebreak : Token =  LexerHelperFunctions.get_following_line_break(
		lexer.input, lexer.line, lexer.column, lexer.position)
	
	if linebreak:
		return [token, linebreak]

	return [token]


# Consume and return Divert parent and linebreak if one exists
func handle_divert_parent() -> Array[Token]:
	var setup_dict : Dictionary = LexerHelperFunctions.internal_setup(lexer)
	LexerHelperFunctions.increase_lexer_position(lexer, 2, 2)

	var token : Token = Token.new(Syntax.TOKEN_DIVERT_PARENT,
		lexer.line, setup_dict["initial_column"])

	var linebreak =  LexerHelperFunctions.get_following_line_break(lexer.input, 
		lexer.line, lexer.column, lexer.position)
	
	if linebreak:
		return [token, linebreak]

	return [token]


# Consumes until next line and returns empty
func handle_comments() -> Array[Token]:
	while (LexerHelperFunctions.is_valid_position(lexer.input, lexer.position) 
	&& lexer.input[lexer.position] != '\n'):
		LexerHelperFunctions.increase_lexer_position(lexer, 1, 0)

	LexerHelperFunctions.increase_lexer_position(lexer, 1, 0)
	lexer.line += 1
	return []
