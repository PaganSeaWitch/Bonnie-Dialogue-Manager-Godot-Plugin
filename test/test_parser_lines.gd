extends "res://addons/gut/test.gd"


func parse(input):
	var parser = Parser.new()
	return parser.to_JSON_object(parser.parse(input))


func test_parse_single_line():
	var result = parse('jules: say what one more time! $first #yelling #mad')
	var expected = {
		"type": NodeFactory.NODE_TYPES.DOCUMENT,
		"content": [
			{
				"type": NodeFactory.NODE_TYPES.LINE,
				"value": 'say what one more time!',
				"id": 'first',
				"speaker": 'jules',
				"tags": [
					'yelling',
					'mad'
				],
				"id_suffixes": [],
			}
		],
		"blocks": []
	}
	assert_eq_deep(result, expected)


func test_parse_lines():
		var result = parse("""jules: say what one more time! $first #yelling #mad
just text
just id $another&var1&var2
just tags #tag
speaker: just speaker
id last #tag #another_tag $some_id
""")

		var expected = {
			"type": NodeFactory.NODE_TYPES.DOCUMENT,
			"content": [
					{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'say what one more time!', "id": 'first', "speaker": 'jules', "tags": [ 'yelling', 'mad' ], "id_suffixes": [] },
					{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'just text', "speaker": "", "id": "", "tags": [], "id_suffixes": [] },
					{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'just id', "id": 'another', "speaker": "", "tags": [], "id_suffixes": [ "var1", "var2" ] },
					{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'just tags', "tags": [ 'tag' ], "speaker": "", "id": "", "id_suffixes": [] },
					{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'just speaker', "speaker": 'speaker', "id": "", "tags": [], "id_suffixes": [] },
					{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'id last', "speaker": "", "id": 'some_id', "tags": [ 'tag', 'another_tag' ], "id_suffixes": [] },],
			"blocks": []
		}

		assert_eq_deep(result, expected)


func test_parse_multiline():
	var result = parse("""
jules: say what one more time!
	 Just say it $some_id #tag
hello! $id_on_first_line #and_tags
	Just talking.
""")
	var expected = {
		"type": NodeFactory.NODE_TYPES.DOCUMENT,
		"blocks":[],
		"content": [
			{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'say what one more time! Just say it', "id": 'some_id', "speaker": 'jules', "tags": [ 'tag' ], "id_suffixes": [] },
			{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'hello! Just talking.', "id": 'id_on_first_line', "tags": [ 'and_tags' ], "speaker": "", "id_suffixes": [] },
		],
	}
	assert_eq_deep(result, expected)

func test_parse_text_in_quotes():
	var result = parse("""
\"jules: say what one more time!
	 Just say it $some_id #tag\"
\"hello! $id_on_first_line #and_tags
Just talking.\"

\"this has $everything:\" $id_on_first_line #and_tags
""")
	var expected = {
		"type": NodeFactory.NODE_TYPES.DOCUMENT,
		"content": [

				{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'jules: say what one more time!\n	 Just say it $some_id #tag', "speaker": "", "id": "", "tags": [], "id_suffixes": [] },
				{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'hello! $id_on_first_line #and_tags\nJust talking.', "speaker": "", "id": "", "tags": [], "id_suffixes": [] },
				{ "type": NodeFactory.NODE_TYPES.LINE, "value": 'this has $everything:', "id": 'id_on_first_line', "tags": [ 'and_tags' ], "speaker": "", "id_suffixes": [] },
			
		],
		"blocks": []
	}
	assert_eq_deep(result, expected)
