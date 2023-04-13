extends "res://addons/gut/test.gd"

const Parser = preload("res://addons/clyde/parser/Parser.gd")

func parse(input):
	var parser = Parser.new()
	return parser.to_JSON_object(parser.parse(input))


func test_simple_variations():
	var result = parse("""
(
	- yes
	- no
)
""")

	var expected = {
		"type": NodeFactory.NODE_TYPES.DOCUMENT,
		"blocks": [],
		"content": [
			{ "type": NodeFactory.NODE_TYPES.VARIATIONS, "mode": 'sequence', "content": [
					[{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'yes', "id": "", "speaker": "", "tags": [], "id_suffixes": [], }],
					[{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'no', "id": "", "speaker": "", "tags": [], "id_suffixes": [], }],
			]},
		],
	}

	assert_eq_deep(result, expected)


func test_simple_variations_with_no_indentation():
	var result = parse("""
(
- yes
- no
)
""")

	var expected = {
		"type": NodeFactory.NODE_TYPES.DOCUMENT,
		"blocks": [],
		"content": [
			{ "type": NodeFactory.NODE_TYPES.VARIATIONS, "mode": 'sequence', "content": [
					[{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'yes', "id": "", "speaker": "", "tags": [], "id_suffixes": [], }],
					[{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'no', "id": "", "speaker": "", "tags": [], "id_suffixes": [], }],
			],},
		],
	}

	assert_eq_deep(result, expected)


func test_nested_variations():
	var result = parse("""
(
	- yes
	- no
	- (
		- nested 1
	)
)
""")

	var expected = {
		"type": NodeFactory.NODE_TYPES.DOCUMENT,
		"blocks": [],
		"content":  [
			{ "type": NodeFactory.NODE_TYPES.VARIATIONS, "mode": 'sequence', "content": [
				[{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'yes', "id": "", "speaker": "", "tags": [], "id_suffixes": [], }],
				[{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'no', "id": "", "speaker": "", "tags": [], "id_suffixes": [], }],
				[{ "type": NodeFactory.NODE_TYPES.VARIATIONS, "mode": 'sequence', 
					"content": 
						[[{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'nested 1', "id": "", "speaker": "", "tags": [], "id_suffixes": [], }]]}],
			]},
		],
	}

	assert_eq_deep(result, expected)


func test_variations_modes():
	for mode in ['shuffle', 'shuffle once', 'shuffle cycle', 'shuffle sequence', 'sequence', 'once', 'cycle']:
		_mode_test(mode)

func _mode_test(mode):
	var result = parse("""
( %s
	- yes
	- no
)
""" % mode)

	var expected = {
		"type": NodeFactory.NODE_TYPES.DOCUMENT,
		"blocks": [],
		"content":  [
			{ "type": NodeFactory.NODE_TYPES.VARIATIONS, "mode": mode, "content": [
				[{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'yes', "id": "", "speaker": "", "tags": [], "id_suffixes": [], }],
				[{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'no', "id": "", "speaker": "", "tags": [], "id_suffixes": [], }],
			]},
		],
	}

	assert_eq_deep(result, expected)


func test_variations_with_options():
	var result = parse("""
(
- *= works?
		yes
	* yep?
		yes
- nice
-
	*= works?
		yes
	* yep?
		yes
)
""")

	var expected = {
		"type": NodeFactory.NODE_TYPES.DOCUMENT,
		"blocks": [],
		"content": [
			{ "type": NodeFactory.NODE_TYPES.VARIATIONS, "mode": 'sequence', "content": [
				[{ "type": NodeFactory.NODE_TYPES.OPTIONS, "name": "", "id": "", "speaker": "", "tags": [], "id_suffixes": [], "content": [
					{ "type": NodeFactory.NODE_TYPES.OPTION, "name": 'works?', "mode": 'once', "id": "", "speaker": "", "tags": [], "id_suffixes": [], "content": 
						[ 
							{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'works?', "id": "", "speaker": "", "tags": [], "id_suffixes": []}, 
							{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'yes', "id": "", "speaker": "", "tags": [], "id_suffixes": []}
						],
					},
					{ "type": NodeFactory.NODE_TYPES.OPTION, "name": 'yep?', "mode": 'once', "id": "", "speaker": "", "tags": [], "id_suffixes": [], "content": [
						{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'yes', "id": "", "speaker": "", "tags": [], "id_suffixes": []}],
					}
				]}],
				[{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'nice', "id": "", "speaker": "", "tags": [], "id_suffixes": []}],
				[{ "type": NodeFactory.NODE_TYPES.OPTIONS, "name": "", "id": "", "speaker": "", "tags": [], "id_suffixes": [], "content": [
					{ "type": NodeFactory.NODE_TYPES.OPTION, "name": 'works?', "mode": 'once', "id": "", "speaker": "", "tags": [], "id_suffixes": [], "content": [
						{"type": NodeFactory.NODE_TYPES.LINE, "value": 'works?', "id": "", "speaker": "", "tags": [], "id_suffixes": []},
						{"type": NodeFactory.NODE_TYPES.LINE, "value": 'yes', "id": "", "speaker": "", "tags": [], "id_suffixes": []},
					]},
					{ "type": NodeFactory.NODE_TYPES.OPTION, "name": 'yep?', "mode": 'once', "id": "", "speaker": "", "tags": [], "id_suffixes": [], "content": 
						[ { "type": NodeFactory.NODE_TYPES.LINE, "value": 'yes', "id": "", "speaker": "", "tags": [], "id_suffixes": []}],
					},
				]}]
			]}
		]
	}

	assert_eq_deep(result, expected)
