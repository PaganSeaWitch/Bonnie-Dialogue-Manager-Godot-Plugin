@tool
extends EditorImportPlugin


func _get_importer_name():
	return "clyde.dialogue"


func _get_visible_name():
	return "Clyde Dialogue Importer"


func _get_recognized_extensions():
	return ["clyde"]


func _get_save_extension():
	return "res"


func _get_resource_type():
	return "PackedDataContainer"



func _get_preset_count():
	return 1


func _get_preset_name(i):
	return "Default"


func _get_import_options(str: String, i : int):
	return []


func _get_option_visibility(option :String,optionName : StringName,  options : Dictionary):
	return true
func _get_import_order():
	return 0

func _import(source_file, save_path, options, platform_variants, gen_files):
	var file : FileAccess = FileAccess.open(source_file, FileAccess.READ)
	var clyde = file.get_as_text()
	print(clyde)
	var parser = Parser.new()
	var result = parser.parse(clyde)

	var container = PackedDataContainer.new()
	print(JSON.stringify(parser.to_JSON_object(result)))
	container.__data__ = JSON.stringify(parser.to_JSON_object(result)).to_utf8_buffer()

	return ResourceSaver.save(container,"%s.%s" % [save_path, _get_save_extension()])

