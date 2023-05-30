extends GutTest

func parse(input):
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
		"id_suffixes": []
	}

func _actionContent(actionContent):
	var content = actionContent.get("content") if actionContent.get("content") != null else []
	var actions = actionContent.get("actions") if actionContent.get("actions") != null else []
	return {
		"type": NodeFactory.NODE_TYPES.ACTION_CONTENT,
		"value": actionContent.get("name"),
		"speaker": actionContent.get("speaker") if actionContent.get("speaker") != null else "",
		"id": actionContent.get("id") if actionContent.get("id") != null else "",
		"tags": actionContent.get("tags") if actionContent.get("tags") != null else [],
		"id_suffixes" : actionContent.get("id_suffixes") if actionContent.get("id_suffixes") != null else [],
		"mode": actionContent.get("mode") if actionContent.get("mode") != null else "once",
		"content": content,
		"actions": actions,
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
	var result = parse('cheese [ set x = 5 ] cakes')
	
	var expected = _create_doc_payload([_create_content_payload([
			{
				"type":  NodeFactory.NODE_TYPES.LINE_PART,
				"part": _line({"type":  NodeFactory.NODE_TYPES.LINE, "value": "cheese " }),
				"end_line" : false,
			},
			{
				"type":  NodeFactory.NODE_TYPES.LINE_PART,
				"part": _actionContent({"type":  NodeFactory.NODE_TYPES.ACTION_CONTENT,
					"mode": "",
					"id": "",
					"id_suffixes" : [],
					"tags" : [],
					"name" : "",
					"speaker": "",
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
				"end_line" : true,
			},
		])
	])
	assert_eq_deep(result, expected)


func test_parser_placement_depentdent_conditional_text():
	var result = parse('cheese [ when chicken ] cakes')
	
	var expected = _create_doc_payload([_create_content_payload([
			{
				"type":  NodeFactory.NODE_TYPES.LINE_PART,
				"part": _line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": "cheese " }),
				"end_line" : false,
			},
			{
				"type":  NodeFactory.NODE_TYPES.LINE_PART,
				"part": {"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
					"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
					"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": ' cakes', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
					},
				"end_line" : true,
			},
		])
	])
	assert_eq_deep(result, expected)
	
func test_parser_multiple_placement_depentdent_conditional_text():
	var result = parse('cheese [ when chicken ] cakes [ when sticks ] suck')
	var expected = _create_doc_payload([_create_content_payload([
			{
				"type":  NodeFactory.NODE_TYPES.LINE_PART,
				"part": _line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": "cheese " }),
				"end_line" : false,
			},
			{
				"type":  NodeFactory.NODE_TYPES.LINE_PART,
				"part": {"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
					"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
					"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": ' cakes ', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
					},
				"end_line" : false,
			},
			{
				"type":  NodeFactory.NODE_TYPES.LINE_PART,
				"part": {"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
					"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "sticks" },
					"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": ' suck', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
					},
				"end_line" : true,
			},
		])
	])
	assert_eq_deep(result, expected)


func test_parser_multiple_placement_depentdent_conditional_and_action_text():
	var result = parse('cheese [ when chicken ] cakes [ when sticks ] suck [ set x = 5 ] a lot')
	var expected = _create_doc_payload([_create_content_payload([
			{
				"type":  NodeFactory.NODE_TYPES.LINE_PART,
				"part": _line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": "cheese " }),
				"end_line" : false,
			},
			{
				"type":  NodeFactory.NODE_TYPES.LINE_PART,
				"part": {"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
					"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
					"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": ' cakes ', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
					},
				"end_line" : false,
			},
			{
				"type":  NodeFactory.NODE_TYPES.LINE_PART,
				"part": {"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
					"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "sticks" },
					"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": ' suck ', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
					},
				"end_line" : false,
			},
			{
				"type":  NodeFactory.NODE_TYPES.LINE_PART,
				"part": _actionContent({"type":  NodeFactory.NODE_TYPES.ACTION_CONTENT,
					"mode": "",
					"id": "",
					"id_suffixes" : [],
					"tags" : [],
					"name" : "",
					"speaker": "",
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
				"end_line" : true,
			},
		])
	])
	assert_eq_deep(result, expected)


func test_not_operator():
	var result = parse('cheese [ not chicken ] cakes')

	var expected = _create_doc_payload([_create_content_payload([
			{
				"type":  NodeFactory.NODE_TYPES.LINE_PART,
				"part": _line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": "cheese " }),
				"end_line" : false,
			},
			{
				"type":  NodeFactory.NODE_TYPES.LINE_PART,
				"part": {"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
					"conditions": {
						"type":  NodeFactory.NODE_TYPES.EXPRESSION,
						"name": "NOT",
						"elements": [{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" }]
						},
					"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": ' cakes', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
					},
				"end_line" : true,
			},
		])
	])

	assert_eq_deep(result, expected)
	
func test_and_operator():
	var result = parse('cheese [chicken && checken ] cakes')

	var expected = _create_doc_payload([_create_content_payload([
			{
				"type":  NodeFactory.NODE_TYPES.LINE_PART,
				"part": _line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": "cheese " }),
				"end_line" : false,
			},
			{
				"type":  NodeFactory.NODE_TYPES.LINE_PART,
				"part": {"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
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
				"end_line" : true,
			},
		])
	])

	assert_eq_deep(result, expected)

func test_empty_block():
	var result = parse("cheese [] cakes")
	
	var expected = _create_doc_payload([_create_content_payload([
			{
				"type":  NodeFactory.NODE_TYPES.LINE_PART,
				"part": _line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": "cheese " }),
				"end_line" : false,
			},
			{
				"type":  NodeFactory.NODE_TYPES.LINE_PART,
				"part": {"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
					"conditions": {},
					"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": ' cakes', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
					},
				"end_line" : true,
			},
		])
	])
	assert_eq_deep(result, expected)
	

func test_independent_before_dependent_logic():
	var result = parse('{ when chicken } cheese [ when chicken ] cakes')
	
	var expected = _create_doc_payload([
		{
			"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
			"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
			"content": 
				[_create_content_payload([
					{
						"type":  NodeFactory.NODE_TYPES.LINE_PART,
						"part": _line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": "cheese " }),
						"end_line" : false,
					},
					{
						"type":  NodeFactory.NODE_TYPES.LINE_PART,
						"part": {"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
							"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
							"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": ' cakes', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
							},
						"end_line" : true,
					},
				])]
		}
	])
	assert_eq_deep(result, expected)

func test_independent_after_dependent_logic():
	var result = parse('cheese [ when chicken ] cakes { when chicken }')
	
	var expected = _create_doc_payload([
		{
			"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
			"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
			"content": 
				[_create_content_payload([
					{
						"type":  NodeFactory.NODE_TYPES.LINE_PART,
						"part": _line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": "cheese " }),
						"end_line" : false,
					},
					{
						"type":  NodeFactory.NODE_TYPES.LINE_PART,
						"part": {"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
							"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
							"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": ' cakes', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
							},
						"end_line" : true,
					},
				])]
		}
	])
	assert_eq_deep(result, expected)

func test_independent_inbetween_dependent_logic():
	var result = parse('cheese [ when chicken ] { when chicken } cakes')
	
	var expected = _create_doc_payload([
		{
			"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
			"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
			"content": 
				[_create_content_payload([
					{
						"type":  NodeFactory.NODE_TYPES.LINE_PART,
						"part": _line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": "cheese " }),
						"end_line" : false,
					},
					{
						"type":  NodeFactory.NODE_TYPES.LINE_PART,
						"part": {"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
							"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
							"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": '  cakes', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
							},
						"end_line" : true,
					},
				])]
		}
	])
	assert_eq_deep(result, expected)

func test_independent_inbetween_dependent_logic_reversed():
	var result = parse('cheese { when chicken }[ when chicken ]  cakes')
	
	var expected = _create_doc_payload([
		{
			"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
			"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
			"content": 
				[_create_content_payload([
					{
						"type":  NodeFactory.NODE_TYPES.LINE_PART,
						"part": _line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": "cheese " }),
						"end_line" : false,
					},
					{
						"type":  NodeFactory.NODE_TYPES.LINE_PART,
						"part": {"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
							"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
							"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": '  cakes', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
							},
						"end_line" : true,
					},
				])]
		}
	])
	assert_eq_deep(result, expected)


func test_independent_inbetween_dependent_logics():
	var result = parse('[ when chicken ] cheese { when chicken } [ when chicken ]  cakes')
	
	var expected = _create_doc_payload([
		{
			"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
			"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
			"content": 
				[_create_content_payload([
					{
						"type":  NodeFactory.NODE_TYPES.LINE_PART,
						"part": {"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
							"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
							"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": ' cheese  ', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
							},
						"end_line" : false,
					},
					{
						"type":  NodeFactory.NODE_TYPES.LINE_PART,
						"part": {"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
							"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
							"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": '  cakes', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
							},
						"end_line" : true,
					},
				])]
		}
	])
	assert_eq_deep(result, expected)


func test_independent_set_inbetween_dependent_logics():
	var result = parse('[ when chicken ] cheese { set x = 5 }[ when chicken ]  cakes')
	
	var expected = _create_doc_payload([
		_actionContent({"type":  NodeFactory.NODE_TYPES.ACTION_CONTENT,
				"mode": "",
				"id": "",
				"id_suffixes" : [],
				"tags" : [],
				"name" : "",
				"speaker": "",
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
				{
					"type":  NodeFactory.NODE_TYPES.LINE_PART,
					"part": {"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
						"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
						"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": ' cheese ', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
						},
					"end_line" : false,
				},
				{
					"type":  NodeFactory.NODE_TYPES.LINE_PART,
					"part": {"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
						"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
						"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": '  cakes', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
						},
					"end_line" : true,
				},
		])]}),
	])
	assert_eq_deep(result, expected)
	

func test_multiple_logic_blocks_with_condition_after():
	var result = parse("{set something = 1}[when chicken]{ some_var }{ trigger event }cheese")
	var expected = _create_doc_payload([{
		"type":  NodeFactory.NODE_TYPES.ACTION_CONTENT,
		"mode": "",
		"id": "",
		"id_suffixes" : [],
		"tags" : [],
		"value" : "",
		"speaker": "",
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
			"content": [{
				"type":  NodeFactory.NODE_TYPES.ACTION_CONTENT,
				"mode": "",
				"id": "",
				"id_suffixes" : [],
				"tags" : [],
				"value" : "",
				"speaker": "",
				"actions": [{
					"type": NodeFactory.NODE_TYPES.EVENTS,
					"events": [{ "type": NodeFactory.NODE_TYPES.EVENT, "name": 'event' } ],
				}],
				"content": [_create_content_payload([{
						"type":  NodeFactory.NODE_TYPES.LINE_PART,
						"part": {"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
							"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
							"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'cheese', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
							},
						"end_line" : true,
				}])],
			}],
		}],
	}])
	assert_eq_deep(result, expected)

func test_parser_placement_depentdent_slice_conditional_text():
	var result = parse('cheese [ set x = 5 ][when chicken] cakes')
	
	var expected = _create_doc_payload([_create_content_payload([
			{
				"type":  NodeFactory.NODE_TYPES.LINE_PART,
				"part": _line({"type":  NodeFactory.NODE_TYPES.LINE, "value": "cheese " }),
				"end_line" : false,
			},
			{
				"type":  NodeFactory.NODE_TYPES.LINE_PART,
				"part": _actionContent({"type":  NodeFactory.NODE_TYPES.ACTION_CONTENT,
					"mode": "",
					"id": "",
					"id_suffixes" : [],
					"tags" : [],
					"name" : "",
					"speaker": "",
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
				"end_line" : false,
			},
			{
				"type":  NodeFactory.NODE_TYPES.LINE_PART,
				"part":{"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
							"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
							"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": ' cakes', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
							},
				"end_line" : true,
			}
		])
	])
	assert_eq_deep(result, expected)
	

func test_parser_placement_depentdent_slice_conditional_text_more():
	var result = parse('[when cheken]cheese [ set x = 5 ][when chicken] cakes')
	
	var expected = _create_doc_payload([_create_content_payload([
			{
				"type":  NodeFactory.NODE_TYPES.LINE_PART,
				"part":{"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
							"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "cheken" },
							"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'cheese ', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
							},
				"end_line" : false,
			},
			{
				"type":  NodeFactory.NODE_TYPES.LINE_PART,
				"part": _actionContent({"type":  NodeFactory.NODE_TYPES.ACTION_CONTENT,
					"mode": "",
					"id": "",
					"id_suffixes" : [],
					"tags" : [],
					"name" : "",
					"speaker": "",
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
				"end_line" : false,
			},
			{
				"type":  NodeFactory.NODE_TYPES.LINE_PART,
				"part":{"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
							"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
							"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": ' cakes', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
							},
				"end_line" : true,
			}
		])
	])
	assert_eq_deep(result, expected)


func test_parser_placement_depentdent_slice_conditional_text_trigger():
	var result = parse('[when cheken]cheese [ set x = 5 ][trigger chicken] cakes')
	
	var expected = _create_doc_payload([_create_content_payload([
			{
				"type":  NodeFactory.NODE_TYPES.LINE_PART,
				"part":{"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
							"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "cheken" },
							"content": [_line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'cheese ', "speaker": "", "id": "", "tags": [], "id_suffixes": [], })],
							},
				"end_line" : false,
			},
			{
				"type":  NodeFactory.NODE_TYPES.LINE_PART,
				"part": _actionContent({"type":  NodeFactory.NODE_TYPES.ACTION_CONTENT,
					"mode": "",
					"id": "",
					"id_suffixes" : [],
					"tags" : [],
					"name" : "",
					"speaker": "",
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
				"end_line" : false,
			},
			{
				"type":  NodeFactory.NODE_TYPES.LINE_PART,
				"part":{"type":  NodeFactory.NODE_TYPES.ACTION_CONTENT,
		"mode": "",
		"id": "",
		"id_suffixes" : [],
		"tags" : [],
		"value" : "",
		"speaker": "",
		"actions": [{
			"type": NodeFactory.NODE_TYPES.EVENTS,
			"events": [{ "type": NodeFactory.NODE_TYPES.EVENT, "name": 'chicken' }],
		}],
		"content": [{
			"type":  NodeFactory.NODE_TYPES.LINE,
			"value": ' cakes', "speaker": "", "id": "", "tags": [], "id_suffixes": [],
		}]},
				"end_line" : true,
			}
		])
	])
	assert_eq_deep(result, expected)
	

func test_parser_placement_depentdent_conditional_text_after():
	var result = parse('cheese cakes[when chicken]')
	
	var expected = _create_doc_payload([_create_content_payload([
			{
				"type":  NodeFactory.NODE_TYPES.LINE_PART,
				"part": _line({ "type":  NodeFactory.NODE_TYPES.LINE, "value": "cheese cakes" }),
				"end_line" : false,
			},
			{
				"type":  NodeFactory.NODE_TYPES.LINE_PART,
				"part": {"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
					"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "chicken" },
					"content": [],
					},
				"end_line" : true,
			},
		])
	])
	assert_eq_deep(result, expected)
	

func test_standalone_assignment_with_standalone_variable():
	var result = parse("[ set a ]")

	var expected = _create_doc_payload([_create_content_payload([{
		"type": NodeFactory.NODE_TYPES.LINE_PART,
		"part":
		_actionContent({"type":  NodeFactory.NODE_TYPES.ACTION_CONTENT,
					"mode": "",
					"id": "",
					"id_suffixes" : [],
					"tags" : [],
					"name" : "",
					"speaker": "",
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
					"content": [],
					}),
		"end_line": true
		}])
	])
	assert_eq_deep(result, expected)

func test_divert_with_assignment():
	var result = parse("-> go [ set a = 2 ]")
	var expected = _create_doc_payload([
		{ "type": NodeFactory.NODE_TYPES.DIVERT, "target": 'go' },
		_create_content_payload([
			{
				"type":  NodeFactory.NODE_TYPES.LINE_PART,
				"part":{
					"type":  NodeFactory.NODE_TYPES.ACTION_CONTENT,
					"mode": "",
					"id": "",
					"id_suffixes" : [],
					"tags" : [],
					"value" : "",
					"speaker": "",
					"content" : [],
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
				},
				"end_line": true
			}
		])])

	assert_eq_deep(result, expected)


func test_options_assignment():
	var result = parse("""
*= [ set a = 2 ] option 1
*= option 2 [ set b = 3 ]
*= [ set c = 4 ] option 3
""")
	var expected = _create_doc_payload([{
		"type": NodeFactory.NODE_TYPES.OPTIONS,
		"value": "",
		"speaker": "", "id": "", "tags": [], "id_suffixes": [],
		"content": [
			{
				"type": NodeFactory.NODE_TYPES.ACTION_CONTENT,
				"mode": "",
				"id": "",
				"id_suffixes" : [],
				"tags" : [],
				"value" : "",
				"speaker": "",
				"actions": [{
					"type":  NodeFactory.NODE_TYPES.ASSIGNMENTS,
					"assignments": [{ "type":  NodeFactory.NODE_TYPES.ASSIGNMENT, "variable": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'a', }, "operation": "ASSIGN", "value": { "type": NodeFactory.NODE_TYPES.NUMBER_LITERAL, "value": 2.0, }, }, ],
				}],
				"content": [{ "type": NodeFactory.NODE_TYPES.OPTION, "value": 'option 1', "mode": 'once', "speaker": "", "id": "", "tags": [], "id_suffixes": [],
					"content":  [
							{ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'option 1', "speaker": "", "id": "", "tags": [], "id_suffixes": [], },
						],
				}],
			},
			{
				"type": NodeFactory.NODE_TYPES.ACTION_CONTENT,
				"mode": "",
				"id": "",
				"id_suffixes" : [],
				"tags" : [],
				"value" : "",
				"speaker": "",
				"actions": [{
					"type":  NodeFactory.NODE_TYPES.ASSIGNMENTS,
					"assignments": [{ "type":  NodeFactory.NODE_TYPES.ASSIGNMENT, "variable": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'b', }, "operation": "ASSIGN", "value": { "type": NodeFactory.NODE_TYPES.NUMBER_LITERAL, "value": 3.0, }, }, ],
				}],
				"content": [{ "type": NodeFactory.NODE_TYPES.OPTION, "value": 'option 2', "mode": 'once', "speaker": "", "id": "", "tags": [], "id_suffixes": [],
					"content":  [
							{ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'option 2', "speaker": "", "id": "", "tags": [], "id_suffixes": [], },
						],
				}],
			},
			{
				"type": NodeFactory.NODE_TYPES.ACTION_CONTENT,
				"mode": "",
				"id": "",
				"id_suffixes" : [],
				"tags" : [],
				"value" : "",
				"speaker": "",
				"actions": [{
					"type":  NodeFactory.NODE_TYPES.ASSIGNMENTS,
					"assignments": [{ "type":  NodeFactory.NODE_TYPES.ASSIGNMENT, "variable": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'c', }, "operation": "ASSIGN", "value": { "type": NodeFactory.NODE_TYPES.NUMBER_LITERAL, "value": 4.0, }, }, ],
				}],
				"content": [{ "type": NodeFactory.NODE_TYPES.OPTION, "value": 'option 3', "mode": 'once', "speaker": "", "id": "", "tags": [], "id_suffixes": [],
					"content": [
							{ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'option 3', "speaker": "", "id": "", "tags": [], "id_suffixes": [], },
						],
				}],
			},
		],
		}
	])
	assert_eq_deep(result, expected)
