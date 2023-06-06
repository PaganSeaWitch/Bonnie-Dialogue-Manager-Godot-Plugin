extends GutTestFunctions


func test_parser_bb_code_in_line():
	var result = _parse('cheese [b] cakes')
	
	var expected = _create_doc_payload([_create_content_payload([
			_line_part( 
				_line({"value": "cheese " }), 
				false
			),
			_line_part(
				_line({ "value": ' cakes', "bb_code_before_line" : "[b]"}),
				true
			),
		])
	])
	assert_eq_deep(result, expected)
