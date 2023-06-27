extends GutTestFunctions


func test_parse_blocks():
	var result = _parse("""
== first block
line 1
line 2

== second_block
line 3
line 4

""")
	var expected = _create_doc_payload([],
		[
			_block({
				"block_name": 'first block', 
				"content": [
					_line({ "value": 'line 1' }),
					_line({ "value": 'line 2' }),
				]
			}),
			_block({
				"block_name": 'second_block', 
				"content": [
					_line({ "value": 'line 3' }),
					_line({ "value": 'line 4' }),
				]
			}),
		]
	)
	assert_eq_deep(result, expected)


func test_parse_blocks_and_lines():
	var result = _parse("""
line outside block 1
line outside block 2

== first block
line 1
line 2

== second_block
line 3
line 4

""")
	var expected = _create_doc_payload(
		[_line({ "value": 'line outside block 1'}), _line({ "value": 'line outside block 2'}),],
		[
			_block({
				"block_name": 'first block', 
				"content": [_line({ "value": 'line 1' }),_line({ "value": 'line 2' })]
			}),
			_block({  
				"block_name": 'second_block', 
				"content": [_line({ "value": 'line 3'}), _line({ "value": 'line 4' })]
			}),
		]
	)
	assert_eq_deep(result, expected)


func test_parse_diverts():
	var result = _parse("""
-> one
-> END
<-
* thats it
	-> somewhere
	<-
* does it work this way?
	-> go
""")
	var expected = _create_doc_payload([
			_divert('one'),
			_divert('<end>'),
			_divert('<parent>'),
			_options({ 
				"content": [
					_option({
						"value": 'thats it', 
						"mode": 'once', 
						"content": [
							_divert('somewhere'),
							_divert('<parent>'),
						],
					}),
					_option({ 
						"value": 'does it work this way?', 
						"mode": 'once', 
						"content":  [_divert('go')],
					}),
			]}),
			
	])
	assert_eq_deep(result, expected)


func test_parse_empty_block():
	var result = _parse("""
== first block
""")
	var expected = _create_doc_payload([],[_block({ "block_name": 'first block'})])
	assert_eq_deep(result, expected)


func test_parse_empty_once_block():
	var result = _parse("""
=* first block
""")
	var expected = _create_doc_payload([],[_random_block({ "mode": "once", "block_name": 'first block'})])
	assert_eq_deep(result, expected)


func test_parse_empty_sticky_block():
	var result = _parse("""
=+ first block
""")
	var expected = _create_doc_payload([],[_random_block({ "mode": "sticky", "block_name": 'first block'})])
	assert_eq_deep(result, expected)


func test_parse_empty_fallback_block():
	var result = _parse("""
=> first block
""")
	var expected = _create_doc_payload([],[_random_block({ "mode": "fallback", "block_name": 'first block'})])
	assert_eq_deep(result, expected)


func test_parse_blocks_with_prereq():
	var result = _parse("""
req second_block
== first block
line 1
line 2

req {x == 5}
== second_block
line 3
line 4

""")
	var expected = _create_doc_payload([],
		[
			_block({
				"block_name": 'first block', 
				"block_requirements" : ["second_block"],
				"content": [
					_line({ "value": 'line 1' }),
					_line({ "value": 'line 2' }),
				]
			}),
			_block({
				"block_name": 'second_block', 
				"conditions": [_expression({
					"name": "LOGICAL_EQUAL",
					"elements": [
						_variable('x'),
						_number(5.0),
					],
				})],
				"content": [
					_line({ "value": 'line 3' }),
					_line({ "value": 'line 4' }),
				]
			}),
		]
	)
	assert_eq_deep(result, expected)


func test_parse_blocks_with_multi_prereq():
	var result = _parse("""
req second_block, fourth_block, file.fifth_block
req !third_block, !sixth_block, !seventh_block
== first block
line 1
line 2

req {x == 5}, {y != 7}, {z >= 9}
req {a <= 2}, {b is 3}, {c isnt 5}
== second_block
line 3
line 4

""")
	var expected = _create_doc_payload([],
		[
			_block({
				"block_name": 'first block', 
				"block_requirements" : ["second_block", "fourth_block", "file.fifth_block"],
				"block_not_requirements" : ["third_block", "sixth_block", "seventh_block"],
				"content": [
					_line({ "value": 'line 1' }),
					_line({ "value": 'line 2' }),
				]
			}),
			_block({
				"block_name": 'second_block', 
				"conditions": [
					_expression({
						"name": "LOGICAL_EQUAL",
						"elements": [
							_variable('x'),
							_number(5.0),
						],
					}),
					_expression({
						"name": "LOGICAL_NOT_EQUAL",
						"elements": [
							_variable('y'),
							_number(7.0),
						],
					}),
					_expression({
						"name": "GREATER_OR_EQUAL_THEN",
						"elements": [
							_variable('z'),
							_number(9.0),
						],
					}),
					_expression({
						"name": "LESS_OR_EQUAL_THEN",
						"elements": [
							_variable('a'),
							_number(2.0),
						],
					}),
					_expression({
						"name": "LOGICAL_EQUAL",
						"elements": [
							_variable('b'),
							_number(3.0),
						],
					}),
					_expression({
						"name": "LOGICAL_NOT_EQUAL",
						"elements": [
							_variable('c'),
							_number(5.0),
						],
					}),
				],
				"content": [
					_line({ "value": 'line 3' }),
					_line({ "value": 'line 4' }),
				]
			}),
		]
	)
	assert_eq_deep(result, expected)


func test_parse_random_blocks_with_prereq():
	var result = _parse("""
req second_block
=* first block
line 1
line 2

req {x == 5}, third block
=+ second_block
line 3
line 4

""")
	var expected = _create_doc_payload([],
		[
			_random_block({
				"mode": "once",
				"block_name": 'first block', 
				"block_requirements" : ["second_block"],
				"content": [
					_line({ "value": 'line 1' }),
					_line({ "value": 'line 2' }),
				]
			}),
			_random_block({
				"mode": "sticky",
				"block_requirements" : ["third block"],
				"block_name": 'second_block', 
				"conditions": [_expression({
					"name": "LOGICAL_EQUAL",
					"elements": [
						_variable('x'),
						_number(5.0),
					],
				})],
				"content": [
					_line({ "value": 'line 3' }),
					_line({ "value": 'line 4' }),
				]
			}),
		]
	)
	assert_eq_deep(result, expected)
