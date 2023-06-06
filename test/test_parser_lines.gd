extends GutTestFunctions


func test_parse_single_line():
	var result = _parse('jules: say what one more time! $first #yelling #mad')
	var expected = _create_doc_payload([
		_line({"value": 'say what one more time!',"id": 'first',"speaker": 'jules',"tags": ['yelling','mad']})
	])
	assert_eq_deep(result, expected)


func test_parse_lines():
		var result = _parse("""jules: say what one more time! $first #yelling #mad
just text
just id $another&var1&var2
just tags #tag
speaker: just speaker
id last #tag #another_tag $some_id
""")

		var expected = _create_doc_payload([
			_line({ "value": 'say what one more time!', "id": 'first', "speaker": 'jules', "tags": [ 'yelling', 'mad' ]}),
			_line({ "value": 'just text'}),
			_line({"value": 'just id', "id": 'another',"id_suffixes": [ "var1", "var2" ] }),
			_line({"value": 'just tags', "tags": [ 'tag' ]}),
			_line({ "value": 'just speaker', "speaker": 'speaker'}),
			_line({"value": 'id last',"id": 'some_id', "tags": [ 'tag', 'another_tag' ]}),
		])

		assert_eq_deep(result, expected)


func test_parse_multiline():
	var result = _parse("""
jules: say what one more time!
	 Just say it $some_id #tag
hello! $id_on_first_line #and_tags
	Just talking.
""")
	var expected = _create_doc_payload([
		_line({ "value": 'say what one more time! Just say it', "id": 'some_id', "speaker": 'jules', "tags": [ 'tag' ] }),
		_line({ "value": 'hello! Just talking.', "id": 'id_on_first_line', "tags": [ 'and_tags' ]}),
	])
	assert_eq_deep(result, expected)

func test_parse_text_in_quotes():
	var result = _parse("""
\"jules: say what one more time!
	 Just say it $some_id #tag\"
\"hello! $id_on_first_line #and_tags
Just talking.\"

\"this has $everything:\" $id_on_first_line #and_tags
""")
	var expected = _create_doc_payload([
		_line({"value": 'jules: say what one more time!\n	 Just say it $some_id #tag'}),
		_line({ "value": 'hello! $id_on_first_line #and_tags\nJust talking.'}),
		_line({ "value": 'this has $everything:', "id": 'id_on_first_line', "tags": [ 'and_tags' ]}),
	])
	assert_eq_deep(result, expected)
