class_name LineLexer
extends MiscLexer


# Consumes as text or speaker text until it hits special character
# or end of line
func handle_text() -> Array[Token]:
	var setup_dict : Dictionary = LexerHelperFunctions.internal_setup(lexer)

	# Get text
	while lexer.position < lexer.input.length():
		var current_char : String = lexer.input[lexer.position]

		if ['\n', '$', '#', '{' ].has(current_char):
			break

		if (current_char == "\\" 
		&& lexer.input[lexer.position + 1] != 'n'):
			setup_dict["values"] += lexer.input[lexer.position + 1]
			LexerHelperFunctions.increase_lexer_position(lexer, 2, 2)
			continue

		# Rule : if : in text, consume speaker
		if current_char == ':':
			LexerHelperFunctions.increase_lexer_position(lexer)
			return [Token.new(Syntax.TOKEN_SPEAKER, setup_dict["initial_line"], 
				setup_dict["initial_column"], setup_dict["values"].strip_edges())]

		setup_dict["values"] += current_char
		LexerHelperFunctions.increase_lexer_position(lexer)

	return [Token.new(Syntax.TOKEN_TEXT, setup_dict["initial_line"],
		setup_dict["initial_column"], setup_dict["values"].strip_edges())]


# Consumes as line id until end of line
func handle_line_id() -> Array[Token]:
	var setup_dict : Dictionary = LexerHelperFunctions.internal_setup(lexer)
	
	# Move past identifier character
	LexerHelperFunctions.increase_lexer_position(lexer)
	
	# Get Line ID
	while (LexerHelperFunctions.is_valid_position(lexer.input, lexer.position) 
	&& LexerHelperFunctions.is_identifier(lexer.input[lexer.position])):
		setup_dict["values"] += lexer.input[lexer.position]
		LexerHelperFunctions.increase_lexer_position(lexer)

	var token : Token = Token.new(Syntax.TOKEN_LINE_ID, lexer.line,
		setup_dict["initial_column"], setup_dict["values"])
	var tokens : Array[Token]= [token]

	# Rule : if & in line id, consume id suffix
	while (LexerHelperFunctions.is_valid_position(lexer.input, lexer.position) 
	&&  lexer.input[lexer.position] == '&'):
		tokens.append_array(handle_id_suffix())

	return tokens


# Consume tag until end of file
func handle_tag() -> Array[Token]:
	return handle_tag_or_id_suffix(Syntax.TOKEN_TAG)


# Consume id suffix until end of file
func handle_id_suffix()-> Array[Token]:
	return handle_tag_or_id_suffix(Syntax.TOKEN_ID_SUFFIX)


func handle_tag_or_id_suffix(token : String) -> Array[Token]:
	var setup_dict : Dictionary = LexerHelperFunctions.internal_setup(lexer)
	
	# Move past tag/id identifier character
	LexerHelperFunctions.increase_lexer_position(lexer)
	
	# Get tag/id
	while (LexerHelperFunctions.is_valid_position(lexer.input, lexer.position) 
	&& LexerHelperFunctions.is_identifier(lexer.input[lexer.position])):
		setup_dict["values"] += lexer.input[lexer.position]
		LexerHelperFunctions.increase_lexer_position(lexer)

	return [Token.new(token, lexer.line, 
		setup_dict["initial_column"], setup_dict["values"])]

 
# Consume qoute text until next quotation mark
func handle_qtext() -> Array[Token]:
	var setup_dict : Dictionary= LexerHelperFunctions.internal_setup(lexer)

	#Get Quote
	while lexer.position < lexer.input.length():
		var current_char : String = lexer.input[lexer.position]

		if current_char == lexer.current_quote:
			break

		if (current_char == '\\' 
		&& lexer.input[lexer.position + 1] == lexer.current_quote):
			setup_dict["values"] += lexer.input[lexer.position + 1]
			LexerHelperFunctions.increase_lexer_position(lexer, 2, 2)
			continue

		if current_char == '\n':
			lexer.line += 1

		setup_dict["values"] += current_char 

		LexerHelperFunctions.increase_lexer_position(lexer)

	return [Token.new(Syntax.TOKEN_TEXT, setup_dict["initial_line"],
		setup_dict["initial_column"], setup_dict["values"].strip_edges())]


# Consume quotation mark and start/stop quote mode, return nothing
func handle_quote() -> Array[Token]:
	LexerHelperFunctions.increase_lexer_position(lexer)
	if lexer.is_current_mode(Syntax.MODE_QSTRING):
		lexer.current_quote = ""
		lexer.pop_mode()
	else:
		lexer.stack_mode(Syntax.MODE_QSTRING)
		
	return []

 

