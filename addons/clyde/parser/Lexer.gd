class_name Lexer
extends RefCounted


var lineHandler : LineHandler = LineHandler.new()
var nonLineHandler : NonLineHandler = NonLineHandler.new()
var logicHandler : LogicHandler = LogicHandler.new()
var _input : String = ""
var _indent: Array[int] = [0]
var _position: int = 0
var _line : int = 0
var _column: int = 0
var _length : int= 0
var _pending_tokens : Array = []
var _modes : Array[String]= [ Syntax.MODE_DEFAULT ]
var _current_quote : String = ""


static func get_token_friendly_hint(tokenName : String) -> String:
	return Syntax._token_hints.get(tokenName, tokenName)


func init(input : String) -> Lexer:
	_input = input
	_indent = [0]
	_position = 0
	_line = 0
	_column = 0
	_length = input.length()
	_pending_tokens = []

	return self

func get_all() -> Array[Token]:
	var tokens : Array[Token]= []
	while _position < _length:
		var new_tokens : Array[Token] = _get_next_tokens()
		tokens = tokens + new_tokens


	_position += 1
	tokens.push_back(Token.init(Syntax.TOKEN_EOF, _line, _column))

	return tokens


func next() -> Token:
	if _pending_tokens.size() > 0:
		return _pending_tokens.pop_front()

	while _position < _length:
		var tokens = _get_next_tokens()
		if !tokens.is_empty():
			_pending_tokens = tokens
			return _pending_tokens.pop_front()

	_position += 1
	return Token.init(Syntax.TOKEN_EOF, _line, _column)


func _stack_mode(mode):
	_modes.push_front(mode)


func _pop_mode():
	if _modes.size() > 1:
		_modes.pop_front()


func _is_current_mode(mode):
	return _modes[0] == mode


func _get_next_tokens() -> Array[Token]:
	if not _is_current_mode(Syntax.MODE_QSTRING) and _input[_position] == '-' and _input[_position + 1] == '-':
		return lineHandler._handle_comments(self)

	if not _is_current_mode(Syntax.MODE_QSTRING) and _input[_position] == '\n':
		return nonLineHandler._handle_line_breaks(self)

	if not _is_current_mode(Syntax.MODE_LOGIC) and ((_column == 0 and MiscLexerFunctions._is_tab_char(_input[_position])) or (_column == 0 and _indent.size() > 1)):
		return nonLineHandler._handle_indent(self)

	if not _is_current_mode(Syntax.MODE_QSTRING) and _input[_position] == '{':
		return logicHandler._handle_logic_block_start(self)

	if _is_current_mode(Syntax.MODE_LOGIC):
		var response = logicHandler._handle_logic_block(self)

		if response:
			return response

	if _input[_position] == '"' or _input[_position] == "'":
		if _current_quote:
			if _input[_position] == _current_quote:
				return NonLineHandler._handle_quote()
		else:
			_current_quote = _input[_position]
			return NonLineHandler._handle_quote()

	if _is_current_mode(Syntax.MODE_QSTRING):
		return lineHandler._handle_qtext(self)

	if _input[_position] == ' ':
		return nonLineHandler._handle_space(self)

	if MiscLexerFunctions._is_tab_char(_input[_position]):
		return nonLineHandler._handle_rogue_tab(self)

	if _input[_position] == '(':
		return nonLineHandler._handle_start_variations(self)

	if _input[_position] == ')':
		return nonLineHandler._handle_stop_variations(self)

	if _column == 0 and _input[_position] == '=' and _input[_position + 1] == '=':
		return nonLineHandler._handle_block(self)

	if _input[_position] == '-' and _input[_position + 1] == '>':
		return nonLineHandler._handle_divert(self)

	if _input[_position] == '<' and _input[_position + 1] == '-':
		return nonLineHandler._handle_divert_parent(self)

	if _is_current_mode(Syntax.MODE_VARIATIONS) and _input[_position] == '-':
		return nonLineHandler._handle_variation_item(self)

	if _input[_position] == '*' or _input[_position] == '+' or _input[_position] == '>':
		return lineHandler._handle_options(self)

	if _is_current_mode(Syntax.MODE_OPTION) and _input[_position] == '=':
		return lineHandler._handle_option_display_char(self)

	if _input[_position] == '$':
		return lineHandler._handle_line_id(self)

	if _input[_position] == '#':
		return lineHandler._handle_tag(self)

	return lineHandler._handle_text(self)
