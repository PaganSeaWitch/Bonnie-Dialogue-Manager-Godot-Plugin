class_name Lexer
extends RefCounted

# The handlers for lines recieved 
var line_lexer : LineLexer = LineLexer.new()
var misc_lexer : MiscLexer = MiscLexer.new()
var logic_lexer : LogicLexer = LogicLexer.new()
var option_lexer : OptionLexer = OptionLexer.new()
var variations_lexer : VariationsLexer = VariationsLexer.new()
var dependent_logic_lexer : DependentLogicLexer = DependentLogicLexer.new()

# The data recieved
var input : String = ""

# keeps track of the indentation of the files
var indent: Array[int] = [0]

# The current position of the data in the file
var position: int = 0
var line : int = 0
var column: int = 0
var length : int= 0
var line_with_dependent_logic : int = -1;

func init(_input : String) -> Lexer:
	input = _input
	indent = [0]
	position = 0
	line = 0
	column = 0
	length = _input.length()
	_pending_tokens = []
	line_lexer.init(self)
	misc_lexer.init(self)
	logic_lexer.init(self)
	option_lexer.init(self)
	variations_lexer.init(self)
	dependent_logic_lexer.init(self)
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

	var chr = input[position]
	var inputTillNow = input.substr(0, position)
	# Rule : If -- in not quote mode, consume as comment
	if  (input.substr(position, 2) == '--' 
	&& !is_current_mode(Syntax.MODE_QSTRING)):
		return line_lexer.handle_comments()
	
	# Rule : If \n in not quote mode, consume line break
	if ((chr == '\n' || chr == '\r')
	&& !is_current_mode(Syntax.MODE_QSTRING)):
		return misc_lexer.handle_line_breaks()

	# Rule : If tab at the zeroth columm in not logic mode, consume the indents
	if (((column == 0 && LexerHelperFunctions.is_tab_char(chr)) 
	|| (column == 0 && indent.size() > 1))
	&&  !is_current_mode(Syntax.MODE_LOGIC)):
		return misc_lexer.handle_indent()

	if (chr == '['
	&& !is_current_mode(Syntax.MODE_QSTRING)):
		return dependent_logic_lexer.handle_dependent_logic_block_start()

	# Rule : if { in not quote mode, start logic mode
	if (chr == '{'
	&& !is_current_mode(Syntax.MODE_QSTRING)):
		return logic_lexer.handle_logic_block_start()

	# Rule : if we are in logic mode, consume as a logic block
	if is_current_mode(Syntax.MODE_LOGIC):
		var response : Array[Token] = logic_lexer.handle_logic_block()
		if !response.is_empty():
			return response
 
	# Rule : if " or ', start quote mode
	if (chr == '"' 
	|| chr == "'"):
		if !current_quote.is_empty():
			if chr == current_quote:
				return line_lexer.handle_quote()
		else:
			current_quote = chr
			return line_lexer.handle_quote()

	# Rule : if we are in quote mode, consume text
	if is_current_mode(Syntax.MODE_QSTRING):
		return line_lexer.handle_qtext()

	# Rule : ignore and consume spaces
	if input[position] == ' ':
		return misc_lexer.handle_space()

	# Rule : ignore and consume non logic tabs
	if LexerHelperFunctions.is_tab_char(input[position]):
		return misc_lexer.handle_rogue_tab()
	
	# Rule : if (, start variations mode
	if input[position] == '(':
		return variations_lexer.handle_start_variations()

	# Rule : if ), end variations mode
	if input[position] == ')':
		return variations_lexer.handle_stop_variations()

	# Rule : if == at zeroth column, consume block
	if ((input.substr(position, 2) == '==' 
	|| input.substr(position, 2) == '=+'
	|| input.substr(position, 2) == '=*'
	|| input.substr(position, 2) == '=>') 
	&& column == 0):
		return misc_lexer.handle_block()

	# Rule : if ->, consume divert
	if input.substr(position, 2) == '->':
		return misc_lexer.handle_divert()

	# Rule : if <-, consume parent divert
	if input.substr(position, 2) == '<-':
		return misc_lexer.handle_divert_parent()

	# Rule : if - in variations mode, consume variation  
	if (chr == '-' 
	&& is_current_mode(Syntax.MODE_VARIATIONS)):
		return variations_lexer.handle_variation_item()


	# Rule : if *, +, >, start option mode
	if (chr == '*' 
	|| chr == '+' 
	|| chr == '>'):
		return option_lexer.handle_options()

	# Rule : if = in option mode, consume assign
	if (chr == '=' 
	&& is_current_mode(Syntax.MODE_OPTION)):
		return option_lexer.handle_option_display_char()

	# Rule : if $, consume line id
	if chr == '$':
		return line_lexer.handle_line_id()

	# Rule : if #, consume tag
	if chr == '#':
		return line_lexer.handle_tag()

	# Rule : base case, handle as regular text
	return line_lexer.handle_text()
