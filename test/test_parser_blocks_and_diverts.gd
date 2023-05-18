extends "res://addons/gut/test.gd"


func parse(input):
	var parser = Parser.new()
	return parser.to_JSON_object(parser.parse(input))

func test_parse_blocks():
	var result = parse("""
== first block
line 1
line 2

== second_block
line 3
line 4

""")
	var expected = {
		"type": NodeFactory.NODE_TYPES.DOCUMENT,
		"content": [],
		"blocks": [
			{ "type": NodeFactory.NODE_TYPES.BLOCK, "block_name": 'first block', 
				"content": [
					{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'line 1', "speaker": "", "id": "", "tags": [], "id_suffixes": [], },
					{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'line 2', "speaker": "", "id": "", "tags": [], "id_suffixes": [], },
				]
			},
			{ "type": NodeFactory.NODE_TYPES.BLOCK, "block_name": 'second_block', 
				"content": [
					{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'line 3', "speaker": "", "id": "", "tags": [], "id_suffixes": [], },
					{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'line 4', "speaker": "", "id": "", "tags": [], "id_suffixes": [], },
				]
			},
		]
	}
	assert_eq_deep(result, expected)

func test_parse_blocks_and_lines():
	var result = parse("""
line outside block 1
line outside block 2

== first block
line 1
line 2

== second_block
line 3
line 4

""")
	var expected = {
		"type": NodeFactory.NODE_TYPES.DOCUMENT,
		
		"content": [
			{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'line outside block 1', "speaker": "", "id": "", "tags": [], "id_suffixes": [], },
			{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'line outside block 2', "speaker": "", "id": "", "tags": [], "id_suffixes": [], },
		]
		,
		"blocks": [
			{ "type": NodeFactory.NODE_TYPES.BLOCK, "block_name": 'first block', 
				"content": [
					{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'line 1', "speaker": "", "id": "", "tags": [], "id_suffixes": [], },
					{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'line 2', "speaker": "", "id": "", "tags": [], "id_suffixes": [], },
				]
			},
			{ "type": NodeFactory.NODE_TYPES.BLOCK, "block_name": 'second_block', 
				
				"content": [
					{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'line 3', "speaker": "", "id": "", "tags": [], "id_suffixes": [], },
					{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'line 4', "speaker": "", "id": "", "tags": [], "id_suffixes": [], },
				]
			},
		]
	}
	assert_eq_deep(result, expected)


func test_parse_diverts():
	var result = parse("""
-> one
-> END
<-
* thats it
	-> somewhere
	<-
* does it work this way?
	-> go
""")
	var expected = {
		"type": NodeFactory.NODE_TYPES.DOCUMENT,
		"content": [
				{ "type": NodeFactory.NODE_TYPES.DIVERT, "target": 'one' },
				{ "type": NodeFactory.NODE_TYPES.DIVERT, "target": '<end>' },
				{ "type": NodeFactory.NODE_TYPES.DIVERT, "target": '<parent>' },
				{ "type": NodeFactory.NODE_TYPES.OPTIONS, "speaker": "", "id": "", "tags": [], "value": "", "id_suffixes": [], "content": [
						{ "type": NodeFactory.NODE_TYPES.OPTION, "value": 'thats it', "mode": 'once', "speaker": "", "id": "", "tags": [], "id_suffixes": [], 
								"content": [
									{ "type": NodeFactory.NODE_TYPES.DIVERT, "target": 'somewhere' },
									{ "type": NodeFactory.NODE_TYPES.DIVERT, "target": '<parent>' },
								],
						},
						{ "type": NodeFactory.NODE_TYPES.OPTION, "value": 'does it work this way?', "mode": 'once', "speaker": "", "id": "", "tags": [], "id_suffixes": [], "content":  [
									{ "type": NodeFactory.NODE_TYPES.DIVERT, "target": 'go' },
								],
						},
				]},
			
		],
		"blocks": []
	}
	assert_eq_deep(result, expected)


func test_parse_empty_block():
	var result = parse("""
== first block
""")
	var expected = {
		"type": NodeFactory.NODE_TYPES.DOCUMENT,
		"content": [],
		"blocks": [
			{ "type": NodeFactory.NODE_TYPES.BLOCK, "block_name": 'first block',"content": [] },
		]
	}
	assert_eq_deep(result, expected)
