class_name MiscLexerFunctions
extends RefCounted


static func _create_simple_token(lexer : Lexer,tokenName : String, length = 1) -> Token:
	var setupDict : Dictionary = _internal_setup(lexer)
	_increase_lexer_position(lexer, length)
	return Token.init(tokenName, lexer._line, setupDict["initial_column"])


static func _get_following_line_break(_input : String,_line : int, _column: int, _position : int) -> Token:
	var lookup_position = _position
	var lookup_column = _column

	while _is_valid_position(_input, _position) and _is_tab_char(_input[lookup_position]):
		lookup_position += 1
		lookup_column += 1

	if  _is_valid_position(_input, _position) and _input[lookup_position] == '\n':
		return Token.init(Syntax.TOKEN_LINE_BREAK, _line, lookup_column)
	return null


static func _get_leading_line_break(_input : String, _line : int, _position :  int) -> Token:
	var lookup_position = _position - 2
	while _is_tab_char(_input[lookup_position]):
		lookup_position -= 1

	if _input[lookup_position] == '\n':
		return Token.init(Syntax.TOKEN_LINE_BREAK, _line, 0)
	return null


static func _array_join(arr : Array[String], separator = ""):
	var output = "";
	for s in arr:
		output += str(s) + separator
	output = output.left(output.length() - separator.length())
	return output


static func _is_tab_char(character : String) -> bool:
	var tab = RegEx.new()
	tab.compile("[\t ]")
	return tab.search(character) != null


static func _is_valid_position(_input : String, _position : int) -> bool:
	return _position < _input.length() && _input[_position] != null


static func _is_identifier(character : String) -> bool:
	var lineId : RegEx = RegEx.new()
	lineId.compile("[A-Z|a-z|0-9|_]")
	return lineId.search(character) != null


static func _is_block_identifier(character : String) -> bool:
	var identifier : RegEx = RegEx.new()
	identifier.compile("[A-Z|a-z|0-9|_| ]")
	return identifier.search(character) != null


static func _get_sequence(string: String, initial_position: int, value : int) -> String:
	return string.substr(initial_position, value)


static func _internal_setup(lexer : Lexer) -> Dictionary:
	var initial_line : int = lexer._line
	var initial_column : int= lexer._column
	var values : String = ""
	return {"initial_column" : initial_column,"initial_line" :initial_line ,"values": values}


static func _increase_lexer_position(lexer : Lexer, posAmt : int = 1, colAmt : int = 1 ) -> void:
	lexer._position += posAmt
	lexer._column += colAmt
