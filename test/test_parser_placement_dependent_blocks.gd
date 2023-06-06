extends GutTestFunctions


func test_parser_placement_depentdent_slice_text():
	var result = _parse('cheese [{ set x = 5 }] cakes')
	
	var expected = _create_doc_payload([_create_content_payload([
			_line_part( 
				_line({"value": "cheese " }), 
				false
			),
			_line_part( 
				_action_content({
					"actions": [
						_assignments([
							_assignment({
								"variable": _variable("x"),
								"operation": 'ASSIGN',
								"value": _number(5.0),
							}),
						]),
					],
					"content": [_line({ "value": ' cakes'})],
				}),
				true,
			),
		])
	])
	assert_eq_deep(result, expected)


func test_parser_placement_depentdent_conditional_text():
	var result = _parse('cheese [{ when chicken }] cakes')
	
	var expected = _create_doc_payload([_create_content_payload([
			_line_part(
				_line({ "value": "cheese " }),
				false
			),
			_line_part( 
				_conditional_content({
					"conditions": _variable("chicken"),
					"content": [_line({ "value": ' cakes' })],
				}),
				true,
			),
		])
	])
	assert_eq_deep(result, expected)


func test_parser_multiple_placement_depentdent_conditional_text():
	var result = _parse('cheese [{ when chicken }] cakes [{ when sticks }] suck')
	var expected = _create_doc_payload([_create_content_payload([
		_line_part(
			_line({ "value": "cheese " }), 
			false
		),
		_line_part(
			_conditional_content({
				"conditions": _variable("chicken"),
				"content": [_line({"value": ' cakes '})],
			}),
			false
		),
		_line_part(
			_conditional_content({
				"conditions": _variable("sticks"),
				"content": [_line({"value": ' suck'})],
			}),
			true
		),
		])
	])
	assert_eq_deep(result, expected)


func test_parser_multiple_placement_depentdent_conditional_and_action_text():
	var result = _parse('cheese [{ when chicken }] cakes [{ when sticks }] suck [{ set x = 5 }] a lot')
	var expected = _create_doc_payload([_create_content_payload([
			_line_part(
				_line({ "value": "cheese " }),
				false
			),
			_line_part(
				_conditional_content({
					"conditions": _variable("chicken"),
					"content": [_line({"value": ' cakes '})],
				}),
				false
			),
			_line_part(
				_conditional_content({
					"conditions": _variable("sticks"),
					"content": [_line({  "value": ' suck '})],
				}),
				false
			),
			_line_part(
				_action_content({
					"actions": [
						_assignments([
							_assignment({
								"variable": _variable("x"),
								"operation": 'ASSIGN',
								"value": _number(5.0),
							}),
						]),
					],
					"content": [_line({ "value": ' a lot'})],
					}),
				true
			),
		])
	])
	assert_eq_deep(result, expected)


func test_not_operator():
	var result = _parse('cheese [{ not chicken }] cakes')

	var expected = _create_doc_payload([_create_content_payload([
		_line_part( 
			_line({ "value": "cheese " }),
			false
		),
		_line_part(
			_conditional_content({
				"conditions": _expression({
					"name": "NOT",
					"elements": [_variable("chicken")]
				}),
				"content": [_line({ "value": ' cakes' })],
			}),
			true
		),
		])
	])

	assert_eq_deep(result, expected)


func test_and_operator():
	var result = _parse('cheese [{chicken && checken }] cakes')

	var expected = _create_doc_payload([_create_content_payload([
		_line_part( 
			_line({"value": "cheese " }),
			false
		),
		_line_part(
			_conditional_content({
				"conditions": _expression({
					"name": 'AND',
					"elements": [
						_variable('chicken'),
						_variable('checken'),
					],
				}),
				"content": [_line({ "value": ' cakes'})],
			}),
			true
		),
		])
	])

	assert_eq_deep(result, expected)


func test_empty_block():
	var result = _parse("cheese [{}] cakes")
	
	var expected = _create_doc_payload([_create_content_payload([
		_line_part(
			_line({"value": "cheese " }),
			false
		),
		_line_part(
			_conditional_content({
				"conditions": {},
				"content": [_line({ "value": ' cakes'})],
			}),
			true
		),
		])
	])
	assert_eq_deep(result, expected)


func test_independent_before_dependent_logic():
	var result = _parse('{ when chicken } cheese [{ when chicken }] cakes')
	
	var expected = _create_doc_payload([
		_conditional_content({
			"conditions": _variable("chicken"),
			"content": [_create_content_payload([
				_line_part(
					_line({"value": "cheese " }),
					false
				),
				_line_part(
					_conditional_content({
						"conditions": _variable("chicken"),
						"content": [_line({"value": ' cakes'})],
					}),
					true
				),
			])]
		})
	])
	assert_eq_deep(result, expected)


func test_independent_after_dependent_logic():
	var result = _parse('cheese [{ when chicken }] cakes { when chicken }')
	
	var expected = _create_doc_payload([
		_conditional_content({
			"conditions": _variable("chicken"),
			"content": [_create_content_payload([
				_line_part( 
					_line({"value": "cheese " }), 
					false
				),
				_line_part(
					_conditional_content({
						"conditions": _variable("chicken"),
						"content": [_line({"value": ' cakes'})],
					}),
					true
				),
			])]
		})
	])
	assert_eq_deep(result, expected)


func test_independent_inbetween_dependent_logic():
	var result = _parse('cheese [{ when chicken }] { when chicken } cakes')
	
	var expected = _create_doc_payload([
		_conditional_content({
			"conditions": _variable("chicken"),
			"content": [_create_content_payload([
				_line_part(
					_line({ "value": "cheese "}),
					false
				),
				_line_part(
					_conditional_content({
						"conditions": _variable("chicken"),
						"content": [_line({ "value": '  cakes'})],
					}),
					true
				),
			])]
		})
	])
	assert_eq_deep(result, expected)


func test_independent_inbetween_dependent_logic_reversed():
	var result = _parse('cheese { when chicken }[{ when chicken }]  cakes')
	
	var expected = _create_doc_payload([
		_conditional_content({
			"conditions": _variable("chicken"),
			"content": [_create_content_payload([
				_line_part(
					_line({ "value": "cheese " }),
					false
				),
				_line_part(
					_conditional_content({
						"conditions": _variable("chicken"),
						"content": [_line({"value": '  cakes'})],
					}),
					true
				),
			])]
		})
	])
	assert_eq_deep(result, expected)


func test_independent_inbetween_dependent_logics():
	var result = _parse('[{ when chicken }] cheese { when chicken } [{ when chicken }]  cakes')
	
	var expected = _create_doc_payload([
		_conditional_content({
			"conditions": _variable("chicken"),
			"content": 
				[_create_content_payload([
					_line_part( 
						_conditional_content({
							"conditions": _variable("chicken"),
							"content": [_line({ "value": ' cheese  '})],
						}),
						false
					),
					_line_part(
						_conditional_content({
							"conditions": _variable("chicken"),
							"content": [_line({"value": '  cakes'})],
						}),
						true
					),
				])]
		})
	])
	assert_eq_deep(result, expected)


func test_independent_set_inbetween_dependent_logics():
	var result = _parse('[{ when chicken }] cheese { set x = 5 }[{ when chicken }]  cakes')
	
	var expected = _create_doc_payload([
		_action_content({
			"actions": [
				_assignments([
					_assignment({
						"variable": _variable("x"),
						"operation": 'ASSIGN',
						"value": _number(5.0),
					}),
				]),
			],
		"content": 
			[_create_content_payload([
				_line_part( 
					_conditional_content({
						"conditions": _variable("chicken"),
						"content": [_line({"value": ' cheese '})],
					}),
					false
				),
				_line_part(
					_conditional_content({
						"conditions": _variable("chicken"),
						"content": [_line({ "value": '  cakes'})],
					}),
					true
				),
			])]
		}),
	])
	assert_eq_deep(result, expected)
	

func test_multiple_logic_blocks_with_condition_after():
	var result = _parse("{set something = 1}[{when chicken}]{ some_var }{ trigger event }cheese")
	var expected = _create_doc_payload([_action_content({
		"actions": [_assignments([
				_assignment({
					"variable": _variable("something"),
					"operation": "ASSIGN",
					"value": _number(1.0),
				})
			]),
		],
		"content": [
			_conditional_content({
				"conditions": _variable('some_var'),
				"content": [_action_content({
					"actions": [_events([_event('event') ])],
					"content": [_create_content_payload([
						_line_part( 
							_conditional_content({
								"conditions": _variable("chicken"),
								"content": [_line({"value": 'cheese'})],
							}),
							true
						)
					])
					],
				})],
			})
		],
	})])
	assert_eq_deep(result, expected)


func test_parser_placement_depentdent_slice_conditional_text():
	var result = _parse('cheese [{ set x = 5 }][{when chicken}] cakes')
	
	var expected = _create_doc_payload([_create_content_payload([
			_line_part( 
				_line({"value": "cheese "}),
				false
			),
			_line_part(
				_action_content({
					"actions": [
						_assignments([
							_assignment({
								"variable": _variable("x"),
								"operation": 'ASSIGN',
								"value": _number(5.0),
							}),
						]),
					],
				}),
				false
			),
			_line_part(
				_conditional_content({
					"conditions": _variable("chicken"),
					"content": [_line({ "value": ' cakes'})],
				}),
				true
			)
		])
	])
	assert_eq_deep(result, expected)


func test_parser_placement_depentdent_slice_conditional_text_more():
	var result = _parse('[{when cheken}]cheese [{ set x = 5 }][{when chicken}] cakes')
	
	var expected = _create_doc_payload([_create_content_payload([
			_line_part(
				_conditional_content({
					"conditions": _variable("cheken"),
					"content": [_line({ "value": 'cheese '})],
				}),
				false
			),
			_line_part(
				_action_content({
					"actions": [
						_assignments([
							_assignment({
								"variable": _variable("x"),
								"operation": 'ASSIGN',
								"value": _number(5.0),
							}),
						]),
					],
				}),
				false
			),
			_line_part(
				_conditional_content({
					"conditions": _variable("chicken"),
					"content": [_line({"value": ' cakes'})],
				}),
				true
			)
		])
	])
	assert_eq_deep(result, expected)


func test_parser_placement_depentdent_slice_conditional_text_trigger():
	var result = _parse('[{when cheken}]cheese [{ set x = 5 }][{trigger chicken}] cakes')
	
	var expected = _create_doc_payload([_create_content_payload([
		_line_part(
			_conditional_content({
				"conditions": _variable("cheken"),
				"content": [_line({"value": 'cheese '})],
			}),
			false
		),
		_line_part(
			_action_content({
				"actions": [_assignments([
						_assignment({
							"variable": _variable("x"),
							"operation": 'ASSIGN',
							"value": _number(5.0),
						}),
					]),
				]
			}),
			false
		),
		_line_part(
			_action_content({
				"actions": [{
					"type": NodeFactory.NODE_TYPES.EVENTS,
					"events": [_event('chicken')],
				}],
				"content": [_line({"value": ' cakes'})]
			}),
			true		
		)])
	])
	assert_eq_deep(result, expected)


func test_parser_placement_depentdent_conditional_text_after():
	var result = _parse('cheese cakes[{when chicken}]')
	
	var expected = _create_doc_payload([_create_content_payload([
			_line_part(
				_line({"value": "cheese cakes" }),
				false
			),
			_line_part(
				_conditional_content({
					"conditions": _variable("chicken"),
					"content": [],
				}),
				true
			),
		])
	])
	assert_eq_deep(result, expected)


func test_standalone_assignment_with_standalone_variable():
	var result = _parse("[{ set a }]")

	var expected = _create_doc_payload([_create_content_payload([
		_line_part(
			_action_content({
				"actions": [
					_assignments([
						_assignment({
							"variable": _variable('a'),
							"operation": 'ASSIGN',
							"value": _bool(true),
						}),
					]),
				],
			}),
			true
		)])
	])
	assert_eq_deep(result, expected)

func test_divert_with_assignment():
	var result = _parse("-> go [{ set a = 2 }]")
	var expected = _create_doc_payload([
		_divert('go'),
		_create_content_payload([
			_line_part(
				_action_content({
					"actions": [
						_assignments([
							_assignment({
								"variable": _variable('a'),
								"operation": "ASSIGN",
								"value": _number(2.0),
							}),
						]),
					]
				}),
				true
			)
		])
	])

	assert_eq_deep(result, expected)


func test_condition_with_multiline_dialogue():
		var result = _parse("""[{ another_var }] This is conditional
		multiline
	""")

		var expected = _create_doc_payload([_create_content_payload([
			_line_part(
				_conditional_content({
					"conditions": _variable("another_var"),
					"content": [_line({"value": " This is conditional multiline"})]
				}),
				true
			)
		])])
		assert_eq_deep(result, expected)


func test_speaker_before_and_after_dependent():
	var result = _parse("""npc: what do you[{when chicken}] want to talk about? """)

	var expected = _create_doc_payload([_create_content_payload([
		_line_part(
			_line({"speaker": "npc","value": "what do you"}),
			false
		),
		_line_part(
			_conditional_content({
				"conditions": _variable("chicken"),
				"content": [_line({"speaker": "npc", "value": ' want to talk about?'})],
			}),
			true
		)
	])])
	assert_eq_deep(result, expected)


func test_tag_before_and_after_dependent():
	var result = _parse("""what do you[{when chicken}] want to talk about? #conspiracy""")

	var expected = _create_doc_payload([_create_content_payload([
		_line_part(_line({"value": "what do you","tags":["conspiracy"]}),false),
		_line_part(
			_conditional_content({
				"conditions": _variable("chicken"),
				"content": [_line({"tags":["conspiracy"], "value": ' want to talk about?'})],
			}),
			true
		)
	])])
	assert_eq_deep(result, expected)


func test_id_before_and_after_dependent():
	var result = _parse("""what do you [{when chicken}] want to talk about? $line_id""")

	var expected = _create_doc_payload([_create_content_payload([
		_line_part(
			_line({"value": "what do you ","id": "line_id_0"}),
			false),
		_line_part(
			_conditional_content({
				"conditions": _variable("chicken"),
				"content": [_line({"id": "line_id_1_0","value": ' want to talk about?'})],
			}),
			true
		)
	])])
	assert_eq_deep(result, expected)


func test_id_suffix_before_and_after_dependent():
	var result = _parse("""what do you [{when chicken}] want to talk about? $line_id&fren""")

	var expected = _create_doc_payload([_create_content_payload([
		_line_part(
			_line({"value": "what do you ","id": "line_id_0","id_suffixes":["fren"]}),
			false),
		_line_part(
			_conditional_content({
				"conditions": _variable("chicken"),
				"content": [_line({"id": "line_id_1_0","value": ' want to talk about?',"id_suffixes":["fren"]})],
			}),
			true
		)
	])])
	assert_eq_deep(result, expected)
	

func test_full_line_after_dependent():
	var result = _parse("""npc: what do you want to talk about?[{when chicken}] #conspiracy $line_id&fren""")

	var expected = _create_doc_payload([_create_content_payload([
		_line_part(
			_line({
				"speaker": "npc",
				"value": "what do you want to talk about?",
				"id": "line_id_0",
				"id_suffixes":["fren"],
				"tags" : ["conspiracy"]
			}),
		false),
		_line_part(
			_conditional_content({
				"conditions": _variable("chicken"),
				"content": [_line({"speaker" : "npc", "id": "line_id_1_0","id_suffixes": ["fren"],"tags" : ["conspiracy"]})],
			}),
			true
		)
	])])
	assert_eq_deep(result, expected)

func test_full_line_tag_before_after_dependent():
	var result = _parse("""npc: what do you want [{when chucken}] to talk about? #only_this [{when chicken}] #conspiracy $line_id&fren""")

	var expected = _create_doc_payload([_create_content_payload([
		_line_part(
				_line({
					"speaker": "npc",
					"value": "what do you want ",
					"id": "line_id_0",
					"id_suffixes":["fren"],
					"tags" : ["conspiracy"]
				}),
			false
		),
		_line_part(
			_conditional_content({
				"conditions": _variable("chucken"),
				"content": [_line({
					"speaker": "npc",
					"value": " to talk about?",
					"id": "line_id_1_0",
					"id_suffixes":["fren"],
					"tags" : ["only_this","conspiracy"]
				})],
			}),
			false
		),
		_line_part(
			_conditional_content({
				"conditions": _variable("chicken"),
				"content": [_line({"speaker" : "npc", "id": "line_id_2_0","id_suffixes": ["fren"],"tags" : ["conspiracy"]})]
			}),
			true
		)
	])])
	assert_eq_deep(result, expected)
