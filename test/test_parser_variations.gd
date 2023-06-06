extends GutTestFunctions


func test_simple_variations():
	var result = _parse("""
(
	- yes
	- no
)
""")

	var expected = _create_doc_payload([
			_variations({
				"mode": 'sequence', 
				"content": [
					[_line({"value": 'yes'})],
					[_line({"value": 'no' })],
				]
			}),
		],
	)

	assert_eq_deep(result, expected)


func test_simple_variations_with_no_indentation():
	var result = _parse("""
(
- yes
- no
)
""")

	var expected = _create_doc_payload([
			_variations({
				"mode": 'sequence', 
				"content": [
					[_line({"value": 'yes'})],
					[_line({"value": 'no'})],
				]
			}),
		]
	)

	assert_eq_deep(result, expected)


func test_nested_variations():
	var result = _parse("""
(
	- yes
	- no
	- (
		- nested 1
	)
)
""")

	var expected = _create_doc_payload([
			_variations({
				"mode": 'sequence', 
				"content": [
					[_line({"value": 'yes'})],
					[_line({"value": 'no'})],
					[_variations({
						"mode": 'sequence', 
						"content": [[_line({"value": 'nested 1'})]]
					})],
				]
			}),
		],
	)

	assert_eq_deep(result, expected)


func test_variations_modes():
	for mode in ['shuffle', 'shuffle once', 'shuffle cycle', 'shuffle sequence', 'sequence', 'once', 'cycle']:
		_mode_test(mode)

func _mode_test(mode):
	var result = _parse("""
( %s
	- yes
	- no
)
""" % mode)

	var expected = _create_doc_payload([
			_variations({ 
				"mode": mode,
				"content": [[_line({"value": 'yes'})],[_line({"value": 'no' })],]
			}),
		],
	)

	assert_eq_deep(result, expected)


func test_variations_with_options():
	var result = _parse("""
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

	var expected = _create_doc_payload([
			_variations({ 
				"mode": 'sequence', 
				"content": [
					[
						_options({ 
							"content": [
								_option({
									"value": 'works?', 
									"mode": 'once',
									"content": [ _line({"value": 'works?'}), _line({"value": 'yes'})],
								}),
								_option({
									"value": 'yep?', 
									"mode": 'once',
									"content": [_line({"value": 'yes'})],
								})
							]
						})
					],
					[_line({"value": 'nice'})],
					[_options({
						"content": [
						_option({"value": 'works?', 
							"mode": 'once', 
							"content": [_line({"value": 'works?'}),_line({"value": 'yes'})]
						}),
						_option({ 
							"value": 'yep?', 
							"mode": 'once',
							"content": [ _line({"value": 'yes'})],
						}),
						]
					})]
			]})
		]
	)

	assert_eq_deep(result, expected)

