extends GutTestFunctions


func test_parse_empty_document():
	var parser = ClydeParser.new()
	var result = parser.to_JSON_object(parser.parse(''));
	var expected = _create_doc_payload()
	assert_eq_deep(result, expected);


func test_parse_document_with_multiple_line_breaks():
	var parser = ClydeParser.new()
	var result = parser.to_JSON_object(parser.parse('\n\n\n\n\n\n\n\n\n\n\n\n\n\n'))
	var expected = _create_doc_payload()
	assert_eq_deep(result, expected);
