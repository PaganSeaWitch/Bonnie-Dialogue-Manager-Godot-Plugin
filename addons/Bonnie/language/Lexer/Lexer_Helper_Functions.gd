class_name LexerHelperFunctions
extends RefCounted


# Creates a simple token without a value
static func create_simple_token(lexer : BonnieLexer, token_name : String, 
pos_length : int = 1, col_length : int = 0) -> Token:
	var setupDict : Dictionary = internal_setup(lexer)
	increase_lexer_position(lexer, pos_length, col_length)
	return Token.new(token_name, lexer.line, setupDict["initial_column"])


# Consumes the line break after something if there is one
static func get_following_line_break(input : String,line : int, 
column: int, position : int) -> Token:
	var lookup_position : int = position
	var lookup_column : int = column

	while (is_valid_position(input, position) 
	&& is_tab_char(input[lookup_position])):
		lookup_position += 1
		lookup_column += 1

	if  is_valid_position(input, position) && input[lookup_position] == '\n':
		return Token.new(Syntax.TOKEN_LINE_BREAK, line, lookup_column)
	return null


# Consumes the line break before something if there is one
static func get_leading_line_break(input : String, 
line : int, position :  int) -> Token:
	var lookup_position = position - 2
	
	while is_tab_char(input[lookup_position]):
		lookup_position -= 1

	if is_valid_position(input, position) && input[lookup_position] == '\n':
		return Token.new(Syntax.TOKEN_LINE_BREAK, line, 0)
	return null


# Checks whether current character is a a tab
static func is_tab_char(character : String) -> bool:
	var regex = RegEx.new()
	regex.compile("[\t ]")
	return regex.search(character) != null


# Checks whether the current position isn't null and 
# within the bounds of the input file
static func is_valid_position(input : String, position : int) -> bool:
	return position < input.length() && input[position] != null


# Checks whether something is a alphanumeric or _
static func is_identifier(character : String) -> bool:
	var regex : RegEx = RegEx.new()
	regex.compile("[A-Z|a-z|0-9|_|@|.]")
	return regex.search(character) != null


static func is_block_identifier(character : String) -> bool:
	var regex : RegEx = RegEx.new()
	regex.compile("[A-Z|a-z|0-9|_| |.]")
	return regex.search(character) != null


# Creates a dictionary of line and column and values so we can manipulate them
static func internal_setup(lexer : BonnieLexer) -> Dictionary:
	var initial_line : int = lexer.line
	var initial_column : int= lexer.column
	var values : String = ""
	return {"initial_column" : initial_column,
		"initial_line" :initial_line ,"values": values}


static func increase_lexer_position(lexer : BonnieLexer, pos_amt : int = 1, 
col_amt : int = 1 ) -> void:
	lexer.position += pos_amt
	lexer.column += col_amt
