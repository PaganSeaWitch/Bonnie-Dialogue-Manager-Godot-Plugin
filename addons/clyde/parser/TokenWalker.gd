class_name TokenWalker
extends RefCounted


var lexer : Lexer
var current_token : Token;
var _lookadhedlexer : Array[Token]= [];
var _is_multiline_enabled : bool = true


func setLexer(l : Lexer) -> void:
	lexer = l


func consume(expected : Array[String] = [] ) -> Token:
	if !_lookadhedlexer.size():
		_lookadhedlexer.push_back(lexer.next())

	var lookahead : Token = _lookadhedlexer.pop_front()

	if expected.is_empty() == false && (!lookahead || !expected.has(lookahead.token)):
		_wrong_token_error(lookahead, expected)

	current_token = lookahead;
	return current_token


func peek(expected : Array[String] = [], offset : int = 0) -> Token:
	while _lookadhedlexer.size() < (offset + 1):
		var token : Token = lexer.next();
		if token:
			_lookadhedlexer.push_back(token);
		else:
			break

	var lookahead : Token = _lookadhedlexer[offset] if _lookadhedlexer.size() > offset else null

	if expected.is_empty() || (lookahead != null && expected.has(lookahead.token)):
		return lookahead
	
	return null


func _wrong_token_error(token : Token, expected : Array[String]) -> void:
	var expected_hints : Array[String]= []
	for e in expected:
		expected_hints.push_back(Lexer.get_token_friendly_hint(e))

	assert(false,
		"Unexpected token \"%s\" checked line %s column %s. Expected %s" % [
			Lexer.get_token_friendly_hint(token.token),
			token.line+1,
			token.column+1,
			expected_hints
		]
	)
