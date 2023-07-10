extends GutTestFunctions


const SAMPLES_FOLDER = "res://test/dialogue_samples/"


func test_samples():
	var files = []
	var dir = DirAccess.open(SAMPLES_FOLDER)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break

		if file.ends_with(".bonnie"):
			files.append(file)

	dir.list_dir_end()

	for file_name in files:
		var result_filename = file_name.replace('.bonnie', '.json')
		var source_file : FileAccess = FileAccess.open("%s%s" % [ SAMPLES_FOLDER, file_name ], 
			FileAccess.READ)

		var source = source_file.get_as_text()
		source_file.close()

		var result_file : FileAccess = FileAccess.open("%s%s" % [ SAMPLES_FOLDER, result_filename ],
			FileAccess.READ)

		var result = result_file.get_as_text()
		var pased = _parse(source, true)
		expect(pased, JSON.parse_string(result))
		pass_test("passed")


func expect(received, expected):
	if typeof(expected) == TYPE_ARRAY:
		expect_assert(received != null && received.size() == expected.size(), "'%s' is not equal to '%s" % [ received, expected ])
		for index in range(expected.size()):
			expect(received[index], expected[index])
	elif typeof(received) == TYPE_DICTIONARY:
		for key in expected:
			expect(received[key], expected[key])
	else:
		expect_assert(received == expected, "'%s' is not equal to '%s" % [ received, expected ])


func is_in_array(array, element):
	expect_assert(array.has(element), '%s is not in array' % element)


func expect_assert(assertion_result, message):
	if not assertion_result:
		printerr("%s: test failed: %s" % [self.name, message])
		return false
	return true

