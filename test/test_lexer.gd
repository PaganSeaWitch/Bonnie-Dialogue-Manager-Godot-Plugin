extends "res://addons/gut/test.gd"




func test_text():
	var lexer = Lexer.new()
	var tokens = lexer.init('this is a line').get_all()
	var jsonTokens : Array = []
	for token in tokens:
		jsonTokens.append(Token.to_JSON_object(token))
	assert_eq_deep(jsonTokens.size(), 2)
	assert_eq_deep(jsonTokens[0], {
		"name": Syntax.TOKEN_TEXT,
		"value": "this is a line",
		"line": 0,
		"column": 0,
	})

func test_text_with_multiple_lines():
	var lexer = Lexer.new()
	var tokens = lexer.init('this is a line\nthis is another line 2').get_all()
	var jsonTokens : Array = []
	for token in tokens:
		jsonTokens.append(Token.to_JSON_object(token))
	assert_eq_deep(jsonTokens.size(), 3)
	assert_eq_deep(jsonTokens[0], {
		"name": Syntax.TOKEN_TEXT,
		"value": 'this is a line',
		"line": 0,
		"column": 0,
	})
	assert_eq_deep(jsonTokens[1], {
		"name": Syntax.TOKEN_TEXT,
		"value": 'this is another line 2',
		"line": 1,
		"column": 0
	})

func test_text_with_quotes():
	var lexer = Lexer.new()
	var tokens = lexer.init('"this is a line with: special# characters $.\\" Enjoy"').get_all()

	var jsonTokens : Array = []
	for token in tokens:
		jsonTokens.append(Token.to_JSON_object(token))
	assert_eq_deep(jsonTokens, [
		{
			"name": Syntax.TOKEN_TEXT,
			"value": 'this is a line with: special# characters $." Enjoy',
			"line": 0,
			"column": 1,
		},
		{ "name": Syntax.TOKEN_EOF, "line": 0, "column": 53, "value": "" },
	])

func test_text_with_single_quotes():
	var lexer = Lexer.new()
	var tokens = lexer.init("'this is a line with: special# characters $.\\' Enjoy'").get_all()
	var jsonTokens : Array = []
	for token in tokens:
		jsonTokens.append(Token.to_JSON_object(token))
	assert_eq_deep(jsonTokens, [
		{
			"name": Syntax.TOKEN_TEXT,
			"value": "this is a line with: special# characters $.' Enjoy",
			"line": 0,
			"column": 1,
		},
		{ "name": Syntax.TOKEN_EOF, "line": 0, "column": 53, "value": "" },
	])


func test_text_with_both_leading_quote_types():
	var lexer = Lexer.new()
	var tokens = lexer.init("\"'this' is a 'line'\"").get_all()
	
	var jsonTokens : Array = []
	for token in tokens:
		jsonTokens.append(Token.to_JSON_object(token))
	assert_eq_deep(jsonTokens, [
		{
			"name": Syntax.TOKEN_TEXT,
			"value": "'this' is a 'line'",
			"line": 0,
			"column": 1,
		},
		{ "name": Syntax.TOKEN_EOF, "line": 0, "column": 20, "value": "" },
	])
	tokens = lexer.init('\'this is a "line"\'').get_all()
	jsonTokens = []
	for token in tokens:
		jsonTokens.append(Token.to_JSON_object(token))
	assert_eq_deep(jsonTokens, [
		{
			"name": Syntax.TOKEN_TEXT,
			"value": 'this is a "line"',
			"line": 0,
			"column": 1,
		},
		{ "name": Syntax.TOKEN_EOF, "line": 0, "column": 18, "value": "" },
	])


func test_variable_with_both_quote_types():
	var lexer = Lexer.new()
	var tokens = lexer.init("{ set characters = '{\"name\": \"brain\"}' }").get_all()
	
	var jsonTokens : Array = []
	for token in tokens:
		jsonTokens.append(Token.to_JSON_object(token))
	assert_eq_deep(jsonTokens, [
		{"column":0, "line":0, "name":Syntax.TOKEN_BRACE_OPEN, "value": ""},
		{"column":2, "line":0, "name":Syntax.TOKEN_KEYWORD_SET, "value": ""},
		{"column":6, "line":0, "name":Syntax.TOKEN_IDENTIFIER, "value":"characters"},
		{"column":17, "line":0, "name":Syntax.TOKEN_ASSIGN, "value": ""},
		{"column":19, "line":0, "name":Syntax.TOKEN_STRING_LITERAL, "value": '{"name": "brain"}' },
		{"column":39, "line":0, "name":Syntax.TOKEN_BRACE_CLOSE, "value": ""},
		{"column":40, "line":0, "name":Syntax.TOKEN_EOF, "value": ""}
	])


func test_escape_characters_in_regular_text():
	var lexer = Lexer.new()
	var tokens = lexer.init('this is a line with\\: special\\# characters \\$.\\" Enjoy').get_all()
	
	var jsonTokens : Array = []
	for token in tokens:
		jsonTokens.append(Token.to_JSON_object(token))
	
	assert_eq_deep(jsonTokens, [
		{
			"name": Syntax.TOKEN_TEXT,
			"value": 'this is a line with: special# characters $." Enjoy',
			"line": 0,
			"column": 0,
		},
		{ "name": Syntax.TOKEN_EOF, "line": 0, "column": 54, "value": "" },
	])


func test_count_lines_correctly_in_quotted_text_with_line_breaks():
	var lexer = Lexer.new()
	var tokens = lexer.init('"this is a line with\nline break"\nthis should be on line 2').get_all()
	
	var jsonTokens : Array = []
	for token in tokens:
		jsonTokens.append(Token.to_JSON_object(token))
	
	assert_eq_deep(jsonTokens, [
		{
			"name": Syntax.TOKEN_TEXT,
			"value": 'this is a line with\nline break',
			"line": 0,
			"column": 1,
			},
		{
			"name": Syntax.TOKEN_TEXT,
			"value": 'this should be on line 2',
			"line": 2,
			"column": 0,
			},
		{ "name": Syntax.TOKEN_EOF, "line": 2, "column": 24, "value": "" },
	])


func test_ignores_comments():
	var lexer = Lexer.new()
	var tokens = lexer.init("""-- this is a comment
-- this is another comment
this is a line
-- this is a third comment
this is another line 2
-- another one
""").get_all()
	var jsonTokens : Array = []
	for token in tokens:
		jsonTokens.append(Token.to_JSON_object(token))
	assert_eq_deep(jsonTokens.size(), 3)
	assert_eq_deep(jsonTokens[0], {
		"name": Syntax.TOKEN_TEXT,
		"value": 'this is a line',
		"line": 2,
		"column": 0,
	})
	assert_eq_deep(jsonTokens[1], {
		"name": Syntax.TOKEN_TEXT,
		"value": 'this is another line 2',
		"line": 4,
		"column": 0
	})

func test_count_lines_correctly():
	var lexer = Lexer.new()
	var tokens = lexer.init("""-- this is a comment
-- this is another comment
this is a line
-- this is a third comment
this is another line 2
"this is another line 3"
this is another line 4
-- another one
""").get_all()


	var jsonTokens : Array = []
	for token in tokens:
		jsonTokens.append(Token.to_JSON_object(token))
		
		
	assert_eq_deep(jsonTokens, [
		{ "name": Syntax.TOKEN_TEXT, "value": 'this is a line', "line": 2, "column": 0, },
		{ "name": Syntax.TOKEN_TEXT, "value": 'this is another line 2', "line": 4, "column": 0 },
		{ "name": Syntax.TOKEN_TEXT, "value": 'this is another line 3', "line": 5, "column": 1 },
		{ "name": Syntax.TOKEN_TEXT, "value": 'this is another line 4', "line": 6, "column": 0 },
		{ "name": Syntax.TOKEN_EOF, "line": 8, "column": 0, "value": "" },
	])


func test_detects_indents_and_dedents():
	var lexer = Lexer.new()
	var tokens = lexer.init("""normal line
				indented line
				indented line
						another indent
				now a dedent
now another dedent
		indent again
				one more time
dedent all the way
		tab test
he he
""").get_all()


	var jsonTokens : Array = []
	for token in tokens:
		jsonTokens.append(Token.to_JSON_object(token))

	assert_eq_deep(jsonTokens, [
		{ "name": Syntax.TOKEN_TEXT, "value": 'normal line', "line": 0, "column": 0, },
		{ "name": Syntax.TOKEN_INDENT, "line": 1, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_TEXT, "value": 'indented line', "line": 1, "column": 4 },
		{ "name": Syntax.TOKEN_TEXT, "value": 'indented line', "line": 2, "column": 4 },
		{ "name": Syntax.TOKEN_INDENT, "line": 3, "column": 4, "value": "" },
		{ "name": Syntax.TOKEN_TEXT, "value": 'another indent', "line": 3, "column": 6 },
		{ "name": Syntax.TOKEN_DEDENT, "line": 4, "column": 4, "value": "" },
		{ "name": Syntax.TOKEN_TEXT, "value": 'now a dedent', "line": 4, "column": 4 },
		{ "name": Syntax.TOKEN_DEDENT, "line": 5, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_TEXT, "value": 'now another dedent', "line": 5, "column": 0 },
		{ "name": Syntax.TOKEN_INDENT, "line": 6, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_TEXT, "value": 'indent again', "line": 6, "column": 2 },
		{ "name": Syntax.TOKEN_INDENT, "line": 7, "column": 2, "value": "" },
		{ "name": Syntax.TOKEN_TEXT, "value": 'one more time', "line": 7, "column": 4 },
		{ "name": Syntax.TOKEN_DEDENT, "line": 8, "column": 2, "value": "" },
		{ "name": Syntax.TOKEN_DEDENT, "line": 8, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_TEXT, "value": 'dedent all the way', "line": 8, "column": 0 },
		{ "name": Syntax.TOKEN_INDENT, "line": 9, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_TEXT, "value": 'tab test', "line": 9, "column": 2 },
		{ "name": Syntax.TOKEN_DEDENT, "line": 10, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_TEXT, "value": 'he he', "line": 10, "column": 0 },
		{ "name": Syntax.TOKEN_EOF, "line": 11, "column": 0, "value": "" },
	])


func test_detects_indents_and_dedents_after_quoted_options():
	var lexer = Lexer.new()
	var tokens = lexer.init("""
\"indented line\"
		* indented line
				hello

\"indented line\"
		* indented line
				hello
""").get_all()

	var jsonTokens : Array = []
	for token in tokens:
		jsonTokens.append(Token.to_JSON_object(token))

	assert_eq_deep(jsonTokens, [
		{ "name": Syntax.TOKEN_TEXT, "value": 'indented line', "line": 1, "column": 1, },
		{ "name": Syntax.TOKEN_INDENT, "line": 2, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_OPTION, "line": 2, "column": 2, "value": "" },
		{ "name": Syntax.TOKEN_TEXT, "value": 'indented line', "line": 2, "column": 4 },
		{ "name": Syntax.TOKEN_INDENT, "line": 3, "column": 2, "value": "" },
		{ "name": Syntax.TOKEN_TEXT, "value": 'hello', "line": 3, "column": 4 },
		{ "name": Syntax.TOKEN_DEDENT, "line": 5, "column": 2, "value": "" },
		{ "name": Syntax.TOKEN_DEDENT, "line": 5, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_TEXT, "value": 'indented line', "line": 5, "column": 1, },
		{ "name": Syntax.TOKEN_INDENT, "line": 6, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_OPTION, "line": 6, "column": 2, "value": "" },
		{ "name": Syntax.TOKEN_TEXT, "value": 'indented line', "line": 6, "column": 4 },
		{ "name": Syntax.TOKEN_INDENT, "line": 7, "column": 2, "value": "" },
		{ "name": Syntax.TOKEN_TEXT, "value": 'hello', "line": 7, "column": 4 },
		{ "name": Syntax.TOKEN_EOF, "line": 8, "column": 0, "value": "" },
	])


func test_returns_EOF():
	var lexer = Lexer.new()
	var tokens = lexer.init("normal line")

	assert_eq_deep(Token.to_JSON_object(tokens.next()), { "name": Syntax.TOKEN_TEXT, "value": 'normal line', "line": 0, "column": 0, })
	assert_eq_deep(Token.to_JSON_object(tokens.next()),{ "name": Syntax.TOKEN_EOF, "line": 0, "column": 11, "value": "" })
	assert_eq_deep(tokens.next(), null)

func test_options():
	var lexer = Lexer.new()
	var tokens = lexer.init("""
this is something
		* this is another thing
				hello
		+ this is a sticky option
				hello again
* a whole new list
		hello
*= hello
		hi
		this is just some text with [ brackets ]
		and this is some text with * and + and >
> this is a fallback
""").get_all()

	var jsonTokens : Array = []
	for token in tokens:
		jsonTokens.append(Token.to_JSON_object(token))

	assert_eq_deep(jsonTokens, [
		{ "name": Syntax.TOKEN_TEXT, "value": 'this is something', "line": 1, "column": 0 },
		{ "name": Syntax.TOKEN_INDENT, "line": 2, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_OPTION, "line": 2, "column": 2, "value": "" },
		{ "name": Syntax.TOKEN_TEXT, "value": 'this is another thing', "line": 2, "column": 4 },
		{ "name": Syntax.TOKEN_INDENT, "line": 3, "column": 2, "value": "" },
		{ "name": Syntax.TOKEN_TEXT, "value": 'hello', "line": 3, "column": 4 },
		{ "name": Syntax.TOKEN_DEDENT, "line": 4, "column": 2, "value": "" },
		{ "name": Syntax.TOKEN_STICKY_OPTION, "line": 4, "column": 2, "value": "" },
		{ "name": Syntax.TOKEN_TEXT, "value": 'this is a sticky option', "line": 4, "column": 4 },
		{ "name": Syntax.TOKEN_INDENT, "line": 5, "column": 2, "value": "" },
		{ "name": Syntax.TOKEN_TEXT, "value": 'hello again', "line": 5, "column": 4 },
		{ "name": Syntax.TOKEN_DEDENT, "line": 6, "column": 2, "value": "" },
		{ "name": Syntax.TOKEN_DEDENT, "line": 6, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_OPTION, "line": 6, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_TEXT, "value": 'a whole new list', "line": 6, "column": 2 },
		{ "name": Syntax.TOKEN_INDENT, "line": 7, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_TEXT, "value": 'hello', "line": 7, "column": 2 },
		{ "name": Syntax.TOKEN_DEDENT, "line": 8, "column": 0 , "value": ""},
		{ "name": Syntax.TOKEN_OPTION, "line": 8, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_ASSIGN, "line": 8, "column": 1, "value": "" },
		{ "name": Syntax.TOKEN_TEXT, "value": 'hello', "line": 8, "column": 3 },
		{ "name": Syntax.TOKEN_INDENT, "line": 9, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_TEXT, "value": 'hi', "line": 9, "column": 2 },
		{ "name": Syntax.TOKEN_TEXT, "value": 'this is just some text with [ brackets ]', "line": 10, "column": 2 },
		{ "name": Syntax.TOKEN_TEXT, "value": 'and this is some text with * and + and >', "line": 11, "column": 2 },
		{ "name": Syntax.TOKEN_DEDENT, "line": 12, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_FALLBACK_OPTION, "line": 12, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_TEXT, "value": 'this is a fallback', "line": 12, "column": 2 },
		{ "name": Syntax.TOKEN_EOF, "line": 13, "column": 0, "value": "" },
	])


func test_speaker():
	var lexer = Lexer.new()
	var tokens = lexer.init("""
speaker1: this is something
		* speaker2: this is another thing
				speaker3: hello
		+ speaker4: this is a sticky option
*= speaker5: hello
		speaker 1: this is ok
""").get_all()

	var jsonTokens : Array = []
	for token in tokens:
		jsonTokens.append(Token.to_JSON_object(token))
	assert_eq_deep(jsonTokens, [
		{ "name": Syntax.TOKEN_SPEAKER, "value": 'speaker1', "line": 1, "column": 0 },
		{ "name": Syntax.TOKEN_TEXT, "value": 'this is something', "line": 1, "column": 10 },
		{ "name": Syntax.TOKEN_INDENT, "line": 2, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_OPTION, "line": 2, "column": 2, "value": "" },
		{ "name": Syntax.TOKEN_SPEAKER, "value": 'speaker2', "line": 2, "column": 4 },
		{ "name": Syntax.TOKEN_TEXT, "value": 'this is another thing', "line": 2, "column": 14 },
		{ "name": Syntax.TOKEN_INDENT, "line": 3, "column": 2, "value": "" },
		{ "name": Syntax.TOKEN_SPEAKER, "value": 'speaker3', "line": 3, "column": 4 },
		{ "name": Syntax.TOKEN_TEXT, "value": 'hello', "line": 3, "column": 14 },
		{ "name": Syntax.TOKEN_DEDENT, "line": 4, "column": 2, "value": "" },
		{ "name": Syntax.TOKEN_STICKY_OPTION, "line": 4, "column": 2, "value": "" },
		{ "name": Syntax.TOKEN_SPEAKER, "value": 'speaker4', "line": 4, "column": 4 },
		{ "name": Syntax.TOKEN_TEXT, "value": 'this is a sticky option', "line": 4, "column": 14 },
		{ "name": Syntax.TOKEN_DEDENT, "line": 5, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_OPTION, "line": 5, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_ASSIGN, "line": 5, "column": 1, "value": "" },
		{ "name": Syntax.TOKEN_SPEAKER, "value": 'speaker5', "line": 5, "column": 3 },
		{ "name": Syntax.TOKEN_TEXT, "value": 'hello', "line": 5, "column": 13 },
		{ "name": Syntax.TOKEN_INDENT, "line": 6, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_SPEAKER, "value": 'speaker 1', "line": 6, "column": 2 },
		{ "name": Syntax.TOKEN_TEXT, "value": 'this is ok', "line": 6, "column": 13 },
		{ "name": Syntax.TOKEN_EOF, "line": 7, "column": 0, "value": "" },
	])

func test_line_id():
	var lexer = Lexer.new()
	var tokens = lexer.init("""
speaker1: this is something $123
* this is another thing $abc
*= hello $a1b2
speaker1: this is something $123""").get_all()

	var jsonTokens : Array = []
	for token in tokens:
		jsonTokens.append(Token.to_JSON_object(token))
	assert_eq_deep(jsonTokens, [
		{ "name": Syntax.TOKEN_SPEAKER, "value": 'speaker1', "line": 1, "column": 0 },
		{ "name": Syntax.TOKEN_TEXT, "value": 'this is something', "line": 1, "column": 10 },
		{ "name": Syntax.TOKEN_LINE_ID, "value": '123', "line": 1, "column": 28 },
		{ "name": Syntax.TOKEN_OPTION, "line": 2, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_TEXT, "value": 'this is another thing', "line": 2, "column": 2 },
		{ "name": Syntax.TOKEN_LINE_ID, "value": 'abc', "line": 2, "column": 24 },
		{ "name": Syntax.TOKEN_OPTION, "line": 3, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_ASSIGN, "line": 3, "column": 1, "value": "" },
		{ "name": Syntax.TOKEN_TEXT, "value": 'hello', "line": 3, "column": 3 },
		{ "name": Syntax.TOKEN_LINE_ID, "value": 'a1b2', "line": 3, "column": 9 },
		{ "name": Syntax.TOKEN_SPEAKER, "value": 'speaker1', "line": 4, "column": 0 },
		{ "name": Syntax.TOKEN_TEXT, "value": 'this is something', "line": 4, "column": 10 },
		{ "name": Syntax.TOKEN_LINE_ID, "value": '123', "line": 4, "column": 28 },
		{ "name": Syntax.TOKEN_EOF, "line": 4, "column": 32, "value": "" },
	])


func test_id_suffixes():
	var lexer = Lexer.new()
	var tokens = lexer.init("""
speaker1: this is something $123&var1
* this is another thing $abc&var1&var2
*= hello $a1b2&var1 #tag""").get_all()


	var jsonTokens : Array = []
	for token in tokens:
		jsonTokens.append(Token.to_JSON_object(token))
	assert_eq_deep(jsonTokens, [
		{ "name": Syntax.TOKEN_SPEAKER, "value": 'speaker1', "line": 1, "column": 0 },
		{ "name": Syntax.TOKEN_TEXT, "value": 'this is something', "line": 1, "column": 10 },
		{ "name": Syntax.TOKEN_LINE_ID, "value": '123', "line": 1, "column": 28 },
		{ "name": Syntax.TOKEN_ID_SUFFIX, "value": 'var1', "line": 1, "column": 32 },
		{ "name": Syntax.TOKEN_OPTION, "line": 2, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_TEXT, "value": 'this is another thing', "line": 2, "column": 2 },
		{ "name": Syntax.TOKEN_LINE_ID, "value": 'abc', "line": 2, "column": 24 },
		{ "name": Syntax.TOKEN_ID_SUFFIX, "value": 'var1', "line": 2, "column": 28 },
		{ "name": Syntax.TOKEN_ID_SUFFIX, "value": 'var2', "line": 2, "column": 33 },
		{ "name": Syntax.TOKEN_OPTION, "line": 3, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_ASSIGN, "line": 3, "column": 1, "value": "" },
		{ "name": Syntax.TOKEN_TEXT, "value": 'hello', "line": 3, "column": 3 },
		{ "name": Syntax.TOKEN_LINE_ID, "value": 'a1b2', "line": 3, "column": 9 },
		{ "name": Syntax.TOKEN_ID_SUFFIX, "value": 'var1', "line": 3, "column": 14 },
		{ "name": Syntax.TOKEN_TAG, "value": 'tag', "line": 3, "column": 20 },
		{ "name": Syntax.TOKEN_EOF, "line": 3, "column": 24, "value": "" },
	]);


func test_tags():
	var lexer = Lexer.new()
	var tokens = lexer.init("""
this is something #hello #happy #something_else
""").get_all()


	var jsonTokens : Array = []
	for token in tokens:
		jsonTokens.append(Token.to_JSON_object(token))
	assert_eq_deep(jsonTokens, [
		{ "name": Syntax.TOKEN_TEXT, "value": 'this is something', "line": 1, "column": 0 },
		{ "name": Syntax.TOKEN_TAG, "value": 'hello', "line": 1, "column": 18 },
		{ "name": Syntax.TOKEN_TAG, "value": 'happy', "line": 1, "column": 25 },
		{ "name": Syntax.TOKEN_TAG, "value": 'something_else', "line": 1, "column": 32 },
		{ "name": Syntax.TOKEN_EOF, "line": 2, "column": 0, "value": "" },
	])


func test_blocks():
	var lexer = Lexer.new()
	var tokens = lexer.init("""
== first_block
line
line 2

== second block
line 3
line 4
""").get_all()


	var jsonTokens : Array = []
	for token in tokens:
		jsonTokens.append(Token.to_JSON_object(token))
	assert_eq_deep(jsonTokens, [
		{ "name": Syntax.TOKEN_BLOCK, "value": 'first_block', "line": 1, "column": 0, },
		{ "name": Syntax.TOKEN_TEXT, "value": 'line', "line": 2, "column": 0, },
		{ "name": Syntax.TOKEN_TEXT, "value": 'line 2', "line": 3, "column": 0, },
		{ "name": Syntax.TOKEN_BLOCK, "value": 'second block', "line": 5, "column": 0, },
		{ "name": Syntax.TOKEN_TEXT, "value": 'line 3', "line": 6, "column": 0, },
		{ "name": Syntax.TOKEN_TEXT, "value": 'line 4', "line": 7, "column": 0, },
		{ "name": Syntax.TOKEN_EOF, "line": 8, "column": 0, "value": "" },
	])


func test_diverts():
	var lexer = Lexer.new()
	var tokens = lexer.init("""
hello
-> first divert

* test
		-> divert
		<-
		-> END
""").get_all()


	var jsonTokens : Array = []
	for token in tokens:
		jsonTokens.append(Token.to_JSON_object(token))
	assert_eq_deep(jsonTokens, [
		{ "name": Syntax.TOKEN_TEXT, "value": 'hello', "line": 1, "column": 0, },
		{ "name": Syntax.TOKEN_DIVERT, "value": 'first divert', "line": 2, "column": 0, },
		{ "name": Syntax.TOKEN_LINE_BREAK, "value": "", "line": 2, "column": 15, },
		{ "name": Syntax.TOKEN_OPTION, "line": 4, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_TEXT, "value": 'test', "line": 4, "column": 2 },
		{ "name": Syntax.TOKEN_INDENT, "line": 5, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_DIVERT, "value": 'divert', "line": 5, "column": 2 },
		{ "name": Syntax.TOKEN_LINE_BREAK, "value": "", "line": 5, "column": 11, },
		{ "name": Syntax.TOKEN_DIVERT_PARENT, "line": 6, "column": 2, "value": "" },
		{ "name": Syntax.TOKEN_LINE_BREAK, "value": "", "line": 6, "column": 4, },
		{ "name": Syntax.TOKEN_DIVERT, "value": 'END', "line": 7, "column": 2 },
		{ "name": Syntax.TOKEN_LINE_BREAK, "value": "", "line": 7, "column": 8, },
		{ "name": Syntax.TOKEN_EOF, "line": 8, "column": 0, "value": ""},
	])


func test_divert_on_eof():
	var lexer = Lexer.new()
	var tokens = lexer.init("-> div").get_all()
	
	var jsonTokens : Array = []
	for token in tokens:
		jsonTokens.append(Token.to_JSON_object(token))
	assert_eq_deep(jsonTokens, [
		{ "name": Syntax.TOKEN_DIVERT, "value": 'div', "line": 0, "column": 0, },
		{ "name": Syntax.TOKEN_EOF, "line": 0, "column": 6, "value": ""},
	])


func test_divert_parent_on_eof():
	var lexer = Lexer.new()
	var tokens = lexer.init("<-").get_all()
	
	var jsonTokens : Array = []
	for token in tokens:
		jsonTokens.append(Token.to_JSON_object(token))
	assert_eq_deep(jsonTokens, [
		{ "name": Syntax.TOKEN_DIVERT_PARENT, "value": "", "line": 0, "column": 0, },
		{ "name": Syntax.TOKEN_EOF, "line": 0, "column": 2, "value": ""},
	])


func test_variations():
	var lexer = Lexer.new()
	var tokens = lexer.init("""
(
		- nope
		- yep
)

( shuffle
		- -> nope
		- yep
)

( shuffle once
		- nope
		- yep
		(
				- "another one"
		)
)

""").get_all()

	var jsonTokens : Array = []
	for token in tokens:
		jsonTokens.append(Token.to_JSON_object(token))
	assert_eq_deep(jsonTokens, [
		{ "name": Syntax.TOKEN_BRACKET_OPEN, "line": 1, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_INDENT, "line": 2, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_MINUS, "line": 2, "column": 2, "value": "" },
		{ "name": Syntax.TOKEN_TEXT, "value": 'nope', "line": 2, "column": 4 },
		{ "name": Syntax.TOKEN_MINUS, "line": 3, "column": 2, "value": "" },
		{ "name": Syntax.TOKEN_TEXT, "value": 'yep', "line": 3, "column": 4 },
		{ "name": Syntax.TOKEN_DEDENT, "line": 4, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_BRACKET_CLOSE, "line": 4, "column": 0, "value": "" },

		{ "name": Syntax.TOKEN_BRACKET_OPEN, "line": 6, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_VARIATIONS_MODE, "value": 'shuffle', "line": 6, "column": 2, },
		{ "name": Syntax.TOKEN_INDENT, "line": 7, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_MINUS, "line": 7, "column": 2, "value": "" },
		{ "name": Syntax.TOKEN_DIVERT, "value": 'nope', "line": 7, "column": 4 },
		{ "name": Syntax.TOKEN_LINE_BREAK, "value": "", "line": 7, "column": 11, },
		{ "name": Syntax.TOKEN_MINUS, "line": 8, "column": 2, "value": "", },
		{ "name": Syntax.TOKEN_TEXT, "value": 'yep', "line": 8, "column": 4 },
		{ "name": Syntax.TOKEN_DEDENT, "line": 9, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_BRACKET_CLOSE, "line": 9, "column": 0, "value": "", },

		{ "name": Syntax.TOKEN_BRACKET_OPEN, "line": 11, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_VARIATIONS_MODE, "value": 'shuffle once', "line": 11, "column": 2, },
		{ "name": Syntax.TOKEN_INDENT, "line": 12, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_MINUS, "line": 12, "column": 2, "value": "", },
		{ "name": Syntax.TOKEN_TEXT, "value": 'nope', "line": 12, "column": 4 },
		{ "name": Syntax.TOKEN_MINUS, "line": 13, "column": 2, "value": "", },
		{ "name": Syntax.TOKEN_TEXT, "value": 'yep', "line": 13, "column": 4 },

		{ "name": Syntax.TOKEN_BRACKET_OPEN, "line": 14, "column": 2, "value": "", },
		{ "name": Syntax.TOKEN_INDENT, "line": 15, "column": 2, "value": "" },
		{ "name": Syntax.TOKEN_MINUS, "line": 15, "column": 4, "value": "", },

		{ "name": Syntax.TOKEN_TEXT, "value": 'another one', "line": 15, "column": 7 },

		{ "name": Syntax.TOKEN_DEDENT, "line": 16, "column": 2, "value": "" },
		{ "name": Syntax.TOKEN_BRACKET_CLOSE, "line": 16, "column": 2, "value": "", },

		{ "name": Syntax.TOKEN_DEDENT, "line": 17, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_BRACKET_CLOSE, "line": 17, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_EOF, "line": 19, "column": 0, "value": "" },

	])



func test_variables_conditions():
	var lexer = Lexer.new()
	var tokens = lexer.init("""
{ variable }
{ not variable }
{ !variable }
{ variable == variable2 }
{ variable != variable2 }
{ variable && variable2 }
{ variable || variable2 }
{ variable <= variable2 }
{ variable >= variable2 }
{ variable < variable2 }
{ variable > variable2 }
{ variable > variable2 < variable3 }

{ variable is variable2 }
{ variable isnt variable2 }
{ variable and variable2 }
{ variable or variable2 }

{ variable == 12.1 }
{ variable == true }
{ variable == false }
{ variable == \"s1\" }
{ variable == null }

""").get_all()


	var jsonTokens : Array = []
	for token in tokens:
		jsonTokens.append(Token.to_JSON_object(token))
	assert_eq_deep(jsonTokens, [
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 1, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 1, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 1, "column": 2, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 1, "column": 11, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 1, "column": 12, "value": "", },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 2, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 2, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_NOT, "line": 2, "column": 2, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 2, "column": 6, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 2, "column": 15, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 2, "column": 16, "value": "", },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 3, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 3, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_NOT, "line": 3, "column": 2, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 3, "column": 3, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 3, "column": 12, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 3, "column": 13, "value": "", },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 4, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 4, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 4, "column": 2, },
		{ "name": Syntax.TOKEN_EQUAL, "line": 4, "column": 11, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable2', "line": 4, "column": 14, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 4, "column": 24, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 4, "column": 25, "value": "", },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 5, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 5, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 5, "column": 2, },
		{ "name": Syntax.TOKEN_NOT_EQUAL, "line": 5, "column": 11, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable2', "line": 5, "column": 14, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 5, "column": 24, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 5, "column": 25, "value": "", },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 6, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 6, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 6, "column": 2, },
		{ "name": Syntax.TOKEN_AND, "line": 6, "column": 11, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable2', "line": 6, "column": 14, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 6, "column": 24, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 6, "column": 25, "value": "", },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 7, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 7, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 7, "column": 2, },
		{ "name": Syntax.TOKEN_OR, "line": 7, "column": 11, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable2', "line": 7, "column": 14, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 7, "column": 24, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 7, "column": 25, "value": "", },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 8, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 8, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 8, "column": 2, },
		{ "name": Syntax.TOKEN_LE, "line": 8, "column": 11, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable2', "line": 8, "column": 14, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 8, "column": 24, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 8, "column": 25, "value": "", },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 9, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 9, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 9, "column": 2, },
		{ "name": Syntax.TOKEN_GE, "line": 9, "column": 11, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable2', "line": 9, "column": 14, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 9, "column": 24, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 9, "column": 25, "value": "", },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 10, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 10, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 10, "column": 2, },
		{ "name": Syntax.TOKEN_LESS, "line": 10, "column": 11, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable2', "line": 10, "column": 13, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 10, "column": 23, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 10, "column": 24, "value": "", },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 11, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 11, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 11, "column": 2, },
		{ "name": Syntax.TOKEN_GREATER, "line": 11, "column": 11, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable2', "line": 11, "column": 13, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 11, "column": 23, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 11, "column": 24, "value": "", },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 12, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 12, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 12, "column": 2, },
		{ "name": Syntax.TOKEN_GREATER, "line": 12, "column": 11, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable2', "line": 12, "column": 13, },
		{ "name": Syntax.TOKEN_LESS, "line": 12, "column": 23, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable3', "line": 12, "column": 25, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 12, "column": 35, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 12, "column": 36, "value": "", },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 14, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 14, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 14, "column": 2, },
		{ "name": Syntax.TOKEN_EQUAL, "line": 14, "column": 11, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable2', "line": 14, "column": 14, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 14, "column": 24, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 14, "column": 25, "value": "", },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 15, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 15, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 15, "column": 2, },
		{ "name": Syntax.TOKEN_NOT_EQUAL, "line": 15, "column": 11, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable2', "line": 15, "column": 16, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 15, "column": 26, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 15, "column": 27, "value": "", },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 16, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 16, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 16, "column": 2, },
		{ "name": Syntax.TOKEN_AND, "line": 16, "column": 11, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable2', "line": 16, "column": 15, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 16, "column": 25, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 16, "column": 26, "value": "", },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 17, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 17, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 17, "column": 2, },
		{ "name": Syntax.TOKEN_OR, "line": 17, "column": 11, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable2', "line": 17, "column": 14, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 17, "column": 24, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 17, "column": 25, "value": "", },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 19, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 19, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 19, "column": 2, },
		{ "name": Syntax.TOKEN_EQUAL, "line": 19, "column": 11, "value": "", },
		{ "name": Syntax.TOKEN_NUMBER_LITERAL, "value": '12.1', "line": 19, "column": 14, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 19, "column": 19, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 19, "column": 20, "value": "", },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 20, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 20, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 20, "column": 2, },
		{ "name": Syntax.TOKEN_EQUAL, "line": 20, "column": 11, "value": "", },
		{ "name": Syntax.TOKEN_BOOLEAN_LITERAL, "value": 'true', "line": 20, "column": 14, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 20, "column": 19, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 20, "column": 20, "value": "", },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 21, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 21, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 21, "column": 2, },
		{ "name": Syntax.TOKEN_EQUAL, "line": 21, "column": 11, "value": "", },
		{ "name": Syntax.TOKEN_BOOLEAN_LITERAL, "value": 'false', "line": 21, "column": 14, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 21, "column": 20, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 21, "column": 21, "value": "", },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 22, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 22, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 22, "column": 2, },
		{ "name": Syntax.TOKEN_EQUAL, "line": 22, "column": 11, "value": "", },
		{ "name": Syntax.TOKEN_STRING_LITERAL, "value": 's1', "line": 22, "column": 14, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 22, "column": 19, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 22, "column": 20, "value": "", },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 23, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 23, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 23, "column": 2, },
		{ "name": Syntax.TOKEN_EQUAL, "line": 23, "column": 11, "value": "", },
		{ "name": Syntax.TOKEN_NULL_TOKEN, "line": 23, "column": 14, "value": "", },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 23, "column": 19, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 23, "column": 20, "value": "", },

		{ "name": Syntax.TOKEN_EOF, "line": 25, "column": 0, "value": "" },
	])


func test_variables_indent():
	var lexer = Lexer.new()
	var tokens = lexer.init("""
 { a }
{ a }

""").get_all()

	var jsonTokens : Array = []
	for token in tokens:
		jsonTokens.append(Token.to_JSON_object(token))
	assert_eq_deep(jsonTokens, [
		{ "name": Syntax.TOKEN_INDENT, "line": 1, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 1, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 1, "column": 1, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'a', "line": 1, "column": 3, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 1, "column": 5, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 1, "column": 6, "value": "", },

		{ "name": Syntax.TOKEN_DEDENT, "line": 2, "column": 0, "value": "", },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 2, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 2, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'a', "line": 2, "column": 2, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 2, "column": 4, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 2, "column": 5, "value": "" },

		{ "name": Syntax.TOKEN_EOF, "line": 4, "column": 0, "value": "" },
	])


func test_variables_assignements():
	var lexer = Lexer.new()
	var tokens = lexer.init("""
{ set variable = 1 }
{ set variable -= 1 }
{ set variable += 1 }
{ set variable *= 1 }
{ set variable /= 1 }
{ set variable ^= 1 }
{ set variable %= 1 }
{ set variable = a = b }

{ set variable = 1 + 2 }
{ set variable = 1 - 2 }
{ set variable = 1 * 2 }
{ set variable = 1 / 2 }
{ set variable = 1 ^ 2 }
{ set variable = 1 % 2 }

{ trigger event_name }
{ set a = 1, set b = 2 }
{ when a }

""").get_all()


	var jsonTokens : Array = []
	for token in tokens:
		jsonTokens.append(Token.to_JSON_object(token))
	assert_eq_deep(jsonTokens, [
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 1, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 1, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_KEYWORD_SET, "line": 1, "column": 2, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 1, "column": 6, },
		{ "name": Syntax.TOKEN_ASSIGN, "line": 1, "column": 15, "value": "", },
		{ "name": Syntax.TOKEN_NUMBER_LITERAL, "value": '1', "line": 1, "column": 17, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 1, "column": 19, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 1, "column": 20, "value": "" },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 2, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 2, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_KEYWORD_SET, "line": 2, "column": 2, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 2, "column": 6, },
		{ "name": Syntax.TOKEN_ASSIGN_SUB, "line": 2, "column": 15, "value": "", },
		{ "name": Syntax.TOKEN_NUMBER_LITERAL, "value": '1', "line": 2, "column": 18, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 2, "column": 20, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 2, "column": 21, "value": "" },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 3, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 3, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_KEYWORD_SET, "line": 3, "column": 2, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 3, "column": 6, },
		{ "name": Syntax.TOKEN_ASSIGN_SUM, "line": 3, "column": 15, "value": "", },
		{ "name": Syntax.TOKEN_NUMBER_LITERAL, "value": '1', "line": 3, "column": 18, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 3, "column": 20, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 3, "column": 21, "value": "" },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 4, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 4, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_KEYWORD_SET, "line": 4, "column": 2, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 4, "column": 6, },
		{ "name": Syntax.TOKEN_ASSIGN_MULT, "line": 4, "column": 15, "value": "", },
		{ "name": Syntax.TOKEN_NUMBER_LITERAL, "value": '1', "line": 4, "column": 18, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 4, "column": 20, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 4, "column": 21, "value": "" },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 5, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 5, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_KEYWORD_SET, "line": 5, "column": 2, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 5, "column": 6, },
		{ "name": Syntax.TOKEN_ASSIGN_DIV, "line": 5, "column": 15, "value": "", },
		{ "name": Syntax.TOKEN_NUMBER_LITERAL, "value": '1', "line": 5, "column": 18, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 5, "column": 20, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 5, "column": 21, "value": "" },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 6, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 6, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_KEYWORD_SET, "line": 6, "column": 2, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 6, "column": 6, },
		{ "name": Syntax.TOKEN_ASSIGN_POW, "line": 6, "column": 15, "value": "", },
		{ "name": Syntax.TOKEN_NUMBER_LITERAL, "value": '1', "line": 6, "column": 18, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 6, "column": 20, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 6, "column": 21, "value": "" },


		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 7, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 7, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_KEYWORD_SET, "line": 7, "column": 2, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 7, "column": 6, },
		{ "name": Syntax.TOKEN_ASSIGN_MOD, "line": 7, "column": 15, "value": "", },
		{ "name": Syntax.TOKEN_NUMBER_LITERAL, "value": '1', "line": 7, "column": 18, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 7, "column": 20, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 7, "column": 21, "value": "" },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 8, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 8, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_KEYWORD_SET, "line": 8, "column": 2, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 8, "column": 6, },
		{ "name": Syntax.TOKEN_ASSIGN, "line": 8, "column": 15, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'a', "line": 8, "column": 17, },
		{ "name": Syntax.TOKEN_ASSIGN, "line": 8, "column": 19, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'b', "line": 8, "column": 21, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 8, "column": 23, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 8, "column": 24, "value": "" },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 10, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 10, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_KEYWORD_SET, "line": 10, "column": 2, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 10, "column": 6, },
		{ "name": Syntax.TOKEN_ASSIGN, "line": 10, "column": 15, "value": "", },
		{ "name": Syntax.TOKEN_NUMBER_LITERAL, "value": '1', "line": 10, "column": 17, },
		{ "name": Syntax.TOKEN_PLUS, "line": 10, "column": 19, "value": "", },
		{ "name": Syntax.TOKEN_NUMBER_LITERAL, "value": '2', "line": 10, "column": 21, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 10, "column": 23, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 10, "column": 24, "value": "" },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 11, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 11, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_KEYWORD_SET, "line": 11, "column": 2, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 11, "column": 6, },
		{ "name": Syntax.TOKEN_ASSIGN, "line": 11, "column": 15, "value": "", },
		{ "name": Syntax.TOKEN_NUMBER_LITERAL, "value": '1', "line": 11, "column": 17, },
		{ "name": Syntax.TOKEN_MINUS, "line": 11, "column": 19, "value": "", },
		{ "name": Syntax.TOKEN_NUMBER_LITERAL, "value": '2', "line": 11, "column": 21, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 11, "column": 23, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 11, "column": 24, "value": "" },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 12, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 12, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_KEYWORD_SET, "line": 12, "column": 2, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 12, "column": 6, },
		{ "name": Syntax.TOKEN_ASSIGN, "line": 12, "column": 15, "value": "", },
		{ "name": Syntax.TOKEN_NUMBER_LITERAL, "value": '1', "line": 12, "column": 17, },
		{ "name": Syntax.TOKEN_MULT, "line": 12, "column": 19, "value": "", },
		{ "name": Syntax.TOKEN_NUMBER_LITERAL, "value": '2', "line": 12, "column": 21, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 12, "column": 23, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 12, "column": 24, "value": "" },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 13, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 13, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_KEYWORD_SET, "line": 13, "column": 2, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 13, "column": 6, },
		{ "name": Syntax.TOKEN_ASSIGN, "line": 13, "column": 15, "value": "", },
		{ "name": Syntax.TOKEN_NUMBER_LITERAL, "value": '1', "line": 13, "column": 17, },
		{ "name": Syntax.TOKEN_DIV, "line": 13, "column": 19, "value": "", },
		{ "name": Syntax.TOKEN_NUMBER_LITERAL, "value": '2', "line": 13, "column": 21, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 13, "column": 23, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 13, "column": 24, "value": "" },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 14, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 14, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_KEYWORD_SET, "line": 14, "column": 2, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 14, "column": 6, },
		{ "name": Syntax.TOKEN_ASSIGN, "line": 14, "column": 15, "value": "", },
		{ "name": Syntax.TOKEN_NUMBER_LITERAL, "value": '1', "line": 14, "column": 17, },
		{ "name": Syntax.TOKEN_POWER, "line": 14, "column": 19, "value": "", },
		{ "name": Syntax.TOKEN_NUMBER_LITERAL, "value": '2', "line": 14, "column": 21, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 14, "column": 23, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 14, "column": 24, "value": "" },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 15, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 15, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_KEYWORD_SET, "line": 15, "column": 2, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 15, "column": 6, },
		{ "name": Syntax.TOKEN_ASSIGN, "line": 15, "column": 15, "value": "", },
		{ "name": Syntax.TOKEN_NUMBER_LITERAL, "value": '1', "line": 15, "column": 17, },
		{ "name": Syntax.TOKEN_MOD, "line": 15, "column": 19, "value": "", },
		{ "name": Syntax.TOKEN_NUMBER_LITERAL, "value": '2', "line": 15, "column": 21, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 15, "column": 23, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 15, "column": 24 , "value": ""},

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 17, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 17, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_KEYWORD_TRIGGER, "line": 17, "column": 2, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'event_name', "line": 17, "column": 10, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 17, "column": 21, "value": "" },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 17, "column": 22, "value": "" },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 18, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 18, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_KEYWORD_SET, "line": 18, "column": 2, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'a', "line": 18, "column": 6, },
		{ "name": Syntax.TOKEN_ASSIGN, "line": 18, "column": 8, "value": "", },
		{ "name": Syntax.TOKEN_NUMBER_LITERAL, "value": '1', "line": 18, "column": 10, },
		{ "name": Syntax.TOKEN_COMMA, "line": 18, "column": 11, "value": "", },
		{ "name": Syntax.TOKEN_KEYWORD_SET, "line": 18, "column": 13, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'b', "line": 18, "column": 17, },
		{ "name": Syntax.TOKEN_ASSIGN, "line": 18, "column": 19, "value": "", },
		{ "name": Syntax.TOKEN_NUMBER_LITERAL, "value": '2', "line": 18, "column": 21, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 18, "column": 23, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 18, "column": 24, "value": "" },


		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 19, "column": 0, "value": "" },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 19, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_KEYWORD_WHEN, "line": 19, "column": 2, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'a', "line": 19, "column": 7, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 19, "column": 9, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 19, "column": 10, "value": "" },

		{ "name": Syntax.TOKEN_EOF, "line": 21, "column": 0, "value": "" },
	])


func test_variables_assignment_after_line():
	var lexer = Lexer.new()
	var tokens = lexer.init("this line { set variable = 1 }").get_all()
	
	
	var jsonTokens : Array = []
	for token in tokens:
		jsonTokens.append(Token.to_JSON_object(token))
	assert_eq_deep(jsonTokens, [
		{ "name": Syntax.TOKEN_TEXT, "value": 'this line', "line": 0, "column": 0, },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 0, "column": 10, "value": "", },
		{ "name": Syntax.TOKEN_KEYWORD_SET, "line": 0, "column": 12, "value": "", },
		{ "name": Syntax.TOKEN_IDENTIFIER, "value": 'variable', "line": 0, "column": 16, },
		{ "name": Syntax.TOKEN_ASSIGN, "line": 0, "column": 25, "value": "", },
		{ "name": Syntax.TOKEN_NUMBER_LITERAL, "value": '1', "line": 0, "column": 27, },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 0, "column": 29, "value": "", },
		{ "name": Syntax.TOKEN_EOF, "line": 0, "column": 30, "value": "", },
	])


func test_includes_line_break_when_just_after_or_before_a_logic_block():
	var lexer = Lexer.new()
	var tokens = lexer.init("""
after {}
{} before
both
{}
""").get_all()


	var jsonTokens : Array = []
	for token in tokens:
		jsonTokens.append(Token.to_JSON_object(token))
	assert_eq_deep(jsonTokens, [
		{ "name": Syntax.TOKEN_TEXT, "value": 'after', "line": 1, "column": 0, },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 1, "column": 6, "value": "", },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 1, "column": 7, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 1, "column": 8, "value": "", },

		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 2, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 2, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 2, "column": 1, "value": "", },
		{ "name": Syntax.TOKEN_TEXT, "value": 'before', "line": 2, "column": 3, },

		{ "name": Syntax.TOKEN_TEXT, "value": 'both', "line": 3, "column": 0, },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 4, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_BRACE_OPEN, "line": 4, "column": 0, "value": "", },
		{ "name": Syntax.TOKEN_BRACE_CLOSE, "line": 4, "column": 1, "value": "", },
		{ "name": Syntax.TOKEN_LINE_BREAK, "line": 4, "column": 2, "value": "", },
		{ "name": Syntax.TOKEN_EOF, "line": 5, "column": 0, "value": "", },
	])


func test_returns_line_by_line():
	var lexer = Lexer.new()
	var tokens = lexer.init("""normal line
				indented line
						another indent
now another dedent""")

	assert_eq_deep(Token.to_JSON_object(tokens.next()), { "name": Syntax.TOKEN_TEXT, "value": 'normal line', "line": 0, "column": 0, })
	assert_eq_deep(Token.to_JSON_object(tokens.next()), { "name": Syntax.TOKEN_INDENT, "line": 1, "column": 0 , "value": ""})
	assert_eq_deep(Token.to_JSON_object(tokens.next()), { "name": Syntax.TOKEN_TEXT, "value": 'indented line', "line": 1, "column": 4 })
	assert_eq_deep(Token.to_JSON_object(tokens.next()), { "name": Syntax.TOKEN_INDENT, "line": 2, "column": 4, "value": "" })
	assert_eq_deep(Token.to_JSON_object(tokens.next()), { "name": Syntax.TOKEN_TEXT, "value": 'another indent', "line": 2, "column": 6 })
	assert_eq_deep(Token.to_JSON_object(tokens.next()), { "name": Syntax.TOKEN_DEDENT, "line": 3, "column": 4, "value": "" })
	assert_eq_deep(Token.to_JSON_object(tokens.next()), { "name": Syntax.TOKEN_DEDENT, "line": 3, "column": 0, "value": "" })
	assert_eq_deep(Token.to_JSON_object(tokens.next()), { "name": Syntax.TOKEN_TEXT, "value": 'now another dedent', "line": 3, "column": 0 })

func test_parse_token_friendly_hint():
	assert_eq_deep(Lexer.get_token_friendly_hint(Syntax.TOKEN_LINE_ID), '$id')
	assert_eq_deep(Lexer.get_token_friendly_hint('some_unkown_token'), 'some_unkown_token')


func test_does_not_fail_when_leaving_mode():
	var lexer = Lexer.new()
	lexer.init('))').get_all()
	pass_test("didn't fail")


func test_produces_same_blocks_for_tabbed_and_spaced_indentation():
	var lexer = Lexer.new()
	var tokens = lexer.init("""
Pick an option.
 + Quest test
  { QUEST_STARTED } How's that quest going? (you should see this line at some point)
  { not QUEST_STARTED } I have a quest for you! {set QUEST_STARTED = true}
  <-
{no QUEST_STARTED}
 blah { not QUEST_STARTED} 
 bleh { QUEST_STARTED}
""").get_all()

	var json2Tokens : Array = []
	for token in tokens:
		json2Tokens.append(Token.to_JSON_object(token))
	var tab_tokens = lexer.init("""
Pick an option.
	+ Quest test
		{ QUEST_STARTED } How's that quest going? (you should see this line at some point)
		{ not QUEST_STARTED } I have a quest for you! {set QUEST_STARTED = true}
		<-
{no QUEST_STARTED}
	blah { not QUEST_STARTED}	
	bleh { QUEST_STARTED}
""").get_all()

	var jsonTokens : Array = []
	for token in tab_tokens:
		jsonTokens.append(Token.to_JSON_object(token))
	assert_eq_deep(jsonTokens, json2Tokens)

