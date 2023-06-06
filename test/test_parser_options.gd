extends GutTestFunctions


func test_parse_options():
	var result = _parse("""
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
	var expected = _create_doc_payload([
			_line({"value": 'what do you want to talk about?', "speaker": 'npc'}),
			_options({
				"content": [
					_option({
						"value": 'Life',
						"speaker": 'speaker',
						"mode": 'once',
						"content":  [
								_line({ "value": 'I want to talk about life!', "speaker": 'player'}),
								_line({"value": 'Well! That\'s too complicated...', "speaker": 'npc'}),
							],
					}),
					_option({
						"value": 'Everything else...',
						"mode": 'once',
						"content":  [
								_line({"value": 'What about everything else?', "speaker": 'player'}),
								_line({"value": 'I don\'t have time for this...', "speaker": 'npc'}),
							],
						"tags": [ 'some_tag', ]
					}),
					_option({
						"value": "one more thing",
						"mode": "once",
						"content": [_line({"value": "one", "speaker": "npc"})],
						"id": "abc",
						"id_suffixes": [ "whatever" ],
					}),
				],
			}),
		],[])
	assert_eq_deep(result, expected)


func test_parse_sticky_option():
	var result = _parse("""
npc: what do you want to talk about?
* Life
	player: I want to talk about life!
+ Everything else... #some_tag
	player: What about everything else?
""" )
	var expected = _create_doc_payload([
			_line({ "value": 'what do you want to talk about?', "speaker": 'npc'}),
			_options({
				"content": [
					_option({
						"value": 'Life',
						"mode": 'once',
						"content": [_line({"value": 'I want to talk about life!', "speaker": 'player'})]
					}),
					_option({
						"value": 'Everything else...',
						"mode": 'sticky',
						"content":  [_line({"value": 'What about everything else?', "speaker": 'player' })],
						"tags": ['some_tag']
					}),
				],
			}),
		],[])
	assert_eq_deep(result, expected)


func test_parse_fallback_option():
	var result = _parse("""
npc: what do you want to talk about?
* Life
	player: I want to talk about life!
> Everything else... #some_tag
	player: What about everything else?
""" )
	var expected = _create_doc_payload([
			_line({ "value": 'what do you want to talk about?', "speaker": 'npc'}),
			_options({
				"content": [
					_option({
						"value": 'Life',
						"mode": 'once',
						"content":  [_line({ "value": 'I want to talk about life!', "speaker": 'player'})],
					}),
					_option({
						"value": 'Everything else...',
						"mode": 'fallback',
						"content": [_line({"value": 'What about everything else?', "speaker": 'player'})],
						"tags": [ 'some_tag', ]
					}),
				],
			}),
		], [])
	assert_eq_deep(result, expected)



func test_define_label_to_display_as_content():
	var result = _parse("""
npc: what do you want to talk about?
*= Life
	player: I want to talk about life!
	npc: Well! That's too complicated...
*= Everything else... #some_tag
	player: What about everything else?
	npc: I don't have time for this...
""" )
	var expected = _create_doc_payload([
			_line({ "value": 'what do you want to talk about?', "speaker": 'npc'}),
			_options({
				"content": [
					_option({
						"value": 'Life',
						"mode": 'once',
						"content":  [
							_line({ "value": 'Life' }),
							_line({ "value": 'I want to talk about life!', "speaker": 'player' }),
							_line({ "value": 'Well! That\'s too complicated...', "speaker": 'npc'}),
						],
					}),
					_option({
						"value": 'Everything else...',
						"mode": 'once', 
						"content":  [
							_line({ "value": 'Everything else...', "tags": ['some_tag']}),
							_line({ "value": 'What about everything else?', "speaker": 'player'}),
							_line({ "value": 'I don\'t have time for this...', "speaker": 'npc'}),
						],
						"tags": ['some_tag'],
					}),
				],
			}),
		],[])
	assert_eq_deep(result, expected)

func test_use_first_line_as_label():
	var result = _parse("""
*
	life
	player: I want to talk about life!
	npc: Well! That's too complicated...
*
	the universe #tag $id&suffix
""" )
	var expected = _create_doc_payload([
			_options({
				"content": [
					_option({
						"value": 'life',
						"mode": 'once', 
						"content":[
							_line({"value": 'life'}),
							_line({ "value": 'I want to talk about life!', "speaker": 'player'}),
							_line({ "value": 'Well! That\'s too complicated...', "speaker": 'npc'}),
						],
					}),
					_option({
						"value": 'the universe',
						"mode": 'once', 
						"id": "id", 
						"tags": ["tag"],
						"id_suffixes": ["suffix"],
						"content": [_line({"value": "the universe", "id": "id", "tags": ["tag"], "id_suffixes": ["suffix"]})],
					}),
				],
			}),
		],[])
	assert_eq_deep(result, expected)


func test_use_previous_line_as_label():
	var result = _parse("""
spk: this line will be the label $some_id&some_suffix #some_tag
	* life
		player: I want to talk about life!
		npc: Well! That's too complicated...

spk: second try
	* life
		npc: Well! That's too complicated...
""" )
	var expected = _create_doc_payload([
			_options({
				"speaker": 'spk',
				"id": 'some_id',
				"tags": ['some_tag'],
				"id_suffixes": ["some_suffix"],
				"value": 'this line will be the label',
				"content": [
					_option({
						"value": 'life',
						"mode": 'once', 
						"content":  [
							_line({ "value": 'I want to talk about life!', "speaker": 'player'}),
							_line({"value": 'Well! That\'s too complicated...', "speaker": 'npc'}),
						],
					}),
				],
			}),
			_options({
				"speaker": 'spk',
				"value": 'second try',
				"content": [
					_option({
						"value": 'life',
						"mode": 'once',
						"content": [_line({"value": 'Well! That\'s too complicated...', "speaker": 'npc'})],
					}),
				],
			}),
		],[])
	assert_eq_deep(result, expected)

func test_use_previous_line_in_quotes_as_label():
	var result = _parse("""
\"spk: this line will be the label $some_id #some_tag\"
	* life
		player: I want to talk about life!


\"spk: this line will be the label $some_id #some_tag\"
	* universe
		player: I want to talk about the universe!
""" )
	var expected = _create_doc_payload([
			_options({
				"value": 'spk: this line will be the label $some_id #some_tag',
				"content": [
					_option({
						"value": 'life',
						"mode": 'once',
						"content": [_line({"value": 'I want to talk about life!', "speaker": 'player'})],
					}),
				],
			}),
			_options({
				"value": 'spk: this line will be the label $some_id #some_tag',
				"content": [
					_option({
						"value": 'universe',
						"mode": 'once', 
						"content":[_line({ "value": 'I want to talk about the universe!', "speaker": 'player'})],
					}),
				],
			}),
		],[])
	assert_eq_deep(result, expected)


func test_ensures_options_ending_worked():
	var result = _parse("""
*= yes
*= no

{ some_check } maybe
""" )
	var expected = _create_doc_payload([
			_options({
				"content": [
					_option({
						"value": 'yes',
						"mode": 'once',
						"content": [_line({ "value": 'yes'})],
					}),
					_option({
						"value": 'no',
						"mode": 'once',
						"content": [_line({"value": 'no'})],
					}),
				],
			}),
			_conditional_content({
				"conditions": _variable("some_check"),
				"content": [_line({"value": "maybe"})]
			}),
		],[])
	assert_eq_deep(result, expected)


func test_ensures_option_item_ending_worked():
	var result = _parse("""
*= yes { set yes = true }
* no
	no
""" )
	var expected = _create_doc_payload([
			_options({
				"type": NodeFactory.NODE_TYPES.OPTIONS,
				"content": [
					_action_content({
						"actions": [
							_assignments([
									_assignment({
										"variable": _variable('yes'),
										"operation": "ASSIGN",
										"value": _bool(true),
									}),
								]
							)],
						"content": [
							_option({
								"value": 'yes',
								"mode": 'once',
								"content": [_line({"value": 'yes'})],
							})],
					}),
					_option({
						"value": 'no',
						"mode": 'once',
						"content": [_line({"value": 'no'})],
					}),
				],
			}),
		],[])
	assert_eq_deep(result, expected)


func test_options_with_blocks_both_sides():
	var result = _parse("""
*= { what } yes { set yes = true }
* {set no = true} no { when something }
	no
""" )
	var expected = _create_doc_payload([
			_options({
				"content": [
					_conditional_content({
					"conditions": _variable("what"),
					"content": [
						_action_content({
							"actions": [
								_assignments([
									_assignment({
										"variable": _variable('yes'),
										"operation": "ASSIGN",
										"value": _bool(true),
									}),
								]),
							],
							"content": [
								_option({
									"value": 'yes',
									"mode": 'once',
									"content": [_line({"value": 'yes'})],
								})
							],
						})
					],
				}),
					_action_content({
						"actions": [
							_assignments([
								_assignment({
									"variable": _variable('no'),
									"operation": "ASSIGN",
									"value": _bool(true),
								}),
							]),
						],
						"content": [
							_conditional_content({
								"conditions": _variable("something"),
								"content": [_option({
									"value": 'no',
									"mode": 'once',
									"content": [_line({"value": 'no'})],
								})],
							})
						],
					}),
				],
			}),
		],[])
	assert_eq_deep(result, expected)


func test_options_with_multiple_blocks_on_same_side():
	var result = _parse("""
*= yes { when what } { set yes = true }
*= no {set no = true} { when something }
*= { when what } { set yes = true } yes
*= {set no = true} { when something } no
*= {set yes = true} { when yes } yes { set one_more = true }
""")
	var expected = _create_doc_payload([
		_options({
			"content": [
				_conditional_content({
					"conditions": _variable("what"),
					"content": [
						_action_content({
							"actions": [
								_assignments([
									_assignment({
										"variable": _variable('yes'),
										"operation": "ASSIGN",
										"value": _bool(true),
									}),
								]),
							],
							"content": [
								_option({
									"value": 'yes',
									"mode":  'once', 
									"content": [_line({"value": 'yes'})],
								})
							],
						})
					],
				}),

				_action_content({
					"actions": [
						_assignments([
							_assignment({
								"variable": _variable('no'),
								"operation": "ASSIGN",
								"value": _bool(true),
							})
						]),
					],
					"content": [
						_conditional_content({
							"conditions": _variable("something"),
							"content": [
								_option({
									"value": 'no',
									"mode":  'once',
									"content": [_line({"value": 'no'})],
								})
							],
						})
					],
				}),

				_conditional_content({
					"conditions": _variable("what"),
					"content": [
						_action_content({
							"actions": [
								_assignments([
									_assignment({
										"variable": _variable('yes'),
										"operation": "ASSIGN",
										"value": _bool(true),
									}),
								]),
							],
							"content": [
								_option({
									"value": 'yes',
									"mode":  'once', 
									"content":  [_line({"value": 'yes'})],
								})
							],
						})
					],
				}),

				_action_content({
					"actions": [
						_assignments([
							_assignment({
								"variable": _variable('no'),
								"operation": "ASSIGN",
								"value": _bool(true),
							}),
						]),
					],
					"content": [
						_conditional_content({
							"conditions": _variable("something"),
							"content": [
								_option({
									"value": 'no',
									"mode":  'once', 
									"content": [_line({ "type": NodeFactory.NODE_TYPES.LINE, "value": 'no'})],
								})
							],
						})
					],
				}),
				_action_content({
					"actions": [
						_assignments([
							_assignment({
								"variable": _variable('yes'),
								"operation": "ASSIGN",
								"value": _bool(true),
							}),
						]),
					],
					"content": [
						_conditional_content({
							"conditions": _variable("yes"),
							"content": [
								_action_content({
									"actions": [
										_assignments([
											_assignment({
												"variable": _variable('one_more'),
												"operation": "ASSIGN",
												"value":  _bool(true)
											}),
										]),
									],
									"content":[
										_option({
											"value": 'yes',
											"mode":  'once',
											"content": [_line({"value": 'yes'})]
										})
									],
								})
							],
						})
					],
				}),
			],
		}),
	],[])
	assert_eq_deep(result, expected)
