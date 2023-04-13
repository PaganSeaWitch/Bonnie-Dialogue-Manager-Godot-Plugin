extends "res://addons/gut/test.gd"

var Parser = preload("res://addons/clyde/parser/Parser.gd")

func test_parse_empty_document():
	var parser = Parser.new()
	var result = parser.to_JSON_object(parser.parse(''));
	var expected = {
		"type": NodeFactory.NODE_TYPES.DOCUMENT,
		"content": [],
		"blocks": []
	};
	assert_eq_deep(result, expected);


func test_parse_document_with_multiple_line_breaks():
	var parser = Parser.new()
	var result = parser.to_JSON_object(parser.parse('\n\n\n\n\n\n\n\n\n\n\n\n\n\n'))
	var expected = {
		"type": NodeFactory.NODE_TYPES.DOCUMENT,
		"content": [],
		"blocks": []
	};
	assert_eq_deep(result, expected);
