extends "res://addons/gut/test.gd"


func parse(input):
	var parser = Parser.new()
	return parser.to_JSON_object(parser.parse(input))


func test_parse_options():
	var result = parse("""
npc: what do you want to talk about?
* speaker: Life
	player: I want to talk about life!
	npc: Well! That's too complicated...
* Everything else... #some_tag
	player: What about everything else?
	npc: I don't have time for this...
* one more thing $abc&whatever
	npc: one
""" )
	var expected = {
		"type":  NodeFactory.NODE_TYPES.DOCUMENT,
		"content": [
			{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'what do you want to talk about?', "speaker": 'npc', "id": "", "tags": [], "id_suffixes": [], },
			{
				"type": NodeFactory.NODE_TYPES.OPTIONS,
				"name": "",
				"speaker": "",
				"id": "",
				"tags": [],
				"id_suffixes": [],
				"content": [
					{
						"type": NodeFactory.NODE_TYPES.OPTION,
						"name": 'Life',
						"speaker": 'speaker',
						"id": "",
						"tags": [],
						"id_suffixes": [],
						"mode": 'once',
						"content":  [
								{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'I want to talk about life!', "speaker": 'player', "id": "", "tags": [], "id_suffixes": [], },
								{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'Well! That\'s too complicated...', "speaker": 'npc', "id": "", "tags": [], "id_suffixes": [], },
							],
						
					},
					{
						"type": NodeFactory.NODE_TYPES.OPTION,
						"name": 'Everything else...',
						"mode": 'once',
						"speaker": "",
						"id": "",
						"content":  [
								{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'What about everything else?', "speaker": 'player', "id": "", "tags": [], "id_suffixes": [], },
								{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'I don\'t have time for this...', "speaker": 'npc', "id": "", "tags": [], "id_suffixes": [], },
							],
						"tags": [ 'some_tag', ],
						"id_suffixes": [],
					},
					{
						"type": NodeFactory.NODE_TYPES.OPTION,
						"name": "one more thing",
						"mode": "once",
						"speaker": "",
						"tags": [],
						"content": [{ "type": NodeFactory.NODE_TYPES.LINE, "value": "one", "speaker": "npc","tags": [], "id": "", "id_suffixes": [], },],
						"id": "abc",
						"id_suffixes": [ "whatever" ],
						},
				],
			},
		],
		"blocks": [],
	}
	assert_eq_deep(result, expected)


func test_parse_sticky_option():
	var result = parse("""
npc: what do you want to talk about?
* Life
	player: I want to talk about life!
+ Everything else... #some_tag
	player: What about everything else?
""" )
	var expected = {
		"type":  NodeFactory.NODE_TYPES.DOCUMENT,
		"content":  [
			{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'what do you want to talk about?', "speaker": 'npc', "id": "", "tags": [], "id_suffixes": [], },
			{
				"type": NodeFactory.NODE_TYPES.OPTIONS,
				"name": "",
				"speaker": "",
				"id": "",
				"tags": [],
				"id_suffixes": [],
				"content": [
					{
						"type": NodeFactory.NODE_TYPES.OPTION,
						"name": 'Life',
						"mode": 'once',
						"speaker": "",
						"id": "",
						"tags": [],
						"id_suffixes": [],
						"content": [{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'I want to talk about life!', "speaker": 'player', "id": "", "tags": [], "id_suffixes": [], },],
					},
					{
						"type": NodeFactory.NODE_TYPES.OPTION,
						"name": 'Everything else...',
						"mode": 'sticky',
						"speaker": "",
						"id": "",
						"content":  [{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'What about everything else?', "speaker": 'player', "id": "", "tags": [], "id_suffixes": [], },],
						"tags": [ 'some_tag', ],
						"id_suffixes": [],
					},
				],
			},
		],
		"blocks": [],
	}
	assert_eq_deep(result, expected)


func test_parse_fallback_option():
	var result = parse("""
npc: what do you want to talk about?
* Life
	player: I want to talk about life!
> Everything else... #some_tag
	player: What about everything else?
""" )
	var expected = {
		"type":  NodeFactory.NODE_TYPES.DOCUMENT,
		"content":  [
			{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'what do you want to talk about?', "speaker": 'npc', "id": "", "tags": [], "id_suffixes": [], },
			{
				"type": NodeFactory.NODE_TYPES.OPTIONS,
				"name": "",
				"speaker": "",
				"id": "",
				"tags": [],
				"id_suffixes": [],
				"content": [
					{
						"type": NodeFactory.NODE_TYPES.OPTION,
						"name": 'Life',
						"mode": 'once',
						"speaker": "",
						"id": "",
						"tags": [],
						"id_suffixes": [],
						"content":  [{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'I want to talk about life!', "speaker": 'player', "id": "", "tags": [], "id_suffixes": [], },],
					},
					{
						"type": NodeFactory.NODE_TYPES.OPTION,
						"name": 'Everything else...',
						"mode": 'fallback',
						"speaker": "",
						"id": "",
						"content": [{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'What about everything else?', "speaker": 'player', "id": "", "tags": [], "id_suffixes": [], },],
						"tags": [ 'some_tag', ],
						"id_suffixes": [],
					},
				],
			},
		],
		"blocks": [],
	}
	assert_eq_deep(result, expected)



func test_define_label_to_display_as_content():
	var result = parse("""
npc: what do you want to talk about?
*= Life
	player: I want to talk about life!
	npc: Well! That's too complicated...
*= Everything else... #some_tag
	player: What about everything else?
	npc: I don't have time for this...
""" )
	var expected = {
		"type":  NodeFactory.NODE_TYPES.DOCUMENT,
		"content": [
			{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'what do you want to talk about?', "speaker": 'npc', "id": "", "tags": [], "id_suffixes": [], },
			{
				"type": NodeFactory.NODE_TYPES.OPTIONS,
				"name": "",
				"speaker": "",
				"id": "",
				"tags": [],
				"id_suffixes": [],
				"content": [
					{
						"type": NodeFactory.NODE_TYPES.OPTION,
						"name": 'Life',
						"mode": 'once',
						"id": "", "tags": [], "speaker": "",
						"id_suffixes": [],
						"content":  [
							{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'Life', "speaker": "", "id": "", "tags": [], "id_suffixes": [], },
							{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'I want to talk about life!', "speaker": 'player', "id": "", "tags": [], "id_suffixes": [], },
							{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'Well! That\'s too complicated...', "speaker": 'npc', "id": "", "tags": [], "id_suffixes": [], },
						],
					},
					{
						"type": NodeFactory.NODE_TYPES.OPTION,
						"name": 'Everything else...',
						"mode": 'once', "id": "", "speaker": "",
						"id_suffixes": [],
						"content":  [
							{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'Everything else...', "speaker": "", "id": "", "tags": [ 'some_tag', ], "id_suffixes": [], },
							{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'What about everything else?', "speaker": 'player', "id": "", "tags": [], "id_suffixes": [], },
							{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'I don\'t have time for this...', "speaker": 'npc', "id": "", "tags": [], "id_suffixes": [], },
						],
						"tags": [ 'some_tag'],
					},
				],
			},
		],
		"blocks": [],
	}
	assert_eq_deep(result, expected)

func test_use_first_line_as_label():
	var result = parse("""
*
	life
	player: I want to talk about life!
	npc: Well! That's too complicated...
*
	the universe #tag $id&suffix
""" )
	var expected = {
		"type":  NodeFactory.NODE_TYPES.DOCUMENT,
		"content": [
			{
				"type": NodeFactory.NODE_TYPES.OPTIONS,
				"name": "",
				"speaker": "",
				"id": "",
				"tags": [],
				"id_suffixes": [],
				"content": [
					{
						"type": NodeFactory.NODE_TYPES.OPTION,
						"name": 'life',
						"mode": 'once', "id": "", "tags": [], "speaker": "",
						"id_suffixes": [],
						"content":[
							{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'life', "id": "", "speaker": "", "tags": [], "id_suffixes": [], },
							{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'I want to talk about life!', "speaker": 'player', "id": "", "tags": [], "id_suffixes": [], },
							{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'Well! That\'s too complicated...', "speaker": 'npc', "id": "", "tags": [], "id_suffixes": [], },
						],
					},
					{
						"type": NodeFactory.NODE_TYPES.OPTION,
						"name": 'the universe',
						"mode": 'once', "id": "id", "tags": ["tag"], "speaker": "",
						"id_suffixes": ["suffix"],
						"content": [{ "type": NodeFactory.NODE_TYPES.LINE, "value": "the universe", "id": "id", "speaker": "", "tags": ["tag"], "id_suffixes": ["suffix"], },],
					},
				],
			},
		],
		"blocks": [],
	}
	assert_eq_deep(result, expected)


func test_use_previous_line_as_label():
	var result = parse("""
spk: this line will be the label $some_id&some_suffix #some_tag
	* life
		player: I want to talk about life!
		npc: Well! That's too complicated...

spk: second try
	* life
		npc: Well! That's too complicated...
""" )
	var expected = {
		"type":  NodeFactory.NODE_TYPES.DOCUMENT,
		"content":  [
			{
				"type": NodeFactory.NODE_TYPES.OPTIONS,
				"speaker": 'spk',
				"id": 'some_id',
				"tags": ['some_tag'],
				"id_suffixes": ["some_suffix"],
				"name": 'this line will be the label',
				"content": [
					{
						"type": NodeFactory.NODE_TYPES.OPTION,
						"name": 'life',
						"mode": 'once', "id": "", "speaker": "", "tags": [],
						"id_suffixes": [],
						"content":  [
							{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'I want to talk about life!', "speaker": 'player', "id": "", "tags": [], "id_suffixes": [], },
							{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'Well! That\'s too complicated...', "speaker": 'npc', "id": "", "tags": [], "id_suffixes": [], },
						],
					},
				],
			},
			{
				"type": NodeFactory.NODE_TYPES.OPTIONS,
				"speaker": 'spk',
				"name": 'second try',
				"id": "",
				"tags": [],
				"id_suffixes": [],
				"content": [
					{
						"type": NodeFactory.NODE_TYPES.OPTION,
						"name": 'life',
						"mode": 'once', "id": "", "speaker": "", "tags": [],
						"id_suffixes": [],
						"content": [{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'Well! That\'s too complicated...', "speaker": 'npc', "id": "", "tags": [], "id_suffixes": [], },],
					},
				],
			},
		],
		"blocks": [],
	}
	assert_eq_deep(result, expected)

func test_use_previous_line_in_quotes_as_label():
	var result = parse("""
\"spk: this line will be the label $some_id #some_tag\"
	* life
		player: I want to talk about life!


\"spk: this line will be the label $some_id #some_tag\"
	* universe
		player: I want to talk about the universe!
""" )
	var expected = {
		"type":  NodeFactory.NODE_TYPES.DOCUMENT,
		"content": [
			{
				"type": NodeFactory.NODE_TYPES.OPTIONS,
				"speaker": "",
				"id": "",
				"tags": [],
				"id_suffixes": [],
				"name": 'spk: this line will be the label $some_id #some_tag',
				"content": [
					{
						"type": NodeFactory.NODE_TYPES.OPTION,
						"name": 'life',
						"mode": 'once', "id": "", "tags": [], "speaker": "",
						"id_suffixes": [],
						"content": [{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'I want to talk about life!', "speaker": 'player', "id": "", "tags": [], "id_suffixes": [], }],
					},
				],
			},
			{
				"type": NodeFactory.NODE_TYPES.OPTIONS,
				"name": 'spk: this line will be the label $some_id #some_tag',
				"tags": [],
				"id_suffixes": [],
				"speaker": "",
				"id": "",
				"content": [
					{
						"type": NodeFactory.NODE_TYPES.OPTION,
						"name": 'universe',
						"mode": 'once', "id": "", "speaker": "", "tags": [],
						"id_suffixes": [],
						"content":[{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'I want to talk about the universe!', "speaker": 'player', "id": "", "tags": [], "id_suffixes": [], }],
					},
				],
			},
		],
		"blocks": [],
	}
	assert_eq_deep(result, expected)


func test_ensures_options_ending_worked():
	var result = parse("""
*= yes
*= no

{ some_check } maybe
""" )
	var expected = {
		"type":  NodeFactory.NODE_TYPES.DOCUMENT,
		"content":  [
			{
				"type": NodeFactory.NODE_TYPES.OPTIONS,
				"name": "",
				"speaker": "",
				"id": "",
				"tags": [],
				"id_suffixes": [],
				"content": [
					{
						"type": NodeFactory.NODE_TYPES.OPTION,
						"name": 'yes',
						"mode": 'once',
						"id": "", "speaker": "", "tags": [],
						"id_suffixes": [],
						"content": [{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'yes', "id": "", "speaker": "", "tags": [], "id_suffixes": [], }],
					},
					{
						"type": NodeFactory.NODE_TYPES.OPTION,
						"name": 'no',
						"mode": 'once',
						"id": "", "speaker": "", "tags": [],
						"id_suffixes": [],
						"content": [{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'no', "id": "", "speaker": "", "tags": [], "id_suffixes": [], }],
					},
				],
			},
			{
				"type": NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
				"conditions": { "type": NodeFactory.NODE_TYPES.VARIABLE, "name": "some_check" },
				"content": [{ "type": NodeFactory.NODE_TYPES.LINE, "value": "maybe", "id": "", "speaker": "", "tags": [], "id_suffixes": [], }]
			},
		],
		"blocks": [],
	}
	assert_eq_deep(result, expected)


func test_ensures_option_item_ending_worked():
	var result = parse("""
*= yes { set yes = true }
* no
	no
""" )
	var expected = {
		"type":  NodeFactory.NODE_TYPES.DOCUMENT,
		"content": [
			{
				"type": NodeFactory.NODE_TYPES.OPTIONS,
				"name": "",
				"speaker": "",
				"id": "",
				"tags": [],
				"id_suffixes": [],
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
							"type": NodeFactory.NODE_TYPES.ASSIGNMENTS,
							"assignments": [
								{
									"type": NodeFactory.NODE_TYPES.ASSIGNMENT,
									"variable": { "type": NodeFactory.NODE_TYPES.VARIABLE, "name": 'yes', },
									"operation": "ASSIGN",
									"value": { "type": NodeFactory.NODE_TYPES.BOOLEAN_LITERAL, "value": true, },
								},
							],
						}],
						"content": [{
							"type": NodeFactory.NODE_TYPES.OPTION,
							"name": 'yes',
							"mode": 'once', "id": "", "speaker": "", "tags": [], "id_suffixes": [],
							"content": [{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'yes', "id": "", "speaker": "", "tags": [], "id_suffixes": [], }],
						}],
					},
					{
						"type": NodeFactory.NODE_TYPES.OPTION,
						"name": 'no',
						"mode": 'once', "id": "", "speaker": "", "tags": [], "id_suffixes": [],
						"content": [{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'no' , "id": "", "speaker": "", "tags": [], "id_suffixes": [], }],
					},
				],
			},
		],
		"blocks": [],
	}
	assert_eq_deep(result, expected)


func test_options_with_blocks_both_sides():
	var result = parse("""
*= { what } yes { set yes = true }
* {set no = true} no { when something }
	no
""" )
	var expected = {
		"type":  NodeFactory.NODE_TYPES.DOCUMENT,
		"content":  [
			{
				"type": NodeFactory.NODE_TYPES.OPTIONS,
				"name": "",
				"speaker": "",
				"id": "",
				"tags": [],
				"id_suffixes": [],
				"content": [
					{
					"type": NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
					"conditions": { "type": NodeFactory.NODE_TYPES.VARIABLE, "name": "what" },
					"content": [{
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
									"variable": { "type": NodeFactory.NODE_TYPES.VARIABLE, "name": 'yes', },
									"operation": "ASSIGN",
									"value": { "type": NodeFactory.NODE_TYPES.BOOLEAN_LITERAL, "value": true, },
								},
							],
						}],
						"content": [{
							"type": NodeFactory.NODE_TYPES.OPTION,
							"name": 'yes',
							"mode": 'once', "id": "", "speaker": "", "tags": [],
							"id_suffixes": [],
							"content": [{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'yes', "id": "", "speaker": "", "tags": [], "id_suffixes": [], }],
						}],
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
							"type": NodeFactory.NODE_TYPES.ASSIGNMENTS,
							"assignments": [
								{
									"type": NodeFactory.NODE_TYPES.ASSIGNMENT,
									"variable": { "type": NodeFactory.NODE_TYPES.VARIABLE, "name": 'no', },
									"operation": "ASSIGN",
									"value": { "type": NodeFactory.NODE_TYPES.BOOLEAN_LITERAL, "value": true, },
								},
							],
						}],
						"content": [{
							"type": NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
							"conditions": { "type": NodeFactory.NODE_TYPES.VARIABLE, "name": "something" },
							"content": [{
								"type": NodeFactory.NODE_TYPES.OPTION,
								"name": 'no',
								"mode": 'once', "id": "", "speaker": "", "tags": [],
								"id_suffixes": [],
								"content": [{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'no', "id": "", "speaker": "", "tags": [], "id_suffixes": [], }],
							}],
						}],
					},
				],
			},
		],
		"blocks": [],
	}
	assert_eq_deep(result, expected)


func test_options_with_multiple_blocks_on_same_side():
	var result = parse("""
*= yes { when what } { set yes = true }
*= no {set no = true} { when something }
*= { when what } { set yes = true } yes
*= {set no = true} { when something } no
*= {set yes = true} { when yes } yes { set one_more = true }
""")
	var expected = {
		"type":  NodeFactory.NODE_TYPES.DOCUMENT,
		"content": [{
				"type": NodeFactory.NODE_TYPES.OPTIONS,
				"name": "",
				"speaker": "",
				"id": "",
				"tags": [],
				"id_suffixes": [],
				"content": [
					{
						"type": NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
						"conditions": { "type": NodeFactory.NODE_TYPES.VARIABLE, "name": "what" },
						"content": [{
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
										"variable": { "type": NodeFactory.NODE_TYPES.VARIABLE, "name": 'yes', },
										"operation": "ASSIGN",
										"value": { "type": NodeFactory.NODE_TYPES.BOOLEAN_LITERAL, "value": true, },
									},
								],
							}],
							"content": [{
								"type": NodeFactory.NODE_TYPES.OPTION,
								"name": 'yes',
								"mode":  'once', "id": "", "speaker": "", "tags": [],
								"id_suffixes": [],
								"content": [{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'yes', "id": "", "speaker": "", "tags": [], "id_suffixes": [], }],
							}],
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
							"type": NodeFactory.NODE_TYPES.ASSIGNMENTS,
							"assignments": [
								{
									"type": NodeFactory.NODE_TYPES.ASSIGNMENT,
									"variable": { "type": NodeFactory.NODE_TYPES.VARIABLE, "name": 'no', },
									"operation": "ASSIGN",
									"value": { "type": NodeFactory.NODE_TYPES.BOOLEAN_LITERAL, "value": true, },
								},
							],
						}],
						"content": [{
							"type": NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
							"conditions": { "type": NodeFactory.NODE_TYPES.VARIABLE, "name": "something" },
							"content": [{
								"type": NodeFactory.NODE_TYPES.OPTION,
								"name": 'no',
								"mode":  'once', "id": "", "speaker": "", "tags": [],
								"id_suffixes": [],
								"content": [{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'no', "id": "", "speaker": "", "tags": [], "id_suffixes": [], }],
							}],
						}],
					},

					{
						"type": NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
						"conditions": { "type": NodeFactory.NODE_TYPES.VARIABLE, "name": "what" },
						"content": [{
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
										"variable": { "type": NodeFactory.NODE_TYPES.VARIABLE, "name": 'yes', },
										"operation": "ASSIGN",
										"value": { "type": NodeFactory.NODE_TYPES.BOOLEAN_LITERAL, "value": true, },
									},
								],
							}],
							"content": [{
								"type": NodeFactory.NODE_TYPES.OPTION,
								"name": 'yes',
								"mode":  'once', "id": "", "speaker": "", "tags": [],
								"id_suffixes": [],
								"content":  [{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'yes', "id": "", "speaker": "", "tags": [], "id_suffixes": [], }],
							}],
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
							"type": NodeFactory.NODE_TYPES.ASSIGNMENTS,
							"assignments": [
								{
									"type": NodeFactory.NODE_TYPES.ASSIGNMENT,
									"variable": { "type": NodeFactory.NODE_TYPES.VARIABLE, "name": 'no', },
									"operation": "ASSIGN",
									"value": { "type": NodeFactory.NODE_TYPES.BOOLEAN_LITERAL, "value": true, },
								},
							],
						}],
						"content": [{
							"type": NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
							"conditions": { "type": NodeFactory.NODE_TYPES.VARIABLE, "name": "something" },
							"content": [{
								"type": NodeFactory.NODE_TYPES.OPTION,
								"name": 'no',
								"mode":  'once', "id": "", "speaker": "", "tags": [],
								"id_suffixes": [],
								"content": [{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'no', "id": "", "speaker": "", "tags": [], "id_suffixes": [], }],
							}],
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
							"type": NodeFactory.NODE_TYPES.ASSIGNMENTS,
							"assignments": [
								{
									"type": NodeFactory.NODE_TYPES.ASSIGNMENT,
									"variable": { "type": NodeFactory.NODE_TYPES.VARIABLE, "name": 'yes', },
									"operation": "ASSIGN",
									"value": { "type":NodeFactory.NODE_TYPES.BOOLEAN_LITERAL, "value": true, },
								},
							],
						}],
						"content": [{
							"type": NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
							"conditions": { "type": NodeFactory.NODE_TYPES.VARIABLE, "name": "yes" },
							"content": [{
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
											"variable": { "type": NodeFactory.NODE_TYPES.VARIABLE, "name": 'one_more', },
											"operation": "ASSIGN",
											"value": { "type": NodeFactory.NODE_TYPES.BOOLEAN_LITERAL, "value": true, },
										},
									],
								}],
								"content":[{
									"type": NodeFactory.NODE_TYPES.OPTION,
									"name": 'yes',
									"mode":  'once', "id": "", "speaker": "", "tags": [],
									"id_suffixes": [],
									"content": [ { "type": NodeFactory.NODE_TYPES.LINE, "value": 'yes', "id": "", "speaker": "", "tags": [], "id_suffixes": [], }, ],
								}],
							}],
						}],
					},
				],
			},
		],
		"blocks": [],
	}
	assert_eq_deep(result, expected)
