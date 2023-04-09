class_name Lexer
extends RefCounted

# The handlers for lines recieved 
var line_handler : LineHandler = LineHandler.new()
var _nonline_handler : NonLineHandler = NonLineHandler.new()
var _logic_handler : LogicHandler = LogicHandler.new()

# The data recieved
var input : String = ""

# keeps track of the indentation of the files
var indent: Array[int] = [0]

# The current position of the data in the file
var position: int = 0
var line : int = 0
var column: int = 0
var length : int= 0


func init(_input : String) -> Lexer:
	input = _input
	indent = [0]
	position = 0
	line = 0
	column = 0
	length = _input.length()
	_pending_tokens = []

	return self


# Tokens we have yet to process
var _pending_tokens : Array = []


# The current modes
var modes : Array[String]= [ Syntax.MODE_DEFAULT ]


# The current quote
var current_quote : String = ""


# Gets the error hint for a token
static func get_token_friendly_hint(tokenName : String) -> String:
	return Syntax.token_hints.get(tokenName, tokenName)


# Gets all tokens from a file
func get_all() -> Array[Token]:
	var tokens : Array[Token]= []
	while position < length:
		var new_tokens : Array[Token] = _get_next_tokens()
		tokens.append_array(new_tokens)

	position += 1
	tokens.push_back(Token.new(Syntax.TOKEN_EOF, line, column))

	return tokens


# Gets the next token
func next() -> Token:
	if _pending_tokens.size() > 0:
		return _pending_tokens.pop_front()

	while position < length:
		var tokens = _get_next_tokens()
		if !tokens.is_empty():
			_pending_tokens = tokens
			return _pending_tokens.pop_front()


	if(position == input.length() + 1):
		return null
	position += 1
	return Token.new(Syntax.TOKEN_EOF, line, column)


# Puts a mode at the top of the stack
func stack_mode(mode : String):
	modes.push_front(mode)


# removes top mode from stack
func pop_mode():
	if modes.size() > 1:
		modes.pop_front()


# Checks whether top mode in stack is mode
func is_current_mode(mode : String):
	return modes[0] == mode


# Returns an array of tokens gotten from input
func _get_next_tokens() -> Array[Token]:
	
	# Rule : If -- in not quote mode, consume as comment
	if  (input.substr(position, 2) == '--' 
	&& !is_current_mode(Syntax.MODE_QSTRING)):
		return line_handler.handle_comments(self)
	
	# Rule : If \n in not quote mode, consume line break
	if (input[position] == '\n'
	&& !is_current_mode(Syntax.MODE_QSTRING)):
		return _nonline_handler.handle_line_breaks(self)

	# Rule : If tab at the zeroth columm in not logic mode, consume the indents
	if (((column == 0 && MiscLexerFunctions.is_tab_char(input[position])) 
	|| (column == 0 && indent.size() > 1))
	&&  !is_current_mode(Syntax.MODE_LOGIC)):
		return _nonline_handler.handle_indent(self)

	# Rule : if { in not quote mode, start logic mode
	if (input[position] == '{'
	&& !is_current_mode(Syntax.MODE_QSTRING)):
		return _logic_handler.handle_logic_block_start(self)

	# Rule : if we are in logic mode, consume as a logic block
	if is_current_mode(Syntax.MODE_LOGIC):
		var response : Array[Token] = _logic_handler.handle_logic_block(self)
		if !response.is_empty():
			return response
 
	# Rule : if " or ', start quote mode
	if (input[position] == '"' 
	|| input[position] == "'"):
		if !current_quote.is_empty():
			if input[position] == current_quote:
				return line_handler.handle_quote(self)
		else:
			current_quote = input[position]
			return line_handler.handle_quote(self)

	# Rule : if we are in quote mode, consume text
	if is_current_mode(Syntax.MODE_QSTRING):
		return line_handler.handle_qtext(self)

	# Rule : ignore and consume spaces
	if input[position] == ' ':
		return _nonline_handler.handle_space(self)

	# Rule : ignore and consume non logic tabs
	if MiscLexerFunctions.is_tab_char(input[position]):
		return _nonline_handler.handle_rogue_tab(self)
	
	# Rule : if (, start variations mode
	if input[position] == '(':
		return _nonline_handler.handle_start_variations(self)

	# Rule : if ), end variations mode
	if input[position] == ')':
		return _nonline_handler.handle_stop_variations(self)

	# Rule : if == at zeroth column, consume block
	if ((input.substr(position, 2) == '==' 
	|| input.substr(position, 2) == '=+'
	|| input.substr(position, 2) == '=*'
	|| input.substr(position, 2) == '=>') 
	&& column == 0):
		return _nonline_handler.handle_block(self)

	# Rule : if ->, consume divert
	if input.substr(position, 2) == '->':
		return _nonline_handler.handle_divert(self)

	# Rule : if <-, consume parent divert
	if input.substr(position, 2) == '<-':
		return _nonline_handler.handle_divert_parent(self)

	# Rule : if - in variations mode, consume variation  
	if (input[position] == '-' 
	&& is_current_mode(Syntax.MODE_VARIATIONS)):
		return _nonline_handler.handle_variation_item(self)


	# Rule : if *, +, >, start option mode
	if (input[position] == '*' 
	|| input[position] == '+' 
	|| input[position] == '>'):
		return line_handler.handle_options(self)

	# Rule : if = in option mode, consume assign
	if (input[position] == '=' 
	&& is_current_mode(Syntax.MODE_OPTION)):
		return line_handler.handle_option_display_char(self)

	# Rule : if $, consume line id
	if input[position] == '$':
		return line_handler.handle_line_id(self)

	# Rule : if #, consume tag
	if input[position] == '#':
		return line_handler.handle_tag(self)

	# Rule : base case, handle as regular text
	return line_handler.handle_text(self)
