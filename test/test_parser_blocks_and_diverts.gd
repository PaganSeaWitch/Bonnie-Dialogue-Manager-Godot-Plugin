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
