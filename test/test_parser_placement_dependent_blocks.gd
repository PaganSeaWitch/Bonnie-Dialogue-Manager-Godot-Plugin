extends GutTest

func _parse(input):
	var parser = Parser.new()
	return parser.to_JSON_object(parser.parse(input))

func _line(line):
	var tags = []
	if(line.get("tags")) != null:
		tags.append_array(line.get("tags"))

	var value = line.get("value") if line.get("value") != null else ""
	var speaker = line.get("speaker") if line.get("speaker") != null else ""
	var id = line.get("id") if line.get("id") != null else ""
	return {
		"type": NodeFactory.NODE_TYPES.LINE,
		"value": value,
		"speaker": speaker,
		"id": id,
		"tags": tags,
		"id_suffixes": line.get("id_suffixes") if line.get("id_suffixes") != null else []
	}

func _action_content(actionContent):
	var content = actionContent.get("content") if actionContent.get("content") != null else []
	var actions = actionContent.get("actions") if actionContent.get("actions") != null else []
	return {
		"type": NodeFactory.NODE_TYPES.ACTION_CONTENT,
		"value": actionContent.get("name") if actionContent.get("name") != null else "",
		"speaker": actionContent.get("speaker") if actionContent.get("speaker") != null else "",
		"id": actionContent.get("id") if actionContent.get("id") != null else "",
		"tags": actionContent.get("tags") if actionContent.get("tags") != null else [],
		"id_suffixes" : actionContent.get("id_suffixes") if actionContent.get("id_suffixes") != null else [],
		"mode": actionContent.get("mode") if actionContent.get("mode") != null else "",
		"content": content,
		"actions": actions,
	}

func _line_part(part : Dictionary, end_line = false):
	return {
		"type" : NodeFactory.NODE_TYPES.LINE_PART,
		"part": part,
		"end_line": end_line
	}



func _create_doc_payload(content = [], blocks = []):
	return {
		"type":  NodeFactory.NODE_TYPES.DOCUMENT,
		"content": content,
		"blocks": blocks
	}

func _create_content_payload(content = []):
	return {
		"type": NodeFactory.NODE_TYPES.CONTENT,
		"content": content
	}

func test_parser_placement_depentdent_slice_text():
	var result = _parse('cheese [ set x = 5 ] cakes')
	
	var expected = _create_doc_payload([_create_content_payload([
			_line_part( _line({"type":  NodeFactory.NODE_TYPES.LINE, "value": "cheese " }), false),
			_line_part( _action_content({
					"actions": [{
						"type": NodeFactory.NODE_TYPES.ASSIGNMENTS,
						"assignments": [
							{
								"type":  NodeFactory.NODE_TYPES.ASSIGNMENT,
								"variable": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'x', },
								"operation": 'ASSIGN',
								"value": { "type": NodeFactory.NODE_TYPES.NUMBER_LITERAL, "value": 5.0, },
							},
						],
					}],
					"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": ' cakes', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
					}),
				true,
			),
		])
	])
	assert_eq_deep(result, expected)


func test_parser_placement_depentdent_conditional_text():
	var result = _parse('cheese [ when chicken ] cakes')
	
	var expected = _create_doc_payload([_create_content_payload([
			_line_part(_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": "cheese " }),false),
			_line_part( {"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
					"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
					"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": ' cakes', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
					},
				true,
			),
		])
	])
	assert_eq_deep(result, expected)


func test_parser_multiple_placement_depentdent_conditional_text():
	var result = _parse('cheese [ when chicken ] cakes [ when sticks ] suck')
	var expected = _create_doc_payload([_create_content_payload([
		_line_part(_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": "cheese " }), false),
		_line_part({"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
					"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
					"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": ' cakes ', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
					},
				false
		),
		_line_part({"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
					"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "sticks" },
					"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": ' suck', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
					},
				true
		),
		])
	])
	assert_eq_deep(result, expected)


func test_parser_multiple_placement_depentdent_conditional_and_action_text():
	var result = _parse('cheese [ when chicken ] cakes [ when sticks ] suck [ set x = 5 ] a lot')
	var expected = _create_doc_payload([_create_content_payload([
			_line_part(_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": "cheese " }),false),
			_line_part({"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
					"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
					"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": ' cakes ', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
					},
				false
			),
			_line_part({"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
					"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "sticks" },
					"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": ' suck ', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
					},
				false
			),
			_line_part(_action_content({
					"actions": [{
						"type": NodeFactory.NODE_TYPES.ASSIGNMENTS,
						"assignments": [
							{
								"type":  NodeFactory.NODE_TYPES.ASSIGNMENT,
								"variable": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'x', },
								"operation": 'ASSIGN',
								"value": { "type": NodeFactory.NODE_TYPES.NUMBER_LITERAL, "value": 5.0, },
							},
						],
					}],
					"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": ' a lot', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
					}),
				true
			),
		])
	])
	assert_eq_deep(result, expected)


func test_not_operator():
	var result = _parse('cheese [ not chicken ] cakes')

	var expected = _create_doc_payload([_create_content_payload([
		_line_part( _line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": "cheese " }),false),
		_line_part({"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
					"conditions": {
						"type":  NodeFactory.NODE_TYPES.EXPRESSION,
						"name": "NOT",
						"elements": [{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" }]
						},
					"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": ' cakes', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
					},
				true
		),
		])
	])

	assert_eq_deep(result, expected)
	
func test_and_operator():
	var result = _parse('cheese [chicken && checken ] cakes')

	var expected = _create_doc_payload([_create_content_payload([
		_line_part( _line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": "cheese " }),false),
		_line_part({"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
					"conditions": {
						"type":  NodeFactory.NODE_TYPES.EXPRESSION,
						"name": 'AND',
						"elements": [
							{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'chicken', },
							{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'checken', },
						],
					},
					"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": ' cakes', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
					},
				true
		),
		])
	])

	assert_eq_deep(result, expected)

func test_empty_block():
	var result = _parse("cheese [] cakes")
	
	var expected = _create_doc_payload([_create_content_payload([
		_line_part(_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": "cheese " }),false),
		_line_part({"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
					"conditions": {},
					"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": ' cakes', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
					},
				true
		),
		])
	])
	assert_eq_deep(result, expected)
	

func test_independent_before_dependent_logic():
	var result = _parse('{ when chicken } cheese [ when chicken ] cakes')
	
	var expected = _create_doc_payload([
		{
			"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
			"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
			"content": 
				[_create_content_payload([
					_line_part(_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": "cheese " }),false),
					_line_part({"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
							"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
							"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": ' cakes', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
							},
						true
					),
				])]
		}
	])
	assert_eq_deep(result, expected)


func test_independent_after_dependent_logic():
	var result = _parse('cheese [ when chicken ] cakes { when chicken }')
	
	var expected = _create_doc_payload([
		{
			"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
			"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
			"content": 
				[_create_content_payload([
					_line_part( _line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": "cheese " }), false),
					_line_part({"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
							"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
							"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": ' cakes', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
							},
						true
					),
				])]
		}
	])
	assert_eq_deep(result, expected)


func test_independent_inbetween_dependent_logic():
	var result = _parse('cheese [ when chicken ] { when chicken } cakes')
	
	var expected = _create_doc_payload([
		{
			"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
			"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
			"content": 
				[_create_content_payload([
					_line_part(_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": "cheese " }),false),
					_line_part({"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
							"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
							"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": '  cakes', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
							},
						true
					),
				])]
		}
	])
	assert_eq_deep(result, expected)


func test_independent_inbetween_dependent_logic_reversed():
	var result = _parse('cheese { when chicken }[ when chicken ]  cakes')
	
	var expected = _create_doc_payload([
		{
			"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
			"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
			"content": 
				[_create_content_payload([
					_line_part(_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": "cheese " }),false),
					_line_part({"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
							"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
							"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": '  cakes', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
							},
						true
					),
				])]
		}
	])
	assert_eq_deep(result, expected)


func test_independent_inbetween_dependent_logics():
	var result = _parse('[ when chicken ] cheese { when chicken } [ when chicken ]  cakes')
	
	var expected = _create_doc_payload([
		{
			"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
			"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
			"content": 
				[_create_content_payload([
					_line_part( {"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
							"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
							"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": ' cheese  ', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
							},
						false
					),
					_line_part({"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
							"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
							"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": '  cakes', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
							},
						true
					),
				])]
		}
	])
	assert_eq_deep(result, expected)


func test_independent_set_inbetween_dependent_logics():
	var result = _parse('[ when chicken ] cheese { set x = 5 }[ when chicken ]  cakes')
	
	var expected = _create_doc_payload([
		_action_content({
				"actions": [{
					"type": NodeFactory.NODE_TYPES.ASSIGNMENTS,
					"assignments": [
						{
							"type":  NodeFactory.NODE_TYPES.ASSIGNMENT,
							"variable": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'x', },
							"operation": 'ASSIGN',
							"value": { "type": NodeFactory.NODE_TYPES.NUMBER_LITERAL, "value": 5.0, },
						},
					],
				}],
		"content": 
			[_create_content_payload([
				_line_part( {"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
						"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
						"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": ' cheese ', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
						},
					false
				),
				_line_part({"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
						"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
						"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": '  cakes', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
						},
					true
				),
		])]}),
	])
	assert_eq_deep(result, expected)
	

func test_multiple_logic_blocks_with_condition_after():
	var result = _parse("{set something = 1}[when chicken]{ some_var }{ trigger event }cheese")
	var expected = _create_doc_payload([_action_content({
		"actions": [{
			"type":  NodeFactory.NODE_TYPES.ASSIGNMENTS,
			"assignments": [{
				"type":  NodeFactory.NODE_TYPES.ASSIGNMENT,
				"variable": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'something' },
				"operation": "ASSIGN",
				"value": { "type": NodeFactory.NODE_TYPES.NUMBER_LITERAL, "value": 1.0 },
			}],
		}],
		"content": [{
			"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
			"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "some_var" },
			"content": [_action_content({
				"actions": [{
					"type": NodeFactory.NODE_TYPES.EVENTS,
					"events": [{ "type": NodeFactory.NODE_TYPES.EVENT, "name": 'event' } ],
				}],
				"content": [_create_content_payload([
					_line_part( {"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
							"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
							"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'cheese', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
							},
						true
				)])],
			})],
		}],
	})])
	assert_eq_deep(result, expected)


func test_parser_placement_depentdent_slice_conditional_text():
	var result = _parse('cheese [ set x = 5 ][when chicken] cakes')
	
	var expected = _create_doc_payload([_create_content_payload([
			_line_part( _line({"type":  NodeFactory.NODE_TYPES.LINE, "value": "cheese " }),
				false
			),
			_line_part(_action_content({
					"actions": [{
						"type": NodeFactory.NODE_TYPES.ASSIGNMENTS,
						"assignments": [
							{
								"type":  NodeFactory.NODE_TYPES.ASSIGNMENT,
								"variable": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'x', },
								"operation": 'ASSIGN',
								"value": { "type": NodeFactory.NODE_TYPES.NUMBER_LITERAL, "value": 5.0, },
							},
						],
					}],
					}),
				false
			),
			_line_part({"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
							"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
							"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": ' cakes', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
							},
				true
			)
		])
	])
	assert_eq_deep(result, expected)


func test_parser_placement_depentdent_slice_conditional_text_more():
	var result = _parse('[when cheken]cheese [ set x = 5 ][when chicken] cakes')
	
	var expected = _create_doc_payload([_create_content_payload([
			_line_part({"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
							"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "cheken" },
							"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'cheese ', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
							},
						false
			),
			_line_part(_action_content({
					"actions": [{
						"type": NodeFactory.NODE_TYPES.ASSIGNMENTS,
						"assignments": [
							{
								"type":  NodeFactory.NODE_TYPES.ASSIGNMENT,
								"variable": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'x', },
								"operation": 'ASSIGN',
								"value": { "type": NodeFactory.NODE_TYPES.NUMBER_LITERAL, "value": 5.0, },
							},
						],
					}],
					}),
				false
			),
			_line_part({"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
							"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
							"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": ' cakes', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
							},
				true
			)
		])
	])
	assert_eq_deep(result, expected)


func test_parser_placement_depentdent_slice_conditional_text_trigger():
	var result = _parse('[when cheken]cheese [ set x = 5 ][trigger chicken] cakes')
	
	var expected = _create_doc_payload([_create_content_payload([
		_line_part({"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
							"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "cheken" },
							"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'cheese ', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
							},
				false
		),
		_line_part(_action_content({
					"actions": [{
						"type": NodeFactory.NODE_TYPES.ASSIGNMENTS,
						"assignments": [
							{
								"type":  NodeFactory.NODE_TYPES.ASSIGNMENT,
								"variable": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'x', },
								"operation": 'ASSIGN',
								"value": { "type": NodeFactory.NODE_TYPES.NUMBER_LITERAL, "value": 5.0, },
							},
						],
					}],
					"content": [],
					}),
				false
		),
		_line_part(_action_content({
				"actions": [{
					"type": NodeFactory.NODE_TYPES.EVENTS,
					"events": [{ "type": NodeFactory.NODE_TYPES.EVENT, "name": 'chicken' }],
				}],
				"content": [{
					"type":  NodeFactory.NODE_TYPES.LINE,
					"value": ' cakes', "speaker": "", "id": "", "tags": [], "id_suffixes": [],
				}]}),
			true		
		)])
	])
	assert_eq_deep(result, expected)


func test_parser_placement_depentdent_conditional_text_after():
	var result = _parse('cheese cakes[when chicken]')
	
	var expected = _create_doc_payload([_create_content_payload([
			_line_part(_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": "cheese cakes" }),false),
			_line_part({"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
					"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
					"content": [],
					},
				true
			),
		])
	])
	assert_eq_deep(result, expected)


func test_standalone_assignment_with_standalone_variable():
	var result = _parse("[ set a ]")

	var expected = _create_doc_payload([_create_content_payload([
		_line_part(
			_action_content({
						"actions": [{
							"type": NodeFactory.NODE_TYPES.ASSIGNMENTS,
							"assignments": [
								{
									"type":  NodeFactory.NODE_TYPES.ASSIGNMENT,
									"variable": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'a', },
									"operation": 'ASSIGN',
									"value": { "type": NodeFactory.NODE_TYPES.BOOLEAN_LITERAL, "value": true, },
								},
							],
						}],
						}),
			true
		)])
	])
	assert_eq_deep(result, expected)

func test_divert_with_assignment():
	var result = _parse("-> go [ set a = 2 ]")
	var expected = _create_doc_payload([
		{ "type": NodeFactory.NODE_TYPES.DIVERT, "target": 'go' },
		_create_content_payload([
			_line_part(_action_content({
						"actions": [{
						"type":  NodeFactory.NODE_TYPES.ASSIGNMENTS,
						"assignments": [
							{
								"type":  NodeFactory.NODE_TYPES.ASSIGNMENT,
								"variable": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'a', },
								"operation": "ASSIGN",
								"value": { "type": NodeFactory.NODE_TYPES.NUMBER_LITERAL, "value": 2.0, },
							},
						],
						}]
					}),
				true
			)
		])])

	assert_eq_deep(result, expected)


func test_condition_with_multiline_dialogue():
		var result = _parse("""[ another_var ] This is conditional
		multiline
	""")

		var expected = _create_doc_payload([_create_content_payload([_line_part({
			"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
			"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "another_var" },
			"content": [{ "type":  NodeFactory.NODE_TYPES.LINE, "value": " This is conditional multiline", "speaker": "", "id": "", "tags": [], "id_suffixes": [], }]
		}, true)])])
		assert_eq_deep(result, expected)


func test_speaker_before_and_after_dependent():
	var result = _parse("""npc: what do you[when chicken] want to talk about? """)

	var expected = _create_doc_payload([_create_content_payload([
		_line_part(_line({"speaker": "npc","value": "what do you"}),false),
		_line_part(
			{
				"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
				"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
				"content": [_line({
					"speaker": "npc",
					"value": ' want to talk about?'
				})],
			},
			true
		)
	])])
	assert_eq_deep(result, expected)


func test_tag_before_and_after_dependent():
	var result = _parse("""what do you[when chicken] want to talk about? #conspiracy""")

	var expected = _create_doc_payload([_create_content_payload([
		_line_part(_line({"value": "what do you","tags":["conspiracy"]}),false),
		_line_part(
			{
				"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
				"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
				"content": [_line({
					"tags":["conspiracy"],
					"value": ' want to talk about?'
				})],
			},
			true
		)
	])])
	assert_eq_deep(result, expected)


func test_id_before_and_after_dependent():
	var result = _parse("""what do you [when chicken] want to talk about? $line_id""")

	var expected = _create_doc_payload([_create_content_payload([
		_line_part(_line({"value": "what do you ","id": "line_id_0"}),false),
		_line_part(
			{
				"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
				"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
				"content": [_line({
					"id": "line_id_1",
					"value": ' want to talk about?'
				})],
			},
			true
		)
	])])
	assert_eq_deep(result, expected)


func test_id_suffix_before_and_after_dependent():
	var result = _parse("""what do you [when chicken] want to talk about? $line_id&fren""")

	var expected = _create_doc_payload([_create_content_payload([
		_line_part(_line({"value": "what do you ","id": "line_id_0","id_suffixes":["fren"]}),false),
		_line_part(
			{
				"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
				"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
				"content": [_line({
					"id": "line_id_1",
					"value": ' want to talk about?',
					"id_suffixes":["fren"]
				})],
			},
			true
		)
	])])
	assert_eq_deep(result, expected)
	

func test_full_line_after_dependent():
	var result = _parse("""npc: what do you want to talk about?[when chicken] #conspiracy $line_id&fren""")

	var expected = _create_doc_payload([_create_content_payload([
		_line_part(_line({"speaker": "npc","value": "what do you want to talk about?",
					"id": "line_id_0",
					"id_suffixes":["fren"],
					"tags" : ["conspiracy"]
				}),false),
		_line_part(
			{
				"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
				"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
				"content": [_line({"speaker" : "npc", "id": "line_id_1","id_suffixes": ["fren"],"tags" : ["conspiracy"]})],
			},
			true
		)
	])])
	assert_eq_deep(result, expected)

func test_full_line_tag_before_after_dependent():
	var result = _parse("""npc: what do you want [when chucken] to talk about? #only_this [when chicken] #conspiracy $line_id&fren""")

	var expected = _create_doc_payload([_create_content_payload([
		_line_part(
				_line({
					"speaker": "npc",
					"value": "what do you want ",
					"id": "line_id_0",
					"id_suffixes":["fren"],
					"tags" : ["conspiracy"]
				}),
			false
		),
		_line_part(
			{
				"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
				"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chucken" },
				"content": [_line({
					"speaker": "npc",
					"value": " to talk about?",
					"id": "line_id_1",
					"id_suffixes":["fren"],
					"tags" : ["only_this","conspiracy"]
				})],
			},
			false
		),
		_line_part(
			{
				"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
				"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
				"content": [_line({"speaker" : "npc", "id": "line_id_2","id_suffixes": ["fren"],"tags" : ["conspiracy"]})]
			},
			true
		)
	])])
	assert_eq_deep(result, expected)
