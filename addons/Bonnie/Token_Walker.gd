class_name TokenWalker
extends RefCounted


var _lexer : BonnieLexer

# The current token that is being consumed
var current_token : Token;

# An array of tokens ordered by creation
var _look_ahead_lexer : Array[Token]= [];
var is_multiline_enabled : bool = true


func set_lexer(l : BonnieLexer) -> void:
	_lexer = l

# Returns the next token the lexer has produced
func consume(expected : Array[String] = []) -> Token:
	if _look_ahead_lexer.size() == 0:
		_look_ahead_lexer.push_back(_lexer.next())

	var look_ahead_token : Token = _look_ahead_lexer.pop_front()

	if (!expected.is_empty() 
	&& (look_ahead_token == null 
	|| !expected.has(look_ahead_token.name))):
		_wrong_token_error(look_ahead_token, expected)

	current_token = look_ahead_token;
	return current_token

# Gets the next token without consuming it
func peek(expected : Array[String] = [], offset : int = 0) -> Token:
	# Look thru the look ahead lexer for next usable token
	while _look_ahead_lexer.size() < (offset + 1):
		var token : Token = _lexer.next();
		if token != null:
			_look_ahead_lexer.push_back(token);
		else:
			break

	# Get the token without removing it from the array
	var look_ahead_token : Token = _look_ahead_lexer[offset] if _look_ahead_lexer.size() > offset else null

	if (expected.is_empty() 
	|| (look_ahead_token != null 
	&& expected.has(look_ahead_token.name))):
		return look_ahead_token
	
	return null

# Produces a error that informs you where a tokenization error occured
func _wrong_token_error(token : Token, expected : Array[String]) -> void:
	var expected_hints : Array[String]= []
	for e in expected:
		expected_hints.push_back(BonnieLexer.get_token_friendly_hint(e))

	assert(false,
		"Unexpected token \"%s\" checked line %s column %s. Expected %s" % [
			BonnieLexer.get_token_friendly_hint(token.name),
			token.line+1,
			token.column+1,
			expected_hints
		]
	)
