class_name IBonnie
extends RefCounted
## A Dialogue Manager for Bonnie Dialogue Language files. 
##
## @tutorial(Bonnie Language Docs):            https://github.com/PaganSeaWitch/Bonnie-Dialogue-Manager-Godot-Plugin/blob/4.1/LANGUAGE.md


## This signal fires whenever variable is changed in the bonnie file
signal variable_changed(name, value, previous_value)

## this signal fires whenever a event is triggered in the bonnie file
signal event_triggered(name)

## Custom folder where the interpreter should look for dialogue files
## in case just the name is provided.
## by default, it loads from ProjectSettings dialogue/source_folder
var dialogue_folder : String = ""

var _interpreter : IBonnieInterpreter

## Load dialogue file
## file_name: path to the dialogue file.
##            i.e 'my_dialogue', 'res://my_dialogue.bonnie', res://my_dialogue.json
## block: block name to run. This allows keeping
##        multiple dialogues in the same file.
## check_access: when true, will check whether the requirements for accessing this block are met before allowing access
func load_dialogue(file_name : String, block  : String= "", check_access :bool = false) -> void:
	var fileDict : Dictionary = _load_file(_get_file_path(file_name))
	_interpreter.init(fileDict, {
		"id_suffix_lookup_separator": _config_id_suffix_lookup_separator(),
	})
	if(!_interpreter.is_connected("variable_changed",Callable(self,"_trigger_variable_changed"))):
		_interpreter.connect("variable_changed",Callable(self,"_trigger_variable_changed"))
		_interpreter.connect("event_triggered",Callable(self,"_trigger_event_triggered"))
	if !block.is_empty():
		_interpreter.select_block(block,check_access)


## Start or restart dialogue. Variables are not reset.
## block_name: when set, will try to select the specific block name otherwise will default to top of file
## check_access: when true, will check whether the requirements for accessing this block are met before allowing access
func start(block_name : String = "", check_access : bool = false) -> bool:
	return _interpreter.select_block(block_name, check_access)


## Get next dialogue content.
## The content may be a line, options or null.
## If null, it means the dialogue reached an end.
func get_content() -> BonnieNode:
	return _interpreter.get_current_node()


## Choose one of the available options by index.
func choose(option_index : int) -> Bonnie:
	return _interpreter.choose(option_index)


## Set variable to be used in the dialogue
func set_variable(name : String, value):
	_interpreter.set_variable(name, value)


## Get current value of a variable inside the dialogue.
## name: variable name
func get_variable(name : String):
	return _interpreter.get_variable(name)

## Sets a random block as the starting block if one is avaliable 
## check_access: when true, will check whether the requirements for accessing this block are met before allowing access
func set_random_block(check_access : bool = false) -> bool:
	return _interpreter.set_random_block(check_access)


## Return all variables and internal variables. Useful for persisting the dialogue's internal
## data, such as options already choosen and random variations states.
func get_data() -> MemoryInterface.ClydeInternalMemory:
	return _interpreter.get_data()


## Load internal data
func load_data(data : MemoryInterface.ClydeInternalMemory) -> void:
	_interpreter.load_data(data)


## Clear all internal data
func clear_data() -> void:
	_interpreter.clear_data()


func _load_file(path : String) -> Dictionary:
	if path.get_extension() == 'bonnie':
		return _load_clyde_file(path)


	var f : FileAccess = FileAccess.open(path, FileAccess.READ)
	var test_json_conv = JSON.new()
	test_json_conv.parse(f.get_as_text())
	var result := test_json_conv.get_data()
	f.close()
	if result.error:
		printerr("Failed to parse file: ", f.get_error())
		return {}

	return result.result as Dictionary


func _load_clyde_file(path : String) -> Dictionary:
	var data = load(path).__data__.get_string_from_utf8()
	var test_json_conv = JSON.new()
	var error : Error = test_json_conv.parse(data)

	var parsed_json : Dictionary = test_json_conv.get_data()
	if error != OK:
		var format : Array= [parsed_json.error_line, parsed_json.error_string]
		var error_string : String = "%d: %s" % format
		printerr("Could not parse json", error_string)
		return {}


	return parsed_json


func _trigger_variable_changed(name, value, previous_value):
	emit_signal("variable_changed", name, value, previous_value)


func _trigger_event_triggered(name) -> void:
	emit_signal("event_triggered", name)


func _get_file_path(file_name : String) -> String:
	var p : String = file_name
	var extension : String= file_name.get_extension()

	if extension.is_empty():
		p = "%s.bonnie" % file_name

	if p.begins_with('./') || p.begins_with('res://'):
		return p

	return _get_source_folder().path_join(p)


func _get_source_folder(folder_path : String = dialogue_folder) -> String:
	var cfg_folder = (ProjectSettings.get_setting("dialogue/source_folder") 
		if ProjectSettings.has_setting("dialogue/source_folder") else "")
	var folder = folder_path if !folder_path.is_empty() else cfg_folder
	# https://github.com/godotengine/godot/issues/56598
	return folder if folder else "res://dialogues/"


func _config_id_suffix_lookup_separator() -> String:
	var lookup_separator = (ProjectSettings.get_setting("dialogue/id_suffix_lookup_separator") 
		if ProjectSettings.has_setting("dialogue/id_suffix_lookup_separator") else "")
	return lookup_separator if !lookup_separator.is_empty() else "&"
