extends GutTestFunctions


func test_simple_lines_file():
	var dialogue = Bonnie.new()
	dialogue.load_dialogue('simple_lines')

	var lines = [
		_line({ "value": "Dinner at Jack Rabbit Slim's:", "document_name" : "simple_lines" }),
		_line({ "value": "Don’t you hate that?", "speaker": "Mia", "document_name" : "simple_lines" }),
		_line({ "value": "What?", "speaker": "Vincent", "document_name" : "simple_lines" }),
		_line({ "value": "Uncomfortable silences. Why do we feel it’s necessary to yak about bullshit in order to be comfortable?", "speaker": "Mia", "id": "145", "document_name" : "simple_lines" }),
		_line({ "value": "I don’t know. That’s a good question.", "speaker": "Vincent", "document_name" : "simple_lines" }),
		_line({ "value": "That’s when you know you’ve found somebody special. When you can just shut the fuck up for a minute and comfortably enjoy the silence.", "speaker": "Mia", "id": "123", "document_name" : "simple_lines"}),
	]

	for line in lines:
		assert_eq_deep(BonnieParser.new().to_JSON_object(dialogue.get_content()), line)


func test_translate_files():
	TranslationServer.set_locale("pt_BR")
	var t = Translation.new()
	t.locale = "pt_BR"
	t.add_message("145", "Tradução")
	TranslationServer.add_translation(t)
	var dialogue = Bonnie.new()
	dialogue.load_dialogue('simple_lines')

	var lines = [
		_line({  "value": "Dinner at Jack Rabbit Slim's:", "document_name" : "simple_lines"}),
		_line({  "value": "Don’t you hate that?", "speaker": "Mia", "document_name" : "simple_lines" }),
		_line({  "value": "What?", "speaker": "Vincent", "document_name" : "simple_lines" }),
		_line({  "value": "Tradução", "speaker": "Mia", "id": "145", "document_name" : "simple_lines" }),
		_line({  "value": "I don’t know. That’s a good question.", "speaker": "Vincent", "document_name" : "simple_lines" }),
		_line({  "value": "That’s when you know you’ve found somebody special. When you can just shut the fuck up for a minute and comfortably enjoy the silence.", "speaker": "Mia", "id": "123", "document_name" : "simple_lines"}),
	]

	for line in lines:
		assert_eq_deep(BonnieParser.new().to_JSON_object(dialogue.get_content()), line)

	TranslationServer.set_locale("en")


func _initialize_dictionary():
	var t = Translation.new()
	t.locale = "en"
	t.add_message("abc", "simple key")
	t.add_message("abc&P", "simple key with suffix 1")
	t.add_message("abc&P&S", "simple key with suffix 1 and 2")
	t.add_message("abc&S", "simple key with only suffix 2")
	t.add_message("abc__P", "this uses custom suffix")
	TranslationServer.add_translation(t)
	TranslationServer.set_locale("en")


func _initialize_interpreter_for_suffix_test():
	var interpreter = BonnieInterpreter.new()
	var content = _parse("This should be replaced $abc&suffix_1&suffix_2")
	interpreter.init(content)
	return interpreter


func test_id_suffix_returns_line_with_suffix_value():
	var interpreter = _initialize_interpreter_for_suffix_test()
	_initialize_dictionary()
	interpreter.set_variable("suffix_1", "P");

	assert_eq(interpreter.get_current_node().value, "simple key with suffix 1")


func test_id_suffix_returns_line_with_multiple_suffixes_value():
	var interpreter = _initialize_interpreter_for_suffix_test()
	_initialize_dictionary()
	interpreter.set_variable("suffix_1", "P");
	interpreter.set_variable("suffix_2", "S");

	assert_eq(interpreter.get_current_node().value, "simple key with suffix 1 and 2")


func test_id_suffix_ignores_suffix_if_variable_is_not_set():
	var interpreter = _initialize_interpreter_for_suffix_test()
	_initialize_dictionary()
	interpreter.set_variable("suffix_1", "S");

	assert_eq(interpreter.get_current_node().value, "simple key with only suffix 2")


func test_id_suffix_ignores_all_suffixes_when_variables_not_set():
	var interpreter = _initialize_interpreter_for_suffix_test()
	_initialize_dictionary()

	assert_eq(interpreter.get_current_node().value, "simple key")


func test_id_suffix_fallsback_to_id_without_prefix_when_not_found():
	var interpreter = _initialize_interpreter_for_suffix_test()
	_initialize_dictionary()

	interpreter.set_variable("suffix_1", "banana");

	assert_eq(interpreter.get_current_node().value, "simple key")


func test_id_suffix_works_with_options():
	var interpreter = BonnieInterpreter.new()
	var content = _parse("""
first topics $abc&suffix1
	* option 1 $abc&suffix2
		blah
	*
		blah $abc&suffix1&suffix2""")
	interpreter.init(content)

	_initialize_dictionary()

	interpreter.set_variable("suffix1", "P");
	interpreter.set_variable("suffix2", "S");
	var first_options = interpreter.get_current_node()
	assert_eq(first_options.value, "simple key with suffix 1")
	assert_eq(first_options.content[0].value, "simple key with only suffix 2")

	interpreter.choose(1);

	var second_options = interpreter.get_current_node();
	assert_eq(second_options.value, "simple key with suffix 1 and 2")


func test_interpreter_option_id_lookup_suffix():
	_initialize_dictionary()

	var interpreter = BonnieInterpreter.new()
	var content = _parse("This should be replaced $abc&suffix_1&suffix_2")
	interpreter.init(content, { "id_suffix_lookup_separator": "__" })
	interpreter.set_variable("suffix_1", "P");

	assert_eq(interpreter.get_current_node().value, "this uses custom suffix")


func test_options():
	var dialogue = Bonnie.new()
	dialogue.load_dialogue('options')


	var first_part = [
		_line({  "value": "what do you want to talk about?", "speaker": "npc", "document_name" : "options" }),
		_options({ "content": [
			_option({ "name": "Life", "document_name" : "options" }), 
			_option({ "name": "The universe", "document_name" : "options" }), 
			_option({ "name": "Everything else...", "tags": ["some_tag"], "document_name" : "options" })]
			, "document_name" : "options" }),
		]

	var life_option = [
		_line({  "value": "I want to talk about life!", "speaker": "player", "document_name" : "options" }),
		_line({  "value": "Well! That's too complicated...", "speaker": "npc", "document_name" : "options" }),
	]

	for line in first_part:
		var q = BonnieParser.new().to_JSON_object(dialogue.get_content())
		q.content = []
		line.content = []
		assert_eq_deep(q, line)

	dialogue.choose(0)

	for line in life_option:
		var q = BonnieParser.new().to_JSON_object(dialogue.get_content())
		assert_eq_deep(q, line)


func test_fallback_options():
	var interpreter = BonnieInterpreter.new()
	var content = _parse("*= a\n>= b\nend")
	interpreter.init(content)
	var q = BonnieParser.new().to_JSON_object(interpreter.get_current_node())
	q.content[0].content = []
	q.content[1].content = []
	assert_eq_deep(q, _options({ "content": [_option({ "mode" : "once","value": "a" }), _option({ "value": "b", "mode" : "fallback"}) ] }))
	interpreter.choose(0)
	assert_eq_deep(interpreter.get_current_node().value, "a")
	assert_eq_deep(interpreter.get_current_node().value, "end")
	interpreter.select_block()
	assert_eq_deep(BonnieParser.new().to_JSON_object(interpreter.get_current_node()), _line({  "value": "b" }))


func test_blocks_and_diverts():
	var dialogue = Bonnie.new()
	dialogue.load_dialogue('diverts', 'initial_dialog')


	var initial_dialogue = [
		_line({"value": "what do you want to talk about?", "speaker": "npc", "document_name" : "diverts" }),
		_options({ "content": [
			_option({ "value": "Life", "document_name" : "diverts" }),
			_option({ "mode" : "once","value": "The universe","document_name" : "diverts" }), 
			_option({ "mode" : "once","value": "Everything else...", "document_name" : "diverts"  }), 
			_option({"mode" : "once", "value": "Goodbye!", "document_name" : "diverts"  })]
			, "document_name" : "diverts"  }),
	]

	var life_option = [
		_line({ "value": "I want to talk about life!", "speaker": "player", "document_name" : "diverts"  }),
		_line({  "value": "Well! That's too complicated...", "speaker": "npc", "document_name" : "diverts"  }),
		# back to initial dialogue
		_options({ "content": [
			_option({ "mode" : "once", "value": "The universe" , "document_name" : "diverts" }), 
			_option({ "mode" : "once","value": "Everything else...", "document_name" : "diverts"  }), 
			_option({ "mode" : "once","value": "Goodbye!", "document_name" : "diverts"  })], 
			"document_name" : "diverts"  })
	]

	var everything_option = [
		_line({  "value": "What about everything else?", "speaker": "player", "document_name" : "diverts"  }),
		_line({ "value": "I don't have time for this...", "speaker": "npc", "document_name" : "diverts"  }),
		# back to initial dialogue
		_options({ "options": [
			_option({ "value": "The universe", "document_name" : "diverts"  }), 
			_option({ "value": "Goodbye!", "document_name" : "diverts"  })], 
			"document_name" : "diverts"  })
	]

	var universe_option = [
		_line({  "value": "I want to talk about the universe!", "speaker": "player", "document_name" : "diverts"  }),
		_line({ "value": "That's too complex!", "speaker": "npc", "document_name" : "diverts"  }),
		# back to initial dialogue
		_options({ "options": [_option({ "value": "Goodbye!", "document_name" : "diverts"  })], "document_name" : "diverts"  })
	]

	var goodbye_option = [
		_line({ "value": "See you next time!", "speaker": "player", "document_name" : "diverts"  }),
		null
	]

	for line in initial_dialogue:
		var q = BonnieParser.new().to_JSON_object(dialogue.get_content())
		q.content = []
		line.content = []
		assert_eq_deep(q, line)

	dialogue.choose(0)

	for line in life_option:
		var q = BonnieParser.new().to_JSON_object(dialogue.get_content())
		if(q.has("content")):
			q.content[0].content = []
			q.content[1].content = []
			q.content[2].content = []
		assert_eq_deep(q, line)
	dialogue.choose(1)

	for line in everything_option:
		var q = BonnieParser.new().to_JSON_object(dialogue.get_content())
		if(q.has("content")):
			q.content = []
		assert_eq_deep(q, line)
	dialogue.choose(0)

	for line in universe_option:
		var q = BonnieParser.new().to_JSON_object(dialogue.get_content())
		if(q.has("content")):
			q.content = []
			pass
		assert_eq_deep(q, line)
	dialogue.choose(0)

	for line in goodbye_option:
		var line_dic = BonnieParser.new().to_JSON_object(dialogue.get_content())
		if(line_dic.keys().size() == 0):
			assert_eq_deep(null, line)
		else:
			assert_eq_deep(line_dic, line)


func test_variations():
	var dialogue = Bonnie.new()
	dialogue.load_dialogue('variations')

	var sequence = ["Hello", "Hi", "Hey"]
	var random_sequence = ["Hello", "Hi", "Hey"]
	var once = ["nested example", "here I am"]
	var random_cycle = ["multiline example do you think it works?", "yep"]

	for _i in range(4):
		dialogue.start()
		var thing = BonnieParser.new().to_JSON_object(dialogue.get_content())
		# sequence
		assert_eq_deep(
			thing.value,
			sequence[0]
		)

		if sequence.size() > 1:
			sequence.pop_front()

		# random sequence
		var rs = BonnieParser.new().to_JSON_object(dialogue.get_content()).value
		assert_has(random_sequence, rs)
		if random_sequence.size() > 1:
			random_sequence.erase(rs)

		# once each
		if (once.size() != 0):
			var o = BonnieParser.new().to_JSON_object(dialogue.get_content()).value
			assert_has(once, o)
			once.erase(o)

		# random cycle
		var rc = BonnieParser.new().to_JSON_object(dialogue.get_content()).value
		assert_has(random_cycle, rc)
		random_cycle.erase(rc)
		if random_cycle.size() == 0:
			random_cycle = ["multiline example do you think it works?", "yep"]


func _test_variation_default_shuffle_is_cycle():
	var interpreter = BonnieInterpreter.new()
	var content = _parse("( shuffle \n- { a } A\n -  { b } B\n)\nend\n")
	interpreter.init(content)

	var random_default_cycle = ["a", "b"]
	for _i in range(2):
		var rdc = interpreter.get_current_node().value
		assert_has(random_default_cycle, rdc)
		random_default_cycle.erase(rdc)

	assert_eq(random_default_cycle.size(), 0)
	# should re-shuffle after exausting all options
	random_default_cycle = ["a", "b"]
	for _i in range(2):
		var rdc = interpreter.get_current_node().value
		assert_has(random_default_cycle, rdc)
		random_default_cycle.erase(rdc)

	assert_eq(random_default_cycle.size(), 0)


func test_all_variations_not_available():
	var interpreter = BonnieInterpreter.new()
	var content = _parse("(\n - { a } A\n -  { b } B\n)\nend\n")
	interpreter.init(content)

	assert_eq_deep(interpreter.get_current_node().value, 'end')


func test_logic():
	var dialogue = Bonnie.new()
	dialogue.load_dialogue('logic')
	assert_eq_deep(BonnieParser.new().to_JSON_object(dialogue.get_content()).value, "variable was initialized with 1")
	assert_eq_deep(BonnieParser.new().to_JSON_object(dialogue.get_content()).value, "setting multiple variables")
	assert_eq_deep(BonnieParser.new().to_JSON_object(dialogue.get_content()).value, "4 == 4.  3 == 3")
	assert_eq_deep(BonnieParser.new().to_JSON_object(dialogue.get_content()).value, "This is a block")
	assert_eq_deep(BonnieParser.new().to_JSON_object(dialogue.get_content()).value, "inside a condition")
	var line = BonnieParser.new().to_JSON_object(dialogue.get_content())
	if(line.keys().size() == 0):
		assert_eq_deep(null, null)
	else:
		assert_eq_deep(line, null)


func test_variables():
	var dialogue = Bonnie.new()
	dialogue.load_dialogue('variables')
	var u = dialogue.get_content()
	assert_eq_deep(BonnieParser.new().to_JSON_object(u).value, "not")
	var t = dialogue.get_content()
	assert_eq_deep(BonnieParser.new().to_JSON_object(t).value, "equality")
	var p = dialogue.get_content()
	assert_eq_deep(BonnieParser.new().to_JSON_object(p).value, "alias equality")
	var y = dialogue.get_content()
	assert_eq_deep(BonnieParser.new().to_JSON_object(y).value, "trigger")
	var z = dialogue.get_content();
	assert_eq_deep(BonnieParser.new().to_JSON_object(z).value, "hey you")
	var q = dialogue.get_content()
	assert_eq_deep(BonnieParser.new().to_JSON_object(q).value, "hey {you}")
	var j = dialogue.get_content()


	dialogue.choose(1)

	var h = dialogue.get_content()
	var i = dialogue.get_content()
	var k = dialogue.get_content()
	assert_eq_deep(BonnieParser.new().to_JSON_object(h), _line({  "value": "I want to talk about the universe!", "speaker": "player", "document_name" : "variables" }))
	assert_eq_deep(BonnieParser.new().to_JSON_object(i), _line({  "value": "That's too complex!", "speaker": "npc" , "document_name" : "variables"}))
	assert_eq_deep(BonnieParser.new().to_JSON_object(k), _line({  "value": "I'm in trouble", "document_name" : "variables" }))
	
	j.content[0].content = []
	j.content[1].content = []
	j.content[0].actions = []
	assert_eq_deep(
		BonnieParser.new().to_JSON_object(j),
		_options({ "content": [
			_action_content({ "mode": "once", "value": "Life", "document_name" : "variables" }), 
			_option({ "mode": "once","value": "The universe", "document_name" : "variables" })], 
			"document_name" : "variables" })
	)
	
	var line = BonnieParser.new().to_JSON_object(dialogue.get_content())
	
	if(line.keys().size() == 0):
		assert_eq_deep(null, null)
	else:
		assert_eq_deep(line, null)
	assert_eq_deep(dialogue.get_variable('xx'), true)


func test_set_variables():
	var dialogue = Bonnie.new()
	dialogue.load_dialogue('variables.bonnie')
	dialogue.set_variable('first_time', true)
	assert_eq_deep(BonnieParser.new().to_JSON_object(dialogue.get_content()).value, "what do you want to talk about?")
	dialogue.set_variable('first_time', false)
	dialogue.start()
	assert_eq_deep(BonnieParser.new().to_JSON_object(dialogue.get_content()).value, "not")


func test_data_control():
	var dialogue = Bonnie.new()
	dialogue.load_dialogue('variations')

	assert_eq_deep(BonnieParser.new().to_JSON_object(dialogue.get_content()).value, "Hello")
	dialogue.start()
	assert_eq_deep(BonnieParser.new().to_JSON_object(dialogue.get_content()).value, "Hi")

	var dialogue2 = Bonnie.new()
	dialogue2.load_dialogue('variations')
	dialogue2.load_data(dialogue.get_data())
	assert_eq_deep(dialogue2.get_content().value, "Hey")

	dialogue.clear_data()
	dialogue.start()
	assert_eq_deep(BonnieParser.new().to_JSON_object(dialogue.get_content()).value, "Hello")


func test_persisted_data_control_options():
	var dialogue = Bonnie.new()
	dialogue.load_dialogue('options')

	var content = _get_next_options_content(dialogue)
	assert_eq(content.content.size(), 3)

	dialogue.choose(0)
	dialogue.start()

	content = _get_next_options_content(dialogue)
	assert_eq(content.content.size(), 2)


	var stringified_data = JSON.stringify(
		{"access" : dialogue.get_data().access,
		"variables" : dialogue.get_data().variables,
		"internal" : dialogue.get_data().internal })

	var dialogue2 = Bonnie.new()
	dialogue2.load_dialogue('options')
	dialogue2.load_data(dialogue.get_data())

	var content2 = _get_next_options_content(dialogue)
	assert_eq(content2.content.size(), 2)
	assert_eq_deep(content2, content)


func test_persisted_data_control_variations():
	var dialogue = Bonnie.new()
	dialogue.load_dialogue('variations')

	assert_eq_deep(BonnieParser.new().to_JSON_object(dialogue.get_content()).value, "Hello")
	dialogue.start()
	assert_eq_deep(BonnieParser.new().to_JSON_object(dialogue.get_content()).value, "Hi")

	var dialogue2 = Bonnie.new()
	dialogue2.load_dialogue('variations')

	var memory = dialogue.get_data()

	dialogue2.load_data(memory)
	assert_eq_deep(dialogue2.get_content().value, "Hey")


var pending_events = []

func test_events():
	var dialogue = Bonnie.new()
	dialogue.load_dialogue('variables')
	dialogue.connect("event_triggered", Callable(self, "_on_event_triggered"))
	dialogue.connect("variable_changed", Callable(self, "_on_variable_changed"))

	pending_events.push_back({ "type": "variable", "name": "xx", "value": true })
	pending_events.push_back({ "type": "variable", "name": "first_time", "value": 2.0 })
	pending_events.push_back({ "type": "variable", "name": "a", "value": 3.0 })
	pending_events.push_back({ "type": "variable", "name": "b", "value": 3.0 })
	pending_events.push_back({ "type": "variable", "name": "c", "value": 3.0 })
	pending_events.push_back({ "type": "variable", "name": "d", "value": 3.0 })
	pending_events.push_back({ "type": "variable", "name": "a", "value": 6.0 })
	pending_events.push_back({ "type": "variable", "name": "a", "value": -10.0 })
	pending_events.push_back({ "type": "event", "name": "some_event" })
	pending_events.push_back({ "type": "event", "name": "another_event" })
	pending_events.push_back({ "type": "variable", "name": "a", "value": -14.0 })
	pending_events.push_back({ "type": "variable", "name": "b", "value": 1.0 })
	pending_events.push_back({ "type": "variable", "name": "c", "value": "hello" })
	pending_events.push_back({ "type": "variable", "name": "a", "value": 4.0 })
	pending_events.push_back({ "type": "variable", "name": "hp", "value": 5.0 })
	pending_events.push_back({ "type": "variable", "name": "s", "value": false })
	pending_events.push_back({ "type": "variable", "name": "x", "value": true })

	while true:
		var res = BonnieParser.new().to_JSON_object(dialogue.get_content())
		if res.size() == 0:
			break;
		if res.type == NodeFactory.NODE_TYPES.OPTIONS:
			dialogue.choose(0)

	assert_eq(pending_events.size(), 0)


func _on_variable_changed(name, value, _previous_value):
	if(name.contains(".")):
		name = name.split(".")[1]
	for e in pending_events:
		if e.type == 'variable' and e.name == name and  typeof(e.value) == typeof(value) and  e.value == value:
			pending_events.erase(e)


func _on_event_triggered(event_name):
	for e in pending_events:
		if e.type == 'event' and e.name == event_name:
			pending_events.erase(e)


func test_file_path_without_extension():
	var dialogue = Bonnie.new()
	dialogue.load_dialogue('simple_lines')

	var lines = [
		_line({  "value": "Dinner at Jack Rabbit Slim's:", "document_name" : "simple_lines"  }),
		_line({  "value": "Don’t you hate that?", "speaker": "Mia", "document_name" : "simple_lines" }),
		_line({  "value": "What?", "speaker": "Vincent", "document_name" : "simple_lines" }),
		_line({  "value": "Uncomfortable silences. Why do we feel it’s necessary to yak about bullshit in order to be comfortable?", "speaker": "Mia", "id": "145", "document_name" : "simple_lines"}),
		_line({  "value": "I don’t know. That’s a good question.", "speaker": "Vincent", "document_name" : "simple_lines" }),
		_line({  "value": "That’s when you know you’ve found somebody special. When you can just shut the fuck up for a minute and comfortably enjoy the silence.", "speaker": "Mia", "id": "123", "document_name" : "simple_lines"}),
	]

	for line in lines:
		assert_eq_deep(BonnieParser.new().to_JSON_object(dialogue.get_content()), line)


func test_uses_configured_dialogue_folder():
	var dialogue = Bonnie.new()
	dialogue.dialogue_folder = 'res://dialogues'
	dialogue.load_dialogue('simple_lines')

	var lines = [
		_line({  "value": "Dinner at Jack Rabbit Slim's:", "document_name" : "simple_lines" }),
		_line({  "value": "Don’t you hate that?", "speaker": "Mia", "document_name" : "simple_lines" }),
		_line({  "value": "What?", "speaker": "Vincent", "document_name" : "simple_lines" }),
		_line({  "value": "Uncomfortable silences. Why do we feel it’s necessary to yak about bullshit in order to be comfortable?", "speaker": "Mia", "id": "145", "document_name" : "simple_lines" }),
		_line({  "value": "I don’t know. That’s a good question.", "speaker": "Vincent", "document_name" : "simple_lines" }),
		_line({  "value": "That’s when you know you’ve found somebody special. When you can just shut the fuck up for a minute and comfortably enjoy the silence.", "speaker": "Mia", "id": "123", "document_name" : "simple_lines"}),
	]

	for line in lines:
		assert_eq_deep(BonnieParser.new().to_JSON_object(dialogue.get_content()), line)


func test_dependent_logic():
	var dialogue = Bonnie.new()
	dialogue.load_dialogue('dependent_logic')
	var line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, "variable was")
	assert_eq_deep(line_part.end_line, false)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, " initialized with 1")
	assert_eq_deep(line_part.end_line, true)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, "setting")
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, " multiple variables")
	assert_eq_deep(line_part.end_line, true)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, "  4 == 4.  3 == 3")
	assert_eq_deep(line_part.end_line, true)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, "you")
	assert_eq_deep(line_part.end_line, true)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, "hey")
	assert_eq_deep(line_part.end_line, true)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, "Hello ")
	assert_eq_deep(line_part.end_line, false)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, " you!")
	assert_eq_deep(line_part.end_line, true)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, " This is a line inside a condition")
	assert_eq_deep(line_part.end_line, true)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, "trigger ")
	assert_eq_deep(line_part.end_line, false)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, " this!")
	assert_eq_deep(line_part.end_line, true)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, "plz ")
	assert_eq_deep(line_part.end_line, false)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, " trigger me daddy!!")
	assert_eq_deep(line_part.end_line, true)
	
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.value, "logic happening")
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	if(line_part.keys().size() == 0):
		assert_eq_deep(null, null)
	else:
		assert_eq_deep(line_part, null)
		

func test_bb_code():
	var dialogue = Bonnie.new()
	dialogue.load_dialogue('bb_code')
	var line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, "variable was")
	assert_eq_deep(line_part.end_line, false)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, " initialized with 1")
	assert_eq_deep(line_part.part.bb_code_before_line, "[b]")
	assert_eq_deep(line_part.end_line, true)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, "setting ")
	assert_eq_deep(line_part.end_line, false)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, " multiple ")
	assert_eq_deep(line_part.end_line, false)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, " variables")
	assert_eq_deep(line_part.part.bb_code_before_line, "[b]")
	assert_eq_deep(line_part.end_line, false)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, "")
	assert_eq_deep(line_part.part.bb_code_before_line, "[/b]")
	assert_eq_deep(line_part.end_line, true)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, "  4 == 4.  3 == 3")
	assert_eq_deep(line_part.end_line, true)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, "you")
	assert_eq_deep(line_part.part.bb_code_before_line, "[b]")
	assert_eq_deep(line_part.end_line, true)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, "hey ")
	assert_eq_deep(line_part.end_line, true)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, "Hello ")
	assert_eq_deep(line_part.end_line, false)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, " you! ")
	assert_eq_deep(line_part.end_line, false)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, "")
	assert_eq_deep(line_part.part.bb_code_before_line, "[/b]")
	assert_eq_deep(line_part.end_line, true)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, " This is a ")
	assert_eq_deep(line_part.end_line, false)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, "line")
	assert_eq_deep(line_part.end_line, false)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, " inside ")
	assert_eq_deep(line_part.end_line, false)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, "a ")
	assert_eq_deep(line_part.end_line, false)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, "condition")
	assert_eq_deep(line_part.end_line, true)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, "")
	assert_eq_deep(line_part.part.bb_code_before_line, "[b]")
	assert_eq_deep(line_part.end_line, false)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, "")
	assert_eq_deep(line_part.part.bb_code_before_line, "[b]")
	assert_eq_deep(line_part.end_line, false)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, "")
	assert_eq_deep(line_part.part.bb_code_before_line, "[b]")
	assert_eq_deep(line_part.end_line, false)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, "")
	assert_eq_deep(line_part.part.bb_code_before_line, "[b]")
	assert_eq_deep(line_part.end_line, false)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, "")
	assert_eq_deep(line_part.part.bb_code_before_line, "[b]")
	assert_eq_deep(line_part.end_line, false)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, "")
	assert_eq_deep(line_part.part.bb_code_before_line, "[b]")
	assert_eq_deep(line_part.end_line, false)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, "")
	assert_eq_deep(line_part.part.bb_code_before_line, "[b]")
	assert_eq_deep(line_part.end_line, false)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, "")
	assert_eq_deep(line_part.part.bb_code_before_line, "[b]")
	assert_eq_deep(line_part.end_line, false)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, "")
	assert_eq_deep(line_part.part.bb_code_before_line, "[b]")
	assert_eq_deep(line_part.end_line, false)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, "")
	assert_eq_deep(line_part.part.bb_code_before_line, "[b]")
	assert_eq_deep(line_part.end_line, true)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, "trigger")
	assert_eq_deep(line_part.end_line, false)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, "")
	assert_eq_deep(line_part.part.bb_code_before_line, "[b]")
	assert_eq_deep(line_part.end_line, false)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, " this! ")
	assert_eq_deep(line_part.end_line, false)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, "")
	assert_eq_deep(line_part.part.bb_code_before_line, "[b]")
	assert_eq_deep(line_part.end_line, true)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, "plz ")
	assert_eq_deep(line_part.end_line, false)
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.part.value, " trigger me daddy!!")
	assert_eq_deep(line_part.end_line, true)
	assert_eq_deep(line_part.part.bb_code_before_line, "[b]")
	
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	assert_eq_deep(line_part.value, "logic happening")
	line_part = BonnieParser.new().to_JSON_object(dialogue.get_content())
	if(line_part.keys().size() == 0):
		assert_eq_deep(null, null)
	else:
		assert_eq_deep(line_part, null)


func test_block_reqs():
	var dialogue = Bonnie.new()
	dialogue.load_dialogue('block_reqs')
	assert_eq_deep(null, dialogue.get_content())
	assert_eq_deep(true, dialogue.start("block1", true))
	assert_eq_deep(false, dialogue.start("block2", true))
	assert_eq_deep(true, dialogue.start("block3", true))
	assert_eq_deep(null, dialogue.get_content())
	assert_eq_deep(true, dialogue.start("block2", true))
	assert_eq_deep(true, dialogue.start("block4", true))
	assert_eq_deep(null, dialogue.get_content())
	assert_eq_deep(true, dialogue.start("block5", true))
	assert_eq_deep(true, dialogue.start("block6", true))
	assert_eq_deep("everything works!", dialogue.get_content().value)


func test_random_block_reqs():
	var dialogue = Bonnie.new()
	dialogue.load_dialogue('random_block_reqs')
	assert_eq_deep(null, dialogue.get_content())
	assert_eq_deep(true, dialogue.set_random_block(true))
	assert_eq_deep(true, dialogue.set_random_block(true))
	assert_eq_deep(null, dialogue.get_content())
	assert_eq_deep(true, dialogue.set_random_block(true))
	assert_eq_deep(true, dialogue.set_random_block(true))
	assert_eq_deep(null, dialogue.get_content())
	assert_eq_deep(true, dialogue.set_random_block(true))
	assert_eq_deep(true, dialogue.set_random_block(true))
	assert_eq_deep("everything works!", dialogue.get_content().value)

func test_load_multiple_dialogues():
	var dialogue = BonnieManager.new()
	dialogue.load_dialogue('random_block_reqs')
	dialogue.load_dialogue('block_reqs')
	assert_eq_deep(null, dialogue.get_content())
	dialogue.load_dialogue('random_block_reqs')
	assert_eq_deep(null, dialogue.get_content())
	assert_eq_deep(true, dialogue.set_random_block(true))
	assert_eq_deep(null, dialogue.get_content())
	dialogue.load_dialogue('block_reqs')
	assert_eq_deep(true, dialogue.start("block1", true))
	assert_eq_deep(false, dialogue.start("block2", true))
	assert_eq_deep(true, dialogue.start("block3", true))
	assert_eq_deep(null, dialogue.get_content())
	assert_eq_deep(true, dialogue.start("block2", true))
	assert_eq_deep(true, dialogue.start("block4", true))
	assert_eq_deep(null, dialogue.get_content())
	assert_eq_deep(true, dialogue.start("block5", true))
	assert_eq_deep(true, dialogue.start("block6", true))
	assert_eq_deep("everything works!", dialogue.get_content().value)
	dialogue.load_dialogue('random_block_reqs')
	assert_eq_deep(true, dialogue.set_random_block(true))
	assert_eq_deep(null, dialogue.get_content())
	assert_eq_deep(true, dialogue.set_random_block(true))
	assert_eq_deep(true, dialogue.set_random_block(true))
	assert_eq_deep(null, dialogue.get_content())
	assert_eq_deep(true, dialogue.set_random_block(true))
	assert_eq_deep(true, dialogue.set_random_block(true))
	assert_eq_deep("everything works!", dialogue.get_content().value)


func test_random_dialogues_different_scripts():
	var dialogue = BonnieManager.new()
	dialogue.load_dialogue('other_random_blocks')
	assert_eq_deep(null, dialogue.get_content())
	assert_eq_deep(15, dialogue.get_variable("x"))
	dialogue.load_dialogue('other_other_random_blocks')
	assert_eq_deep(null, dialogue.get_content())
	assert_eq_deep(72, dialogue.get_variable("x"))
	assert_eq_deep(15, dialogue.get_variable("other_random_blocks.x"))
	assert_eq_deep(true, dialogue.set_random_block(true))
	assert_eq_deep(null, dialogue.get_content())
	assert_eq_deep(true, dialogue.set_random_block(true))
	assert_eq_deep(null, dialogue.get_content())
	assert_eq_deep(65, dialogue.get_variable("x"))
	assert_eq_deep(75, dialogue.get_variable("other_random_blocks.x"))
	dialogue.load_dialogue('other_random_blocks')
	assert_eq_deep(65, dialogue.get_variable("other_other_random_blocks.x"))
	assert_eq_deep(75, dialogue.get_variable("x"))


func test_diverts_different_scripts():
	var dialogue = BonnieManager.new()
	dialogue.load_dialogue('other_file_divert')
	dialogue.load_dialogue('divert_to_other_file')
	assert_eq_deep(true, dialogue.start("block1", true))
	assert_eq_deep(null, dialogue.get_content())
	assert_eq_deep(7, dialogue.get_variable("x"))
	assert_eq_deep(8, dialogue.get_variable("other_file_divert.x"))
	dialogue.load_dialogue('other_file_divert')
	assert_eq_deep(7, dialogue.get_variable("divert_to_other_file.x"))
	assert_eq_deep(8, dialogue.get_variable("x"))
	

func test_diverts_multiple_different_scripts():
	var dialogue = BonnieManager.new()
	dialogue.load_dialogue('other_file_divert')
	dialogue.load_dialogue('divert_to_other_file')
	dialogue.load_dialogue('third_other_file_divert')
	assert_eq_deep(true, dialogue.start("divert_to_other_file.block3", true))
	assert_eq_deep(null, dialogue.get_content())
	assert_eq_deep(16, dialogue.get_variable("x"))
	assert_eq_deep(8, dialogue.get_variable("other_file_divert.x"))
	assert_eq_deep(7, dialogue.get_variable("other_file_divert.y"))
	assert_eq_deep(9, dialogue.get_variable("divert_to_other_file.x"))


func test_global_variables():
	var dialogue = BonnieManager.new()
	dialogue.load_dialogue('other_file_divert')
	dialogue.load_dialogue('divert_to_other_file')
	assert_eq_deep(true, dialogue.start("other_file_divert.block8", true))
	assert_eq_deep(null, dialogue.get_content())
	assert_eq_deep(30, dialogue.get_variable("@x"))
	assert_eq_deep(54, dialogue.get_variable("other_file_divert.x"))
	assert_eq_deep(7, dialogue.get_variable("divert_to_other_file.x"))


func test_load_files_from_directory():
	var dialogue = BonnieManager.new()
	dialogue.load_dialogue_files_in_directory()
	assert_eq_deep(true, dialogue.start("other_file_divert.block8", true))
	assert_eq_deep(null, dialogue.get_content())
	assert_eq_deep(30, dialogue.get_variable("@x"))
	assert_eq_deep(54, dialogue.get_variable("other_file_divert.x"))
	assert_eq_deep(7, dialogue.get_variable("divert_to_other_file.x"))


func test_load_multiple_files():
	var dialogue = BonnieManager.new()
	dialogue.load_selected_dialogue_files(["other_file_divert", "divert_to_other_file"])
	assert_eq_deep(true, dialogue.start("other_file_divert.block8", true))
	assert_eq_deep(null, dialogue.get_content())
	assert_eq_deep(30, dialogue.get_variable("@x"))
	assert_eq_deep(54, dialogue.get_variable("other_file_divert.x"))
	assert_eq_deep(7, dialogue.get_variable("divert_to_other_file.x"))
	
	
func test_data_persistance():
	var dialogue = BonnieManager.new()
	dialogue.load_selected_dialogue_files(["other_file_divert", "divert_to_other_file"])
	var data = dialogue.get_data()
	dialogue.clear_data()
	dialogue.load_data(data)
	assert_eq_deep(["other_file_divert", "divert_to_other_file"], data.internal["accessed_files"])
	assert_eq_deep("divert_to_other_file", data.internal["current_file"])
	assert_eq_deep(true, dialogue.start("other_file_divert.block8", true))
	assert_eq_deep(null, dialogue.get_content())
	assert_eq_deep(30, dialogue.get_variable("@x"))
	assert_eq_deep(54, dialogue.get_variable("other_file_divert.x"))
	assert_eq_deep(7, dialogue.get_variable("divert_to_other_file.x"))
	data = dialogue.get_data()
	dialogue.clear_data()
	dialogue.load_data(data)
	assert_eq_deep(["other_file_divert", "divert_to_other_file"], data.internal["accessed_files"])
	assert_eq_deep("divert_to_other_file", data.internal["current_file"])
	assert_eq_deep(30, dialogue.get_variable("@x"))
	assert_eq_deep(54, dialogue.get_variable("other_file_divert.x"))
	assert_eq_deep(7, dialogue.get_variable("divert_to_other_file.x"))
