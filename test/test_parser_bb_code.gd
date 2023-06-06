extends GutTestFunctions


func test_parser_bb_code_with_value_in_line():
	var result = _parse('cheese [color=#ffffff] cakes')
	
	var expected = _create_doc_payload([_create_content_payload([
			_line_part( 
				_line({"value": "cheese " }), 
				false
			),
			_line_part(
				_line({ "value": ' cakes', "bb_code_before_line" : "[color=#ffffff]"}),
				true
			),
		])
	])
	assert_eq_deep(result, expected)


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
	

func test_parser_bb_code_alone():
	var result = _parse('[b]')
	
	var expected = _create_doc_payload([_create_content_payload([
			_line_part(
				_line({"bb_code_before_line" : "[b]"}),
				true
			),
		])
	])
	assert_eq_deep(result, expected)


func test_parser_bb_code_multi():
	var result = _parse('[b][b][b][b][b]')
	
	var expected = _create_doc_payload([_create_content_payload([
			_line_part(
				_line({"bb_code_before_line" : "[b]"}),
				false
			),
			_line_part(
				_line({"bb_code_before_line" : "[b]"}),
				false
			),
			_line_part(
				_line({"bb_code_before_line" : "[b]"}),
				false
			),
			_line_part(
				_line({"bb_code_before_line" : "[b]"}),
				false
			),
			_line_part(
				_line({"bb_code_before_line" : "[b]"}),
				true
			),
		])
	])
	assert_eq_deep(result, expected)


func test_parser_bb_code_multi_with_line_at_end():
	var result = _parse('[b][b][b][b][b] cheese')
	
	var expected = _create_doc_payload([_create_content_payload([
			_line_part(
				_line({"bb_code_before_line" : "[b]"}),
				false
			),
			_line_part(
				_line({"bb_code_before_line" : "[b]"}),
				false
			),
			_line_part(
				_line({"bb_code_before_line" : "[b]"}),
				false
			),
			_line_part(
				_line({"bb_code_before_line" : "[b]"}),
				false
			),
			_line_part(
				_line({"value" : " cheese",  "bb_code_before_line" : "[b]"}),
				true
			),
		])
	])
	assert_eq_deep(result, expected)


func test_parser_bb_code_end_in_line():
	var result = _parse('cheese [/b] cakes')
	
	var expected = _create_doc_payload([_create_content_payload([
			_line_part( 
				_line({"value": "cheese " }), 
				false
			),
			_line_part(
				_line({ "value": ' cakes', "bb_code_before_line" : "[/b]"}),
				true
			),
		])
	])
	assert_eq_deep(result, expected)


func test_parser_bb_code_at_begining_line():
	var result = _parse('[b] cheese [/b] cakes')
	
	var expected = _create_doc_payload([_create_content_payload([
			_line_part( 
				_line({"value": " cheese ", "bb_code_before_line" : "[b]" }), 
				false
			),
			_line_part(
				_line({ "value": ' cakes', "bb_code_before_line" : "[/b]"}),
				true
			),
		])
	])
	assert_eq_deep(result, expected)


func test_parser_bb_code_at_begining_line_with_dependent_logic_with_line_id():
	var result = _parse('[{chicken}] [b] cheese [/b] cakes $line_id')
	
	var expected = _create_doc_payload([_create_content_payload([
			_line_part( 
				_conditional_content({
					"conditions": _variable("chicken"),
					"content": 
						[
							_line_part(_line({"value": " cheese ", "bb_code_before_line" : "[b]", "id" : "line_id_0_0"}), false),
							_line_part(_line({ "value": ' cakes', "bb_code_before_line" : "[/b]", "id" : "line_id_0_1"}), true)
						]
				}), 
				true
			),
		])
	])
	assert_eq_deep(result, expected)


func test_parser_bb_code_at_begining_line_with_dependent_logic_with_tags():
	var result = _parse('[{chicken}] [b] cheese #ag [/b] cakes #tag')
	
	var expected = _create_doc_payload([_create_content_payload([
			_line_part( 
				_conditional_content({
					"conditions": _variable("chicken"),
					"content": 
						[
							_line_part(_line({"value": " cheese", "bb_code_before_line" : "[b]", "tags" : ["ag","tag"]}),false),
							_line_part(_line({ "value": ' cakes', "bb_code_before_line" : "[/b]", "tags" : ["tag"]}), true)
						]
				}), 
				true
			),
		])
	])
	assert_eq_deep(result, expected)


func test_parser_bb_code_at_begining_line_with_dependent_logic_with_speaker():
	var result = _parse('[{chicken}] npc: [b] cheese [/b] cakes')
	
	var expected = _create_doc_payload([_create_content_payload([
			_line_part( 
				_conditional_content({
					"conditions": _variable("chicken"),
					"content": 
						[
							_line_part(_line({"speaker": "npc","value": " cheese ", "bb_code_before_line" : "[b]"}),false),
							_line_part(_line({"speaker": "npc", "value": ' cakes', "bb_code_before_line" : "[/b]"}), true)
						]
				}), 
				true
			),
		])
	])
	assert_eq_deep(result, expected)


func test_parser_bb_code_at_begining_line_with_dependent_condition_with_id_suffix():
	var result = _parse('[{chicken}] [b] cheese cakes [/b] $line_id&fren')
	
	var expected = _create_doc_payload([_create_content_payload([
			_line_part( 
				_conditional_content({
					"conditions": _variable("chicken"),
					"content": 
						[
							_line_part(_line({"value": " cheese cakes ", "id_suffixes" : ["fren"] ,"id" : "line_id_0_0", "bb_code_before_line" : "[b]"}),false),
							_line_part(_line({"id_suffixes" : ["fren"] ,"id" : "line_id_0_1", "bb_code_before_line" : "[/b]"}), true)
						]
				}), 
				true
			),
		])
	])
	assert_eq_deep(result, expected)


func test_parser_bb_code_at_begining_line_with_dependent_action():
	var result = _parse('[{set chicken = 5}] [b] cheese cakes [/b]')
	
	var expected = _create_doc_payload([_create_content_payload([
			_line_part( 
				_action_content({
					"actions": [
						_assignments([
							_assignment({
								"variable": _variable('chicken'),
								"operation": "ASSIGN",
								"value": _number(5.0),
							}),
						]),
					],
					"content": 
						[
							_line_part(_line({"value": " cheese cakes ", "bb_code_before_line" : "[b]"}),false),
							_line_part(_line({"bb_code_before_line" : "[/b]"}), true)
						]
				}), 
				true
			),
		])
	])
	assert_eq_deep(result, expected)


func test_parser_bb_code_at_begining_line_with_multi_dependent_action():
	var result = _parse('[{set chicken = 5}] [b] cheese [{set chicken = 6}][/b] cakes')
	
	var expected = _create_doc_payload([_create_content_payload([
			_line_part( 
				_action_content({
					"actions": [
						_assignments([
							_assignment({
								"variable": _variable('chicken'),
								"operation": "ASSIGN",
								"value": _number(5.0),
							}),
						]),
					],
					"content": 
						[
							_line_part(_line({"value": " cheese ", "bb_code_before_line" : "[b]"}),false),
						]
				}),
				false
			),
			_line_part( 
				_action_content({
					"actions": [
						_assignments([
							_assignment({
								"variable": _variable('chicken'),
								"operation": "ASSIGN",
								"value": _number(6.0),
							}),
						]),
					],
					"content": 
						[
							_line_part(_line({"value": " cakes","bb_code_before_line" : "[/b]"}), true)
						]
				}),
				true
			),
		])
	])
	assert_eq_deep(result, expected)


func test_parser_bb_code_before_dependent_conditional():
	var result = _parse('[b][{chicken}] cheese ')

	var expected = _create_doc_payload([_create_content_payload([
			_line_part(_line({"bb_code_before_line" : "[b]"}),false),
			_line_part( 
				_conditional_content({
					"conditions": _variable("chicken"),
					"content": 
						[
							_line({"value": " cheese"}),
						]
				}), 
				true
			),
		])
	])
	assert_eq_deep(result, expected)
