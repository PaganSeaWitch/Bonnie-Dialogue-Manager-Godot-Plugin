extends GutTestFunctions


func test_condition_single_var():
	var result = _parse("{ some_var } This is conditional")
	var expected = _create_doc_payload([
		_conditional_content({
			"conditions": _variable("some_var"),
			"content": [_line({ "value": "This is conditional"})]
		}),
	])
	assert_eq_deep(result, expected)

func test_condition_with_multiline_dialogue():
	var result = _parse("""{ another_var } This is conditional
		multiline
""")

	var expected = _create_doc_payload([
		_conditional_content({
			"conditions": _variable("another_var"),
			"content": [_line({ "value": "This is conditional multiline"})]
		})
	])
	assert_eq_deep(result, expected)


func test_not_operator():
	var result = _parse("{ not some_var } This is conditional")

	var expected = _create_doc_payload([
		_conditional_content({
			"conditions": _expression({
				"name": "NOT",
				"elements": [_variable("some_var")]
			}),
			"content": [_line({ "value": "This is conditional"})]
		})
	])
	assert_eq_deep(result, expected)


func test_and_operator():
	var result = _parse("""{ first_time && second_time } npc: what do you want to talk about? """)

	var expected = _create_doc_payload([
		_conditional_content({
			"conditions": _expression({
				"name": 'AND',
				"elements": [
					_variable('first_time'),
					_variable('second_time'),
				],
			}),
			"content": [_line({"value": 'what do you want to talk about?', "speaker": 'npc'})],
		})
	])
	assert_eq_deep(result, expected)


func test_multiple_logical_checks_and_and_or():
	var result = _parse("{ first_time and second_time or third_time } npc: what do you want to talk about?")

	var expected = _create_doc_payload([
		_conditional_content({
			"conditions": _expression({
				"name": 'OR',
				"elements": [
					_expression({
						"name": 'AND',
						"elements": [
							_variable('first_time'),
							_variable('second_time'),
						],
					}),
					_variable('third_time'),
				],
			}),
			"content": [_line({"value": 'what do you want to talk about?', "speaker": 'npc' })],
		})
	])
	assert_eq_deep(result, expected)


func test_multiple_equality_check():
	var result = _parse("{ first_time == second_time or third_time != fourth_time } equality")

	var expected = _create_doc_payload([
		_conditional_content({
			"conditions": _expression({
				"name": 'OR',
				"elements": [
					_expression({
						"name": "LOGICAL_EQUAL",
						"elements": [
							_variable('first_time'),
							_variable('second_time'),
						],
					}),
					_expression({
						"name": "LOGICAL_NOT_EQUAL",
						"elements": [
							_variable('third_time'),
							_variable('fourth_time'),
						],
					}),
				],
			}),
			"content": [_line({"value": 'equality'})],
		})
	])
	assert_eq_deep(result, expected)


func test_multiple_alias_equality_check():
	var result = _parse("{ first_time is second_time or third_time isnt fourth_time } alias equality")

	var expected = _create_doc_payload([
		_conditional_content({
			"type":  NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
			"conditions": _expression({
				"name": 'OR',
				"elements": [
					_expression({
						"name": "LOGICAL_EQUAL",
						"elements": [
							_variable('first_time'),
							_variable('second_time'),
						],
					}),
					_expression({
						"name": "LOGICAL_NOT_EQUAL",
						"elements": [
							_variable('third_time'),
							_variable('fourth_time'),
						],
					}),
				],
			}),
			"content": [ _line({"value": 'alias equality'})],
		})
	])
	assert_eq_deep(result, expected)


func test_less_or_greater():
	var result = _parse("{ first_time < second_time or third_time > fourth_time } comparison")

	var expected = _create_doc_payload([
		_conditional_content({
			"conditions": _expression({
				"name": 'OR',
				"elements": [
					_expression({
						"name": "LESS_THEN",
						"elements": [
							_variable('first_time'),
							_variable('second_time'),
						],
					}),
					_expression({
						"name": "GREATER_THEN",
						"elements": [
							_variable('third_time'),
							_variable('fourth_time'),
						],
					}),
				],
			}),
			"content": [ _line({ "value": 'comparison'})],
		}),
	])
	assert_eq_deep(result, expected)


func test_less_or_equal_and_greater_or_equal():
	var result = _parse("{ first_time <= second_time and third_time >= fourth_time } second comparison")

	var expected = _create_doc_payload([
		_conditional_content({
			"conditions": _expression({
				"name": 'AND',
				"elements": [
					_expression({
						"name": "LESS_OR_EQUAL_THEN",
						"elements": [
							_variable('first_time'),
							_variable('second_time'),
						],
					}),
					_expression({
						"name": "GREATER_OR_EQUAL_THEN",
						"elements": [
							_variable('third_time'),
							_variable('fourth_time'),
						],
					}),
				],
			}),
			"content": [_line({"value": 'second comparison'})],
		})
	])
	assert_eq_deep(result, expected)



func test__complex_precendence_case():
	var result = _parse("{ first_time > x + y - z * d / e % b } test")

	var expected = _create_doc_payload([
		_conditional_content({
			"conditions": _expression({
				"name": "GREATER_THEN",
				"elements": [
					_variable('first_time'),
					_expression({
						"name": "MINUS",
						"elements": [
							_expression({
								"name": "PLUS",
								"elements": [
									_variable('x'),
									_variable('y'),
								],
							}),
							_expression({
								"name": "MOD",
								"elements": [
									_expression({
										"name": "DIVIDE",
										"elements": [
											_expression({
												"name": "MULTIPLY",
												"elements": [
													_variable('z'),
													_variable('d'),
												],
											}),
											_variable('e'),
										],
									}),
									_variable('b'),
								],
							}),
						],
					}),
				],
			}),
			"content": [_line({"value": 'test'})],
		}),
	])
	assert_eq_deep(result, expected)



func test_number_literal():
	var result = _parse("{ first_time > 0 } hey")

	var expected = _create_doc_payload([
		_conditional_content({
			"conditions": _expression({
				"name": "GREATER_THEN",
				"elements": [
					_variable('first_time'),
					_number(0.0),
				],
			}),
			"content": [_line({"value": 'hey'})],
		}),
	])
	assert_eq_deep(result, expected)



func test__null_token():
	var result = _parse("{ first_time != null } ho")

	var expected = _create_doc_payload([
		_conditional_content({
			"conditions": _expression({
				"name": "LOGICAL_NOT_EQUAL",
				"elements": [
					_variable('first_time'),
					{ "type": NodeFactory.NODE_TYPES.NULL},
				],
			}),
			"content": [_line({"value": 'ho'})],
		})
	])
	assert_eq_deep(result, expected)



func test_boolean_literal():
	var result = _parse("{ first_time is false } let's go")

	var expected = _create_doc_payload([
		_conditional_content({
			"conditions": _expression({
				"name": "LOGICAL_EQUAL",
				"elements": [
					_variable('first_time'),
					_bool(false),
				],
			}),
			"content": [_line({"value": 'let\'s go'})],
		})
	])
	assert_eq_deep(result, expected)


func test_string_literal():
	var result = _parse("{ first_time is \"hello darkness >= my old friend\" } let's go")

	var expected = _create_doc_payload([
		_conditional_content({
			"conditions": _expression({
				"name": "LOGICAL_EQUAL",
				"elements": [
					_variable('first_time'),
					_string('hello darkness >= my old friend'),
				],
			}),
			"content": [_line({ "value": 'let\'s go'})],
		})
	])
	assert_eq_deep(result, expected)

func test_condition_before_line_with_keyword():
	var result = _parse("{ when some_var } This is conditional")
	var expected = _create_doc_payload([
		_conditional_content({
			"conditions": _variable("some_var"),
			"content": [_line({"value": "This is conditional"})]
		}),
	])
	assert_eq_deep(result, expected)


func test_condition_after_line():
	var result = _parse("This is conditional { when some_var }")
	var expected = _create_doc_payload([
		_conditional_content({
			"conditions": _variable("some_var"),
			"content": [_line({"value": "This is conditional"})]
		}),
	])
	assert_eq_deep(result, expected)


func test_condition_after_line_without_when():
	var result = _parse("This is conditional { some_var }")
	var expected = _create_doc_payload([
		_conditional_content({
			"conditions": _variable("some_var"),
			"content": [_line({"value": "This is conditional"})]
		}),
	])
	assert_eq_deep(result, expected)



func test_conditional_divert():
	var result = _parse("{ some_var } -> some_block")
	var expected = _create_doc_payload([
		_conditional_content({
			"conditions": _variable("some_var"),
			"content": [_divert("some_block")]
		}),
	])
	assert_eq_deep(result, expected)


func test_conditional_divert_after():
	var result = _parse("-> some_block { some_var }")
	var expected = _create_doc_payload([
		_conditional_content({
			"conditions": _variable("some_var"),
			"content": [_divert("some_block")]
		}),
	])
	assert_eq_deep(result, expected)


func test_conditional_option():
	var result = _parse("""
*= { some_var } option 1
*= option 2 { when some_var }
*= { some_other_var } option 3
""")
	var expected = _create_doc_payload([
		_options({
			"content": [
				_conditional_content({
					"conditions":_variable("some_var"),
					"content": [
						_option({
							"value": 'option 1',
							"mode": 'once',
							"content":  [_line({ "value": 'option 1'})],
						})
					],
				}),
				_conditional_content({
					"conditions": _variable("some_var"),
					"content": [
						_option({
							"value": 'option 2',
							"mode": 'once',
							"content": [_line({ "value": 'option 2'})],
						})
					],
				}),
				_conditional_content({
					"conditions": _variable("some_other_var"),
					"content": [
						_option({
							"value": 'option 3',
							"mode": 'once',
							"content":  [_line({"value": 'option 3'})],
						})
					],
				}),
			],
		})
	])
	assert_eq_deep(result, expected)


func test_conditional_indented_block():
	var result = _parse("""
{ some_var }
	This is conditional
	This is second conditional
	This is third conditional
""")
	var expected = _create_doc_payload([
		_conditional_content({
			"conditions": _variable("some_var"),
			"content": [
				_line({ "value" : "This is conditional"}),
				_line({ "value" : "This is second conditional"}),
				_line({ "value" : "This is third conditional"})
			]
			
		}),
	])
	assert_eq_deep(result, expected)


const assignments = [
	[ "=", "ASSIGN"],
	[ "+=", "SUM_ASSIGN"],
	[ "-=", "SUBTRACTION_ASSIGN"],
	[ "*=", "MULITPLICATION_ASSIGN"],
	[ "/=", "DIVISION_ASSIGN"],
	[ "%=", "MOD_ASSIGN"],
	[ "^=", "POWER_ASSIGN"],
]

func test_assignments():
	for a in assignments:
		_assignment_tests(a[0], a[1])


func _assignment_tests(token, node_name):
	var result = _parse("{ set a %s 2 } let's go" % token)
	var expected = _create_doc_payload([
		_action_content({
			"actions": [
				_assignments([
					_assignment({
						"variable": _variable('a'),
						"operation": node_name,
						"value": _number(2.0),
					}),
				]),
			],
			"content": [_line({"value": 'let\'s go'})],
		})
	])
	assert_eq_deep(result, expected)


func test_assignment_with_expression():
	var result = _parse('{ set a -= 4 ^ 2 } let\'s go')
	var expected = _create_doc_payload([\
		_action_content({
			"actions": [_assignments([
					_assignment({
						"variable": _variable('a'),
						"operation": "SUBTRACTION_ASSIGN",
						"value": _expression({
							"name": "POWER",
							"elements": [_number(4.0), _number(2.0)],
						}),
					}),
				]),
			],
			"content": [_line({"value": 'let\'s go'})],
		})
	])
	assert_eq_deep(result, expected)


func test_assignment_with_expression_after():
	var result = _parse('multiply { set a = a * 2 }')
	var expected = _create_doc_payload([
		_action_content({
			"actions": [_assignments([
					_assignment({
						"variable": _variable('a'),
						"operation": "ASSIGN",
						"value": _expression({
							"name": "MULTIPLY",
							"elements": [_variable('a'),_number(2.0)],
						}),
					}),
				]),
			],
			"content": [_line({"value": 'multiply'})],
		})
	])
	assert_eq_deep(result, expected)


func test_chaining_assigments():
	var result = _parse('{ set a = b = c = d = 3 } let\'s go')
	var expected = _create_doc_payload([
		_action_content({
			"actions": [_assignments([
					_assignment({
						"variable": _variable('a'),
						"operation": "ASSIGN",
						"value": _assignment({
							"variable": _variable('b'),
							"operation": "ASSIGN",
							"value": _assignment({
								"variable": _variable('c'),
								"operation": "ASSIGN",
								"value": _assignment({
									"variable": _variable('d'),
									"operation": "ASSIGN",
									"value": _number(3.0),
								}),
							}),
						}),
					}),
				]),
			],
			"content": [_line({"value": 'let\'s go'})],
		})
	])
	assert_eq_deep(result, expected)


func test_chaining_assigment_ending_with_variable():
		var result = _parse('{ set a = b = c } let\'s go')
		var expected = _create_doc_payload([
			_action_content({
				"actions": [
					_assignments([
						_assignment({
							"variable": _variable('a'),
							"operation": "ASSIGN",
							"value": _assignment({
								"variable": _variable('b'),
								"operation": "ASSIGN",
								"value": _variable('c'),
							}),
						}),
					]),
				],
				"content": [_line({"value": 'let\'s go'})],
			})
		])
		assert_eq_deep(result, expected)


func test_multiple_assigments_block():
	var result = _parse('{ set a -= 4, b=1, c = "hello" } hey you')
	var expected = _create_doc_payload([
		_action_content({
			"actions": [
				_assignments([
					_assignment({
						"variable": _variable('a'),
						"operation": "SUBTRACTION_ASSIGN",
						"value": _number(4.0),
					}),
					_assignment({
						"variable": _variable('b'),
						"operation": "ASSIGN",
						"value": _number(1.0),
					}),
					_assignment({
						"variable": _variable('c'),
						"operation": "ASSIGN",
						"value": _string('hello'),
					}),
				]),
			],
			"content": [_line({"value": 'hey you'})],
		})
	])
	assert_eq_deep(result, expected)


func test_assignment_after_line():
	var result = _parse("let's go { set a = 2 }")
	var expected = _create_doc_payload([
		_action_content({
			"actions": [
				_assignments([
					_assignment({
						"variable": _variable('a'),
						"operation": "ASSIGN",
						"value": _number(2.0),
					}),
				]),
			],
			"content": [_line({"value": 'let\'s go'})],
		})
	])
	assert_eq_deep(result, expected)


func test_standalone_assignment():
	var result = _parse("""
{ set a = 2 }
{ set b = 3 }""")

	var expected = _create_doc_payload([
		_assignments([
			_assignment({
				"variable": _variable('a'),
				"operation": "ASSIGN",
				"value": _number(2.0),
			}),
		]),
		_assignments([
			_assignment({
				"variable": _variable('b'),
				"operation": "ASSIGN",
				"value": _number(3.0),
			}),
		])
	])
	assert_eq_deep(result, expected)


func test_options_assignment():
	var result = _parse("""
*= { set a = 2 } option 1
*= option 2 { set b = 3 }
*= { set c = 4 } option 3
""")
	var expected = _create_doc_payload([
		_options({
			"content": [
				_action_content({
					"actions": [
						_assignments([
							_assignment({
								"variable": _variable('a'), 
								"operation": "ASSIGN", 
								"value":_number(2.0)
							})
						]),
					],
					"content": [
						_option({
							"value": 'option 1', 
							"mode": 'once',
							"content":  [_line({"value": 'option 1'})],
						})
					],
				}),
				_action_content({
					"actions": [_assignments([
							_assignment({ 
								"variable": _variable('b'),
								"operation": "ASSIGN", 
								"value": _number(3.0), 
							})
						]),
					],
					"content": [
						_option({
							"value": 'option 2', 
							"mode": 'once', 
							"content":  [_line({"value": 'option 2' })],
					})],
				}),
				_action_content({
					"actions": [
						_assignments([
							_assignment({
								"variable": _variable('c'), 
								"operation": "ASSIGN", 
								"value": _number(4.0),
							})
						]),
					],
					"content": [
						_option({ 
							"value": 'option 3',
							"mode": 'once', 
							"content": [_line({"value": 'option 3'})],
						})
					],
				}),
			],
		})
	])
	assert_eq_deep(result, expected)


func test_divert_with_assignment():
	var result = _parse("-> go { set a = 2 }")
	var expected = _create_doc_payload([
		_action_content({
			"actions": [
				_assignments([
					_assignment({
						"variable": _variable('a'),
						"operation": "ASSIGN",
						"value": _number(2.0),
					}),
				]),
			],
			"content": [_divert('go')],
		})
	])
	assert_eq_deep(result, expected)


func test_standalone_assignment_with_standalone_variable():
	var result = _parse("{ set a }")

	var expected = _create_doc_payload([
		_assignments([
			_assignment({
				"variable": _variable("a"),
				"operation": "ASSIGN",
				"value": _bool(true),
			}),
		]),
	])
	assert_eq_deep(result, expected)


func test_trigger_event():
	var result = _parse("{ trigger some_event } trigger")
	var expected = _create_doc_payload([
		_action_content({
			"actions": [_events([_event('some_event')])],
			"content": [_line({"value": 'trigger'})],
		})
	])
	assert_eq_deep(result, expected)


func test_trigger_multiple_events_in_one_block():
	var result = _parse("{ trigger some_event, another_event } trigger")
	var expected = _create_doc_payload([
		_action_content({
			"actions": [
				_events([
					_event('some_event'),
					_event('another_event')
				]),
			],
			"content": [_line({"value": 'trigger'})],
		})
	])
	assert_eq_deep(result, expected)


func test_standalone_trigger_event():
	var result = _parse("{ trigger some_event }")
	var expected = _create_doc_payload([_events([_event('some_event')])])
	assert_eq_deep(result, expected)


func test_trigger_event_after_line():
	var result = _parse("trigger { trigger some_event }")
	var expected = _create_doc_payload([
		_action_content({
			"actions": [_events([_event('some_event')])],
			"content": [_line({"value": 'trigger'})],
		})
	])
	assert_eq_deep(result, expected)


func test_options_trigger():
	var result = _parse("""
*= { trigger a } option 1
*= option 2 { trigger b }
*= { trigger c } option 3
""")
	var expected = _create_doc_payload([
		_options({
			"content": [
				_action_content({
					"actions": [_events([_event('a')])],
					"content": 
					[
						_option({
							"value": 'option 1', 
							"mode": 'once',
							"content": [ _line({"value": 'option 1'})],
						})
					],
				}),
				_action_content({
					"actions": [_events([_event('b')])],
					"content": [
						_option({
							"value": 'option 2',
							"mode": 'once',
							"content": [_line({ "value": 'option 2'})],
						})
					],
				}),
				_action_content({
					"actions": [_events([_event('c')])],
					"content": [
						_option({
							"value": 'option 3', 
							"mode": 'once',
							"content": [
									_line({"value": 'option 3'}),
								],
						})
					],
				}),
			],
		})
	])
	assert_eq_deep(result, expected)


func test_multiple_logic_blocks_in_the_same_line():
	var result = _parse("{ some_var } {set something = 1} { trigger event }")
	var expected = _create_doc_payload([
		_conditional_content({
			"conditions": _variable("some_var"),
			"content": [
				_action_content({
					"actions": [
						_assignments([
							_assignment({
								"variable": _variable('something'),
								"operation": "ASSIGN",
								"value": _number(1.0),
							})
						])
					],
					"content": [_events([_event('event')])],
				})
			],
		})
	])
	assert_eq_deep(result, expected)


func test_multiple_logic_blocks_in_the_same_line_before():
	var result = _parse("{ some_var } {set something = 1} { trigger event } hello")
	var expected = _create_doc_payload([
		_conditional_content({
			"conditions": _variable("some_var"),
			"content": [
				_action_content({
					"actions": [
						_assignments([
							_assignment({
								"variable": _variable('something'),
								"operation": "ASSIGN",
								"value": _number(1.0),
							})
						]),
					],
					"content": [
						_action_content({
							"actions": [_events([_event('event')])],
							"content": [_line({"value": 'hello'})],
						})
					],
				})
			],
		})
	])
	assert_eq_deep(result, expected)


func test_multiple_logic_blocks_in_the_same_line_after():
	var result = _parse("hello { when some_var } {set something = 1} { trigger event }")
	var expected = _create_doc_payload([
		_conditional_content({
			"conditions": _variable("some_var"),
			"content": [
				_action_content({
					"actions": [
						_assignments([
							_assignment({
								"variable": _variable('something'),
								"operation": "ASSIGN",
								"value": _number(1.0),
							})
						]),
					],
					"content": [
						_action_content({
							"actions": [_events([_event('event')])],
							"content": [_line({"value": 'hello'})],
						})
					],
				})
			],
		})
	])
	assert_eq_deep(result, expected)


func test_multiple_logic_blocks_in_the_same_line_around():
	var result = _parse("{ some_var } hello {set something = 1} { trigger event }")
	var expected = _create_doc_payload([
		_conditional_content({
			"conditions": _variable("some_var"),
			"content": [
				_action_content({
					"actions": [
						_assignments([
							_assignment({
								"variable": _variable('something'),
								"operation": "ASSIGN",
								"value": _number(1.0),
							})
						]),
					],
					"content": [
						_action_content({
							"actions": [_events([_event('event') ])],
							"content": [_line({"value": 'hello'})],
						})
					],
				})
			],
		})
	])
	assert_eq_deep(result, expected)


func test_multiple_logic_blocks_with_condition_after():
	var result = _parse("{set something = 1} { some_var } { trigger event } hello")
	var expected = _create_doc_payload([
		_action_content({
			"actions": [
				_assignments([
					_assignment({
						"variable": _variable('something'),
						"operation": "ASSIGN",
						"value": _number(1.0),
					})
				]),
			],
			"content": [
				_conditional_content({
					"conditions": _variable("some_var"),
					"content": [
						_action_content({
							"actions": [
								_events([_event('event')]),
							],
							"content": [
								_line({"value": 'hello'})
							],
						})
					],
				})
			],
		})
	])
	assert_eq_deep(result, expected)


func test_empty_block():
	var result = _parse("{} empty")
	var expected = _create_doc_payload([
		_conditional_content({
			"content": [_line({"value": 'empty'})],
			"conditions": {},
		})
	])
	assert_eq_deep(result, expected)


