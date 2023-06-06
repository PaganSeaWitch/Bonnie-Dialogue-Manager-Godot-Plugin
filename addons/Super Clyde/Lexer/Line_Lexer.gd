class_name LineLexer
extends MiscLexer


# Consumes as text or speaker text until it hits special character
# or end of line
func handle_text() -> Array[Token]:
	var setup_dict : Dictionary = LexerHelperFunctions.internal_setup(lexer)


	# Addtional logic for honoring spaces in line_parts
	var strip_right = true

	var strip_left = true
	var current_pos = lexer.position - 1
	var moving_thru_logic = false
	var left_spaces = 0
	var right_spaces = 0
	# Go past previous spaces
	while current_pos >= 1 && (lexer.input[current_pos] == ' ' || moving_thru_logic):
		if(!moving_thru_logic):
			left_spaces = left_spaces + 1
		current_pos = current_pos - 1
		var current_char : String = lexer.input[current_pos]
		if(current_char == '}'):
			moving_thru_logic = true
		if(lexer.input[current_pos+1] == '{'):
			moving_thru_logic = false
	# if before the previous spaces is a ], honor spacing
	if(lexer.input[current_pos] == ']'):
		strip_left = false


	# Get text
	while lexer.position < lexer.input.length():
		var current_char : String = lexer.input[lexer.position]

		
		if ['\n', '\r', '$', '#', '{', '[' ].has(current_char):
			# if were ending on a [, honor spacing
			if('[' == current_char):
				strip_right = false
			if('{' == current_char):
				# Go past previous spaces
				moving_thru_logic = true
				current_pos = lexer.position
				while current_pos <= lexer.input.length()-2 && (lexer.input[current_pos] == ' ' || moving_thru_logic):
					if(!moving_thru_logic):
						right_spaces = right_spaces + 1
					current_pos = current_pos + 1
					current_char = lexer.input[current_pos]
					if(current_char == '}'):
						moving_thru_logic = true
					if(lexer.input[current_pos-1] == '}'):
						moving_thru_logic = false
				# if before the previous spaces is a ], honor spacing
				if(current_char == '['):
					strip_right = false
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

	var left_spaces_str = " ".repeat(left_spaces) + "" if !strip_left else ""
	var right_spaces_str = " ".repeat(right_spaces) + "" if !strip_right else ""
	return [Token.new(Syntax.TOKEN_TEXT, setup_dict["initial_line"],
		setup_dict["initial_column"], left_spaces_str +setup_dict["values"].strip_edges(true, strip_right) + right_spaces_str)]


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

 

