extends "res://addons/gut/test.gd"


func parse(input):
	var parser = Parser.new()
	return parser.to_JSON_object(parser.parse(input))

func _create_doc_payload(content = [], blocks = []):
	return {
		"type":  NodeFactory.NODE_TYPES.DOCUMENT,
		"content": content,
		"blocks": blocks
	}

func test_condition_single_var():
	var result = parse("{ some_var } This is conditional")
	var expected = _create_doc_payload([
		{
			"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
			"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "some_var" },
			"content": [{ "type":  NodeFactory.NODE_TYPES.LINE, "value": "This is conditional", "speaker": "", "id": "", "tags": [], "id_suffixes": [], }]
		},
	])
	assert_eq_deep(result, expected)

func test_condition_with_multiline_dialogue():
	var result = parse("""{ another_var } This is conditional
		multiline
""")

	var expected = _create_doc_payload([{
		"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
		"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "another_var" },
		"content": [{ "type":  NodeFactory.NODE_TYPES.LINE, "value": "This is conditional multiline", "speaker": "", "id": "", "tags": [], "id_suffixes": [], }]
	}])
	assert_eq_deep(result, expected)


func test_not_operator():
	var result = parse("{ not some_var } This is conditional")

	var expected = _create_doc_payload([
		{
			"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
			"conditions": {
				"type":  NodeFactory.NODE_TYPES.EXPRESSION,
				"name": "NOT",
				"elements": [{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "some_var" }]
			},
			"content": [{ "type":  NodeFactory.NODE_TYPES.LINE, "value": "This is conditional", "speaker": "", "id": "", "tags": [], "id_suffixes": [], }]
		}
	])
	assert_eq_deep(result, expected)


func test_and_operator():
	var result = parse("""{ first_time && second_time } npc: what do you want to talk about? """)

	var expected = _create_doc_payload([
		{
			"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
			"conditions": {
				"type":  NodeFactory.NODE_TYPES.EXPRESSION,
				"name": 'AND',
				"elements": [
					{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'first_time', },
					{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'second_time', },
				],
			},
			"content": [{ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'what do you want to talk about?', "speaker": 'npc', "id": "", "tags": [], "id_suffixes": [], }],
		}
	])
	assert_eq_deep(result, expected)


func test_multiple_logical_checks_and_and_or():
	var result = parse("{ first_time and second_time or third_time } npc: what do you want to talk about?")

	var expected = _create_doc_payload([
		{
			"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
			"conditions": {
				"type":  NodeFactory.NODE_TYPES.EXPRESSION,
				"name": 'OR',
				"elements": [
					{
						"type":  NodeFactory.NODE_TYPES.EXPRESSION,
						"name": 'AND',
						"elements": [
							{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'first_time', },
							{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'second_time', },
						],
					},
					{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'third_time', },
				],
			},
			"content": [{ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'what do you want to talk about?', "speaker": 'npc', "id": "", "tags": [], "id_suffixes": [], }],
		}
	])
	assert_eq_deep(result, expected)


func test_multiple_equality_check():
	var result = parse("{ first_time == second_time or third_time != fourth_time } equality")

	var expected = _create_doc_payload([
		{
			"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
			"conditions": {
				"type":  NodeFactory.NODE_TYPES.EXPRESSION,
				"name": 'OR',
				"elements": [
					{
						"type":  NodeFactory.NODE_TYPES.EXPRESSION,
						"name": "LOGICAL_EQUAL",
						"elements": [
							{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'first_time', },
							{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'second_time', },
						],
					},
					{
						"type":  NodeFactory.NODE_TYPES.EXPRESSION,
						"name": "LOGICAL_NOT_EQUAL",
						"elements": [
							{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'third_time', },
							{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'fourth_time', },
						],
					},
				],
			},
			"content": [{ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'equality', "speaker": "", "id": "", "tags": [], "id_suffixes": [], }],
		}
	])
	assert_eq_deep(result, expected)


func test_multiple_alias_equality_check():
	var result = parse("{ first_time is second_time or third_time isnt fourth_time } alias equality")

	var expected = _create_doc_payload([
		{
			"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
			"conditions": {
				"type":  NodeFactory.NODE_TYPES.EXPRESSION,
				"name": 'OR',
				"elements": [
					{
						"type":  NodeFactory.NODE_TYPES.EXPRESSION,
						"name": "LOGICAL_EQUAL",
						"elements": [
							{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'first_time', },
							{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'second_time', },
						],
					},
					{
						"type":  NodeFactory.NODE_TYPES.EXPRESSION,
						"name": "LOGICAL_NOT_EQUAL",
						"elements": [
							{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'third_time', },
							{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'fourth_time', },
						],
					},
				],
			},
			"content": [{ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'alias equality', "speaker": "", "id": "", "tags": [], "id_suffixes": [], }],
		}
	])
	assert_eq_deep(result, expected)


func test_less_or_greater():
	var result = parse("{ first_time < second_time or third_time > fourth_time } comparison")

	var expected = _create_doc_payload([
		{
			"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
			"conditions": {
				"type":  NodeFactory.NODE_TYPES.EXPRESSION,
				"name": 'OR',
				"elements": [
					{
						"type":  NodeFactory.NODE_TYPES.EXPRESSION,
						"name": "LESS_THEN",
						"elements": [
							{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'first_time', },
							{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'second_time', },
						],
					},
					{
						"type":  NodeFactory.NODE_TYPES.EXPRESSION,
						"name": "GREATER_THEN",
						"elements": [
							{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'third_time', },
							{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'fourth_time', },
						],
					},
				],
			},
			"content": [{ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'comparison', "speaker": "", "id": "", "tags": [], "id_suffixes": [], }],
		},
	])
	assert_eq_deep(result, expected)


func test_less_or_equal_and_greater_or_equal():
	var result = parse("{ first_time <= second_time and third_time >= fourth_time } second comparison")

	var expected = _create_doc_payload([
		{
			"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
			"conditions": {
				"type":  NodeFactory.NODE_TYPES.EXPRESSION,
				"name": 'AND',
				"elements": [
					{
						"type":  NodeFactory.NODE_TYPES.EXPRESSION,
						"name": "LESS_OR_EQUAL_THEN",
						"elements": [
							{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'first_time', },
							{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'second_time', },
						],
					},
					{
						"type":  NodeFactory.NODE_TYPES.EXPRESSION,
						"name": "GREATER_OR_EQUAL_THEN",
						"elements": [
							{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'third_time', },
							{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'fourth_time', },
						],
					},
				],
			},
			"content": [{ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'second comparison', "speaker": "", "id": "", "tags": [], "id_suffixes": [], }],
		}
	])
	assert_eq_deep(result, expected)



func test__complex_precendence_case():
	var result = parse("{ first_time > x + y - z * d / e % b } test")

	var expected = _create_doc_payload([
		{
			"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
			"conditions": {
				"type":  NodeFactory.NODE_TYPES.EXPRESSION,
				"name": "GREATER_THEN",
				"elements": [
					{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'first_time', },
					{
						"type":  NodeFactory.NODE_TYPES.EXPRESSION,
						"name": "MINUS",
						"elements": [
							{
								"type":  NodeFactory.NODE_TYPES.EXPRESSION,
								"name": "PLUS",
								"elements": [
									{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'x', },
									{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'y', },
								],
							},
							{
								"type":  NodeFactory.NODE_TYPES.EXPRESSION,
								"name": "MOD",
								"elements": [
									{
										"type":  NodeFactory.NODE_TYPES.EXPRESSION,
										"name": "DIVIDE",
										"elements": [
											{
												"type":  NodeFactory.NODE_TYPES.EXPRESSION,
												"name": "MULTIPLY",
												"elements": [
													{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'z', },
													{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'd', },
												],
											},
											{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'e', },
										],
									},
									{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'b', },
								],
							},
						],
					},
				],
			},
			"content": [{ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'test', "speaker": "", "id": "", "tags": [], "id_suffixes": [], }],
		},
	])
	assert_eq_deep(result, expected)



func test_number_literal():
	var result = parse("{ first_time > 0 } hey")

	var expected = _create_doc_payload([
		{
			"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
			"conditions": {
				"type":  NodeFactory.NODE_TYPES.EXPRESSION,
				"name": "GREATER_THEN",
				"elements": [
					{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'first_time', },
					{ "type": NodeFactory.NODE_TYPES.NUMBER_LITERAL, "value": 0.0, },
				],
			},
			"content": [{ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'hey', "speaker": "", "id": "", "tags": [], "id_suffixes": [], }],
		},
	])
	assert_eq_deep(result, expected)



func test__null_token():
	var result = parse("{ first_time != null } ho")

	var expected = _create_doc_payload([
		{
			"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
			"conditions": {
				"type":  NodeFactory.NODE_TYPES.EXPRESSION,
				"name": "LOGICAL_NOT_EQUAL",
				"elements": [
					{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'first_time', },
					{ "type": NodeFactory.NODE_TYPES.NULL},
				],
			},
			"content": [{ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'ho', "speaker": "", "id": "", "tags": [], "id_suffixes": [], }],
		}
	])
	assert_eq_deep(result, expected)



func test_boolean_literal():
	var result = parse("{ first_time is false } let's go")

	var expected = _create_doc_payload([
		{
			"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
			"conditions": {
				"type":  NodeFactory.NODE_TYPES.EXPRESSION,
				"name": "LOGICAL_EQUAL",
				"elements": [
					{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'first_time', },
					{ "type": NodeFactory.NODE_TYPES.BOOLEAN_LITERAL, "value": false, },
				],
			},
			"content": [{ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'let\'s go', "speaker": "", "id": "", "tags": [], "id_suffixes": [], }],
		}
	])
	assert_eq_deep(result, expected)


func test_string_literal():
	var result = parse("{ first_time is \"hello darkness >= my old friend\" } let's go")

	var expected = _create_doc_payload([
		{
			"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
			"conditions": {
				"type":  NodeFactory.NODE_TYPES.EXPRESSION,
				"name": "LOGICAL_EQUAL",
				"elements": [
					{ "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'first_time', },
					{ "type": NodeFactory.NODE_TYPES.STRING_LITERAL, "value": 'hello darkness >= my old friend', },
				],
			},
			"content": [{ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'let\'s go', "speaker": "", "id": "", "tags": [], "id_suffixes": [], }],
		}
	])
	assert_eq_deep(result, expected)

func test_condition_before_line_with_keyword():
	var result = parse("{ when some_var } This is conditional")
	var expected = _create_doc_payload([
		{
			"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
			"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "some_var" },
			"content": [{ "type":  NodeFactory.NODE_TYPES.LINE, "value": "This is conditional", "speaker": "", "id": "", "tags": [], "id_suffixes": [], }]
		},
	])
	assert_eq_deep(result, expected)


func test_condition_after_line():
	var result = parse("This is conditional { when some_var }")
	var expected = _create_doc_payload([
		{
			"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
			"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "some_var" },
			"content": [{ "type":  NodeFactory.NODE_TYPES.LINE, "value": "This is conditional", "speaker": "", "id": "", "tags": [], "id_suffixes": [], }]
		},
	])
	assert_eq_deep(result, expected)


func test_condition_after_line_without_when():
	var result = parse("This is conditional { some_var }")
	var expected = _create_doc_payload([
		{
			"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
			"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "some_var" },
			"content": [{ "type":  NodeFactory.NODE_TYPES.LINE, "value": "This is conditional", "speaker": "", "id": "", "tags": [], "id_suffixes": [], }]
		},
	])
	assert_eq_deep(result, expected)



func test_conditional_divert():
	var result = parse("{ some_var } -> some_block")
	var expected = _create_doc_payload([
		{
			"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
			"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "some_var" },
			"content": [{ "type": NodeFactory.NODE_TYPES.DIVERT, "target": "some_block", }]
		},
	])
	assert_eq_deep(result, expected)


func test_conditional_divert_after():
	var result = parse("-> some_block { some_var }")
	var expected = _create_doc_payload([
		{
			"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
			"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "some_var" },
			"content": [{ "type": NodeFactory.NODE_TYPES.DIVERT, "target": "some_block", }]
		},
	])
	assert_eq_deep(result, expected)


func test_conditional_option():
	var result = parse("""
*= { some_var } option 1
*= option 2 { when some_var }
*= { some_other_var } option 3
""")
	var expected = _create_doc_payload([{
		"type": NodeFactory.NODE_TYPES.OPTIONS,
		"name": "",
		"speaker": "", "id": "", "tags": [], "id_suffixes": [],
		"content": [
			{
				"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
				"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "some_var" },
				"content": [{
					"type": NodeFactory.NODE_TYPES.OPTION,
					"name": 'option 1',
					"mode": 'once', "speaker": "", "id": "", "tags": [], "id_suffixes": [],
					"content":  [{ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'option 1', "speaker": "", "id": "", "tags": [], "id_suffixes": [], }],
					
				}],
			},
			{
				"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
				"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "some_var" },
				"content": [{
					"type": NodeFactory.NODE_TYPES.OPTION,
					"name": 'option 2',
					"mode": 'once', "speaker": "", "id": "", "tags": [], "id_suffixes": [],
					"content": [{ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'option 2', "speaker": "", "id": "", "tags": [], "id_suffixes": [], },],
				}],
			},
			{
				"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
				"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "some_other_var" },
				"content": [{
					"type": NodeFactory.NODE_TYPES.OPTION,
					"name": 'option 3',
					"mode": 'once', "speaker": "", "id": "", "tags": [], "id_suffixes": [],
					"content":  [{ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'option 3', "speaker": "", "id": "", "tags": [], "id_suffixes": [], }],
				}],
			},
		],
			}
	])
	assert_eq_deep(result, expected)


func test_conditional_indented_block():
	var result = parse("""
{ some_var }
	This is conditional
	This is second conditional
	This is third conditional
""")
	var expected = _create_doc_payload([
		{
			"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
			"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "some_var" },
			"content": [
					{ "type":  NodeFactory.NODE_TYPES.LINE, "value": "This is conditional", "speaker": "", "id": "", "tags": [], "id_suffixes": [], },
					{ "type":  NodeFactory.NODE_TYPES.LINE, "value": "This is second conditional", "speaker": "", "id": "", "tags": [], "id_suffixes": [], },
					{ "type":  NodeFactory.NODE_TYPES.LINE, "value": "This is third conditional", "speaker": "", "id": "", "tags": [], "id_suffixes": [], }
				]
			
		},
	])
	assert_eq_deep(result, expected)


const assignments = [
	[ "=", "ASSIGN"],
	[ "+=", "SUM_ASSIGN"],
	[ "-=", "SUBTRACTION_ASSIGN"],
	[ "*=", "MULITPLICATION_ASSIGN"],
	[ "/=", "DIVISION_ASSIGN"],
	[ "%=", "MOD_ASSIGN"],
	[ "^=", "POWER_ASSIGN"],
]

func test_assignments():
	for a in assignments:
		_assignment_tests(a[0], a[1])


func _assignment_tests(token, node_name):
	var result = parse("{ set a %s 2 } let's go" % token)
	var expected = _create_doc_payload([{
		"type":  NodeFactory.NODE_TYPES.ACTION_CONTENT,
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
					"operation": node_name,
					"value": { "type": NodeFactory.NODE_TYPES.NUMBER_LITERAL, "value": 2.0, },
				},
			],
		}],
		"content": [{ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'let\'s go', "speaker": "", "id": "", "tags": [], "id_suffixes": [], }],
	}])
	assert_eq_deep(result, expected)


func test_assignment_with_expression():
	var result = parse('{ set a -= 4 ^ 2 } let\'s go')
	var expected = _create_doc_payload([{
		"type":  NodeFactory.NODE_TYPES.ACTION_CONTENT,
		"speaker": "",
		"id": "", 
		"tags": [], 
		"name": "",
		"id_suffixes": [],
		"mode": "",
		"actions": [{
			"type":  NodeFactory.NODE_TYPES.ASSIGNMENTS,
			"assignments": [
				{
					"type":  NodeFactory.NODE_TYPES.ASSIGNMENT,
					"variable": {
						"type":  NodeFactory.NODE_TYPES.VARIABLE,
						"name": 'a',
					},
					"operation": "SUBTRACTION_ASSIGN",
					"value": {
						"type":  NodeFactory.NODE_TYPES.EXPRESSION,
						"name": "POWER",
						"elements": [
							{
								"type": NodeFactory.NODE_TYPES.NUMBER_LITERAL,
								"value": 4.0,
							},
							{
								"type": NodeFactory.NODE_TYPES.NUMBER_LITERAL,
								"value": 2.0,
							},
						],
					},
				},
			],
		}],
		"content": [{ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'let\'s go', "speaker": "", "id": "", "tags": [], "id_suffixes": [], }],
	
	}])
	assert_eq_deep(result, expected)


func test_assignment_with_expression_after():
	var result = parse('multiply { set a = a * 2 }')
	var expected = _create_doc_payload([{
		"type":  NodeFactory.NODE_TYPES.ACTION_CONTENT,
		"mode": "",
		"id": "",
		"id_suffixes" : [],
		"tags" : [],
		"name" : "",
		"speaker": "",
		"actions": [{
			"type":  NodeFactory.NODE_TYPES.ASSIGNMENTS,
			"assignments": [
				{
					"type":  NodeFactory.NODE_TYPES.ASSIGNMENT,
					"variable": {
						"type":  NodeFactory.NODE_TYPES.VARIABLE,
						"name": 'a',
					},
					"operation": "ASSIGN",
					"value": {
						"type":  NodeFactory.NODE_TYPES.EXPRESSION,
						"name": "MULTIPLY",
						"elements": [
							{
								"type":  NodeFactory.NODE_TYPES.VARIABLE,
								"name": 'a',
							},
							{
								"type": NodeFactory.NODE_TYPES.NUMBER_LITERAL,
								"value": 2.0,
							},
						],
					},
				},
			],
		}],
		"content": [{ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'multiply', "speaker": "", "id": "", "tags": [], "id_suffixes": [], }],
	}])
	assert_eq_deep(result, expected)


func test_chaining_assigments():
	var result = parse('{ set a = b = c = d = 3 } let\'s go')
	var expected = _create_doc_payload([{
		"type":  NodeFactory.NODE_TYPES.ACTION_CONTENT,
		"mode": "",
		"id": "",
		"id_suffixes" : [],
		"tags" : [],
		"name" : "",
		"speaker": "",
		"actions": [{
			"type":  NodeFactory.NODE_TYPES.ASSIGNMENTS,
			"assignments": [
				{
					"type":  NodeFactory.NODE_TYPES.ASSIGNMENT,
					"variable": {
						"type":  NodeFactory.NODE_TYPES.VARIABLE,
						"name": 'a',
					},
					"operation": "ASSIGN",
					"value": {
						"type":  NodeFactory.NODE_TYPES.ASSIGNMENT,
						"variable": {
							"type":  NodeFactory.NODE_TYPES.VARIABLE,
							"name": 'b',
						},
						"operation": "ASSIGN",
						"value": {
							"type":  NodeFactory.NODE_TYPES.ASSIGNMENT,
							"variable": {
								"type":  NodeFactory.NODE_TYPES.VARIABLE,
								"name": 'c',
							},
							"operation": "ASSIGN",
							"value": {
								"type":  NodeFactory.NODE_TYPES.ASSIGNMENT,
								"variable": {
									"type":  NodeFactory.NODE_TYPES.VARIABLE,
									"name": 'd',
								},
								"operation": "ASSIGN",
								"value": {
									"type": NodeFactory.NODE_TYPES.NUMBER_LITERAL,
									"value": 3.0,
								},
							},
						},
					},
				},
			],
		}],
		"content": [{ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'let\'s go', "speaker": "", "id": "", "tags": [], "id_suffixes": [], }],
	}])
	assert_eq_deep(result, expected)


func test_chaining_assigment_ending_with_variable():
		var result = parse('{ set a = b = c } let\'s go')
		var expected = _create_doc_payload([{
			"type":  NodeFactory.NODE_TYPES.ACTION_CONTENT,
			"mode": "",
			"id": "",
			"id_suffixes" : [],
			"tags" : [],
			"name" : "",
			"speaker": "",
			"actions": [{
				"type":  NodeFactory.NODE_TYPES.ASSIGNMENTS,
				"assignments": [
					{
						"type":  NodeFactory.NODE_TYPES.ASSIGNMENT,
						"variable": {
							"type":  NodeFactory.NODE_TYPES.VARIABLE,
							"name": 'a',
						},
						"operation": "ASSIGN",
						"value": {
							"type":  NodeFactory.NODE_TYPES.ASSIGNMENT,
							"variable": {
								"type":  NodeFactory.NODE_TYPES.VARIABLE,
								"name": 'b',
							},
							"operation": "ASSIGN",
							"value": {
								"type":  NodeFactory.NODE_TYPES.VARIABLE,
								"name": 'c',
							},
						},
					},
				],
			}],
			"content": [{ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'let\'s go', "speaker": "", "id": "", "tags": [], "id_suffixes": [], }],
		}])
		assert_eq_deep(result, expected)


func test_multiple_assigments_block():
	var result = parse('{ set a -= 4, b=1, c = "hello" } hey you')
	var expected = _create_doc_payload([{
		"type":  NodeFactory.NODE_TYPES.ACTION_CONTENT,
		"mode": "",
		"id": "",
		"id_suffixes" : [],
		"tags" : [],
		"name" : "",
		"speaker": "",
		"actions": [{
			"type":  NodeFactory.NODE_TYPES.ASSIGNMENTS,
			"assignments": [
				{
					"type":  NodeFactory.NODE_TYPES.ASSIGNMENT,
					"variable": {
						"type":  NodeFactory.NODE_TYPES.VARIABLE,
						"name": 'a',
					},
					"operation": "SUBTRACTION_ASSIGN",
					"value": {
						"type": NodeFactory.NODE_TYPES.NUMBER_LITERAL,
						"value": 4.0,
					},
				},
				{
					"type":  NodeFactory.NODE_TYPES.ASSIGNMENT,
					"variable": {
						"type":  NodeFactory.NODE_TYPES.VARIABLE,
						"name": 'b',
					},
					"operation": "ASSIGN",
					"value": {
						"type": NodeFactory.NODE_TYPES.NUMBER_LITERAL,
						"value": 1.0,
					},
				},
				{
					"type":  NodeFactory.NODE_TYPES.ASSIGNMENT,
					"variable": {
						"type":  NodeFactory.NODE_TYPES.VARIABLE,
						"name": 'c',
					},
					"operation": "ASSIGN",
					"value": {
						"type": NodeFactory.NODE_TYPES.STRING_LITERAL,
						"value": 'hello',
					},
				},
			],
		}],
		"content": [{ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'hey you', "speaker": "", "id": "", "tags": [], "id_suffixes": [], }],
	}])
	assert_eq_deep(result, expected)


func test_assignment_after_line():
	var result = parse("let's go { set a = 2 }")
	var expected = _create_doc_payload([{
		"type": NodeFactory.NODE_TYPES.ACTION_CONTENT,
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
					"type": NodeFactory.NODE_TYPES.ASSIGNMENT,
					"variable": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'a', },
					"operation": "ASSIGN",
					"value": { "type": NodeFactory.NODE_TYPES.NUMBER_LITERAL, "value": 2.0, },
				},
			],
		}],
		"content": [{ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'let\'s go', "speaker": "", "id": "", "tags": [], "id_suffixes": [], }],
	}])
	assert_eq_deep(result, expected)


func test_standalone_assignment():
	var result = parse("""
{ set a = 2 }
{ set b = 3 }""")

	var expected = _create_doc_payload([
		{
			"type":  NodeFactory.NODE_TYPES.ASSIGNMENTS,
			"assignments": [
				{
					"type":  NodeFactory.NODE_TYPES.ASSIGNMENT,
					"variable": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'a', },
					"operation": "ASSIGN",
					"value": { "type": NodeFactory.NODE_TYPES.NUMBER_LITERAL, "value": 2.0, },
				},
			],
		},
		{
			"type":  NodeFactory.NODE_TYPES.ASSIGNMENTS,
			"assignments": [
				{
					"type":  NodeFactory.NODE_TYPES.ASSIGNMENT,
					"variable": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'b', },
					"operation": "ASSIGN",
					"value": { "type": NodeFactory.NODE_TYPES.NUMBER_LITERAL, "value": 3.0, },
				},
			],
		}
	])
	assert_eq_deep(result, expected)


func test_options_assignment():
	var result = parse("""
*= { set a = 2 } option 1
*= option 2 { set b = 3 }
*= { set c = 4 } option 3
""")
	var expected = _create_doc_payload([{
		"type": NodeFactory.NODE_TYPES.OPTIONS,
		"name": "",
		"speaker": "", "id": "", "tags": [], "id_suffixes": [],
		"content": [
			{
				"type": NodeFactory.NODE_TYPES.ACTION_CONTENT,
				"mode": "",
				"id": "",
				"id_suffixes" : [],
				"tags" : [],
				"name" : "",
				"speaker": "",
				"actions": [{
					"type":  NodeFactory.NODE_TYPES.ASSIGNMENTS,
					"assignments": [{ "type":  NodeFactory.NODE_TYPES.ASSIGNMENT, "variable": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'a', }, "operation": "ASSIGN", "value": { "type": NodeFactory.NODE_TYPES.NUMBER_LITERAL, "value": 2.0, }, }, ],
				}],
				"content": [{ "type": NodeFactory.NODE_TYPES.OPTION, "name": 'option 1', "mode": 'once', "speaker": "", "id": "", "tags": [], "id_suffixes": [],
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
				"name" : "",
				"speaker": "",
				"actions": [{
					"type":  NodeFactory.NODE_TYPES.ASSIGNMENTS,
					"assignments": [{ "type":  NodeFactory.NODE_TYPES.ASSIGNMENT, "variable": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'b', }, "operation": "ASSIGN", "value": { "type": NodeFactory.NODE_TYPES.NUMBER_LITERAL, "value": 3.0, }, }, ],
				}],
				"content": [{ "type": NodeFactory.NODE_TYPES.OPTION, "name": 'option 2', "mode": 'once', "speaker": "", "id": "", "tags": [], "id_suffixes": [],
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
				"name" : "",
				"speaker": "",
				"actions": [{
					"type":  NodeFactory.NODE_TYPES.ASSIGNMENTS,
					"assignments": [{ "type":  NodeFactory.NODE_TYPES.ASSIGNMENT, "variable": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": 'c', }, "operation": "ASSIGN", "value": { "type": NodeFactory.NODE_TYPES.NUMBER_LITERAL, "value": 4.0, }, }, ],
				}],
				"content": [{ "type": NodeFactory.NODE_TYPES.OPTION, "name": 'option 3', "mode": 'once', "speaker": "", "id": "", "tags": [], "id_suffixes": [],
					"content": [
							{ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'option 3', "speaker": "", "id": "", "tags": [], "id_suffixes": [], },
						],
				}],
			},
		],
		}
	])
	assert_eq_deep(result, expected)


func test_divert_with_assignment():
	var result = parse("-> go { set a = 2 }")
	var expected = _create_doc_payload([{
		"type":  NodeFactory.NODE_TYPES.ACTION_CONTENT,
		"mode": "",
		"id": "",
		"id_suffixes" : [],
		"tags" : [],
		"name" : "",
		"speaker": "",
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
		}],
		"content": [{ "type": NodeFactory.NODE_TYPES.DIVERT, "target": 'go' }],
	}])
	assert_eq_deep(result, expected)


func test_standalone_assignment_with_standalone_variable():
	var result = parse("{ set a }")

	var expected = _create_doc_payload([
		{
			"type": NodeFactory.NODE_TYPES.ASSIGNMENTS,
			"assignments": [
				{
					"type": NodeFactory.NODE_TYPES.ASSIGNMENT,
					"variable": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "a", },
					"operation": "ASSIGN",
					"value": { "type": NodeFactory.NODE_TYPES.BOOLEAN_LITERAL, "value": true, },
				},
			],
		},
	])
	assert_eq_deep(result, expected)


func test_trigger_event():
	var result = parse("{ trigger some_event } trigger")
	var expected = _create_doc_payload([{
		"type":  NodeFactory.NODE_TYPES.ACTION_CONTENT,
		"mode": "",
		"id": "",
		"id_suffixes" : [],
		"tags" : [],
		"name" : "",
		"speaker": "",
		"actions": [{
			"type": NodeFactory.NODE_TYPES.EVENTS,
			"events": [{ "type": NodeFactory.NODE_TYPES.EVENT, "name": 'some_event' }],
		}],
		"content": [{
			"type":  NodeFactory.NODE_TYPES.LINE,
			"value": 'trigger', "speaker": "", "id": "", "tags": [], "id_suffixes": [],
		}],
	}])
	assert_eq_deep(result, expected)


func test_trigger_multiple_events_in_one_block():
	var result = parse("{ trigger some_event, another_event } trigger")
	var expected = _create_doc_payload([{
		"type":  NodeFactory.NODE_TYPES.ACTION_CONTENT,
		"mode": "",
		"id": "",
		"id_suffixes" : [],
		"tags" : [],
		"name" : "",
		"speaker": "",
		"actions": [{
			"type": NodeFactory.NODE_TYPES.EVENTS,
			"events": [
				{ "type": NodeFactory.NODE_TYPES.EVENT, "name": 'some_event' },
				{ "type": NodeFactory.NODE_TYPES.EVENT, "name": 'another_event' }
		],
		}],
		"content": [{
			"type":  NodeFactory.NODE_TYPES.LINE,
			"value": 'trigger', "speaker": "", "id": "", "tags": [], "id_suffixes": [],
		}],
	}])
	assert_eq_deep(result, expected)


func test_standalone_trigger_event():
	var result = parse("{ trigger some_event }")
	var expected = _create_doc_payload([{
		"type": NodeFactory.NODE_TYPES.EVENTS,
		"events": [
			{ "type": NodeFactory.NODE_TYPES.EVENT, "name": 'some_event' },
		],
	}])
	assert_eq_deep(result, expected)


func test_trigger_event_after_line():
	var result = parse("trigger { trigger some_event }")
	var expected = _create_doc_payload([{
		"type":  NodeFactory.NODE_TYPES.ACTION_CONTENT,
		"mode": "",
		"id": "",
		"id_suffixes" : [],
		"tags" : [],
		"name" : "",
		"speaker": "",
		"actions": [{
			"type": NodeFactory.NODE_TYPES.EVENTS,
			"events": [{ "type": NodeFactory.NODE_TYPES.EVENT, "name": 'some_event' }],
		}],
		"content": [{
			"type":  NodeFactory.NODE_TYPES.LINE,
			"value": 'trigger', "speaker": "", "id": "", "tags": [], "id_suffixes": [],
		}],
	}])
	assert_eq_deep(result, expected)


func test_options_trigger():
	var result = parse("""
*= { trigger a } option 1
*= option 2 { trigger b }
*= { trigger c } option 3
""")
	var expected = _create_doc_payload([{
		"type": NodeFactory.NODE_TYPES.OPTIONS,
		"name": "",
		"speaker": "", "id": "", "tags": [], "id_suffixes": [],
		"content": [
			{
				"type": NodeFactory.NODE_TYPES.ACTION_CONTENT,
				"mode": "",
				"id": "",
				"id_suffixes" : [],
				"tags" : [],
				"name" : "",
				"speaker": "",
				"actions": [{
					"type": NodeFactory.NODE_TYPES.EVENTS,
					"events": [{ "type": NodeFactory.NODE_TYPES.EVENT, "name": 'a' }],
				}],
				"content": 
					[{ "type": NodeFactory.NODE_TYPES.OPTION, "name": 'option 1', "mode": 'once', "speaker": "", "id": "", "tags": [], "id_suffixes": [],
						"content": [ { "type":  NodeFactory.NODE_TYPES.LINE, "value": 'option 1', "speaker": "", "id": "", "tags": [], "id_suffixes": [], },],
					}],
			},
			{
				"type": NodeFactory.NODE_TYPES.ACTION_CONTENT,
				"mode": "",
				"id": "",
				"id_suffixes" : [],
				"tags" : [],
				"name" : "",
				"speaker": "",
				"actions": [{
					"type": NodeFactory.NODE_TYPES.EVENTS,
					"events": [{ "type": NodeFactory.NODE_TYPES.EVENT, "name": 'b' }],
				}],
				"content": [{ "type": NodeFactory.NODE_TYPES.OPTION, "name": 'option 2', "mode": 'once', "speaker": "", "id": "", "tags": [], "id_suffixes": [],
					"content": [{ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'option 2', "speaker": "", "id": "", "tags": [], "id_suffixes": [], },],
				}],
			},
			{
				"type": NodeFactory.NODE_TYPES.ACTION_CONTENT,
				"mode": "",
				"id": "",
				"id_suffixes" : [],
				"tags" : [],
				"name" : "",
				"speaker": "",
				"actions": [{
					"type": NodeFactory.NODE_TYPES.EVENTS,
					"events": [{ "type": NodeFactory.NODE_TYPES.EVENT, "name": 'c' }],
				}],
				"content": [{ "type": NodeFactory.NODE_TYPES.OPTION, "name": 'option 3', "mode": 'once', "speaker": "", "id": "", "tags": [], "id_suffixes": [],
					"content": [
							{ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'option 3', "speaker": "", "id": "", "tags": [], "id_suffixes": [], },
						],
				}],
			},
		],
		}
	])
	assert_eq_deep(result, expected)


func test_multiple_logic_blocks_in_the_same_line():
	var result = parse("{ some_var } {set something = 1} { trigger event }")
	var expected = _create_doc_payload([{
		"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
		"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "some_var" },
		"content": [{
			"type":  NodeFactory.NODE_TYPES.ACTION_CONTENT,
			"mode": "",
			"id": "",
			"id_suffixes" : [],
			"tags" : [],
			"name" : "",
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
				"type": NodeFactory.NODE_TYPES.EVENTS,
				"events": [{ "type": NodeFactory.NODE_TYPES.EVENT, "name": 'event' } ],
			}],
		}],
	}])
	assert_eq_deep(result, expected)


func test_multiple_logic_blocks_in_the_same_line_before():
	var result = parse("{ some_var } {set something = 1} { trigger event } hello")
	var expected = _create_doc_payload([{
		"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
		"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "some_var" },
		"content": [{
			"type":  NodeFactory.NODE_TYPES.ACTION_CONTENT,
			"mode": "",
			"id": "",
			"id_suffixes" : [],
			"tags" : [],
			"name" : "",
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
				"type":  NodeFactory.NODE_TYPES.ACTION_CONTENT,
				"mode": "",
				"id": "",
				"id_suffixes" : [],
				"tags" : [],
				"name" : "",
				"speaker": "",
				"actions": [{
					"type": NodeFactory.NODE_TYPES.EVENTS,
					"events": [{ "type": NodeFactory.NODE_TYPES.EVENT, "name": 'event' } ],
				}],
				"content": [{
					"type":  NodeFactory.NODE_TYPES.LINE,
					"value": 'hello', "speaker": "", "id": "", "tags": [], "id_suffixes": [],
				}],
			}],
		}],
	}])
	assert_eq_deep(result, expected)


func test_multiple_logic_blocks_in_the_same_line_after():
	var result = parse("hello { when some_var } {set something = 1} { trigger event }")
	var expected = _create_doc_payload([{
		"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
		"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "some_var" },
		"content": [{
			"type":  NodeFactory.NODE_TYPES.ACTION_CONTENT,
			"mode": "",
			"id": "",
			"id_suffixes" : [],
			"tags" : [],
			"name" : "",
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
				"type":  NodeFactory.NODE_TYPES.ACTION_CONTENT,
				"mode": "",
				"id": "",
				"id_suffixes" : [],
				"tags" : [],
				"name" : "",
				"speaker": "",
				"actions": [{
					"type": NodeFactory.NODE_TYPES.EVENTS,
					"events": [{ "type": NodeFactory.NODE_TYPES.EVENT, "name": 'event' } ],
				}],
				"content": [{
					"type":  NodeFactory.NODE_TYPES.LINE,
					"value": 'hello', "speaker": "", "id": "", "tags": [], "id_suffixes": [],
				}],
			}],
		}],
	}])
	assert_eq_deep(result, expected)


func test_multiple_logic_blocks_in_the_same_line_around():
	var result = parse("{ some_var } hello {set something = 1} { trigger event }")
	var expected = _create_doc_payload([{
		"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
		"conditions": { "type":  NodeFactory.NODE_TYPES.VARIABLE, "name": "some_var" },
		"content": [{
			"type":  NodeFactory.NODE_TYPES.ACTION_CONTENT,
			"mode": "",
			"id": "",
			"id_suffixes" : [],
			"tags" : [],
			"name" : "",
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
				"type":  NodeFactory.NODE_TYPES.ACTION_CONTENT,
				"mode": "",
				"id": "",
				"id_suffixes" : [],
				"tags" : [],
				"name" : "",
				"speaker": "",
				"actions": [{
					"type": NodeFactory.NODE_TYPES.EVENTS,
					"events": [{ "type": NodeFactory.NODE_TYPES.EVENT, "name": 'event' } ],
				}],
				"content": [{
					"type":  NodeFactory.NODE_TYPES.LINE,
					"value": 'hello', "speaker": "", "id": "", "tags": [], "id_suffixes": [],
				}],
			}],
		}],
	}])
	assert_eq_deep(result, expected)


func test_multiple_logic_blocks_with_condition_after():
	var result = parse("{set something = 1} { some_var } { trigger event } hello")
	var expected = _create_doc_payload([{
		"type":  NodeFactory.NODE_TYPES.ACTION_CONTENT,
		"mode": "",
		"id": "",
		"id_suffixes" : [],
		"tags" : [],
		"name" : "",
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
				"name" : "",
				"speaker": "",
				"actions": [{
					"type": NodeFactory.NODE_TYPES.EVENTS,
					"events": [{ "type": NodeFactory.NODE_TYPES.EVENT, "name": 'event' } ],
				}],
				"content": [{
					"type":  NodeFactory.NODE_TYPES.LINE,
					"value": 'hello', "speaker": "", "id": "", "tags": [], "id_suffixes": [],
				}],
			}],
		}],
	}])
	assert_eq_deep(result, expected)


func test_empty_block():
	var result = parse("{} empty")
	var expected = _create_doc_payload([{
		"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
		"content": [{ "type":  NodeFactory.NODE_TYPES.LINE, "value": 'empty', "speaker": "", "id": "", "tags": [], "id_suffixes": [], }],
		"conditions": {},
	}])
	assert_eq_deep(result, expected)


