@tool
extends EditorPlugin


const DialogueSettings = preload("res://addons/Bonnie/components/settings.gd") 
const MainView = preload("res://addons/Bonnie/view/main_view.tscn")
const SETTING_SOURCE_FOLDER := "dialogue/source_folder"
const DEFAULT_SOURCE_FOLDER := "res://dialogues/"

const SETTING_ID_SUFFIX_LOOKUP_SEPARATOR := "dialogue/id_suffix_lookup_separator"
const DEFAULT_ID_SUFFIX_LOOKUP_SEPARATOR := "&"

const ImportPlugin = preload("import_plugin.gd")

var _import_plugin
var main_view 
var dialogue_file_cache: Dictionary = {}


func _enter_tree():
	if Engine.is_editor_hint():
		_import_plugin = ImportPlugin.new()
		add_import_plugin(_import_plugin)
		_setup_project_settings()

		DialogueSettings.prepare()
		#translation_parser_plugin = DialogueTranslationParserPlugin.new()
		#add_translation_parser_plugin(translation_parser_plugin)
			
		main_view = MainView.instantiate()
		main_view.editor_plugin = self
		get_editor_interface().get_editor_main_screen().add_child(main_view)
		_make_visible(false)
			
		update_dialogue_file_cache()
		get_editor_interface().get_resource_filesystem().filesystem_changed.connect(_on_filesystem_changed)
		get_editor_interface().get_file_system_dock().files_moved.connect(_on_files_moved)
		get_editor_interface().get_file_system_dock().file_removed.connect(_on_file_removed)


func _exit_tree():
	if is_instance_valid(main_view):
		main_view.queue_free()

func _get_plugin_name() -> String:
	return "Bonnie"

func _disable_plugin():
	remove_import_plugin(_import_plugin)
	_import_plugin = null
	_clear_project_settings()


func _has_main_screen() -> bool:
	return true


func _get_plugin_icon() -> Texture2D:
	return load("res://addons/Bonnie/assets/icon.svg")


func _setup_project_settings():
	if not ProjectSettings.has_setting(SETTING_SOURCE_FOLDER):
		ProjectSettings.set(SETTING_SOURCE_FOLDER, DEFAULT_SOURCE_FOLDER)
		ProjectSettings.set_initial_value(SETTING_SOURCE_FOLDER, DEFAULT_SOURCE_FOLDER)
		ProjectSettings.add_property_info({
			"name": SETTING_SOURCE_FOLDER,
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_DIR,
		})

	if not ProjectSettings.has_setting(SETTING_ID_SUFFIX_LOOKUP_SEPARATOR):
		ProjectSettings.set(SETTING_ID_SUFFIX_LOOKUP_SEPARATOR, DEFAULT_ID_SUFFIX_LOOKUP_SEPARATOR)
		ProjectSettings.set_initial_value(SETTING_ID_SUFFIX_LOOKUP_SEPARATOR, DEFAULT_ID_SUFFIX_LOOKUP_SEPARATOR)
		ProjectSettings.add_property_info({
			"name": SETTING_ID_SUFFIX_LOOKUP_SEPARATOR,
			"type": TYPE_STRING,
		})

	ProjectSettings.save()


func _on_filesystem_changed() -> void:
	update_dialogue_file_cache()

func update_import_paths(from_path: String, to_path: String) -> void:
	# Update its own reference in the cache
	if dialogue_file_cache.has(from_path):
		dialogue_file_cache[to_path] = dialogue_file_cache[from_path].duplicate()
		dialogue_file_cache.erase(from_path)
	
	# Reopen the file if it's already open
	if main_view.current_file_path == from_path:
		main_view.current_file_path = ""
		main_view.open_file(to_path)
	
	# Update any other files that import the moved file
	var dependents = dialogue_file_cache.values().filter(func(d): return from_path in d.dependencies)
	for dependent in dependents:
		dependent.dependencies.erase(from_path)
		dependent.dependencies.append(to_path)
		
		# Update the live buffer
		if main_view.current_file_path == dependent.path:
			main_view.code_edit.text = main_view.code_edit.text.replace(from_path, to_path)
			main_view.pristine_text = main_view.code_edit.text

		# Open the file and update the path
		var file: FileAccess = FileAccess.open(dependent.path, FileAccess.READ)
		var text = file.get_as_text().replace(from_path, to_path)
		
		file = FileAccess.open(dependent.path, FileAccess.WRITE)
		file.store_string(text)
	
	save_dialogue_cache()

func _on_files_moved(old_file: String, new_file: String) -> void:
	update_import_paths(old_file, new_file)
	DialogueSettings.move_recent_file(old_file, new_file)


func _on_file_removed(file: String) -> void:
	recompile_dependent_files(file)
	if is_instance_valid(main_view):
		main_view.close_file(file)

## Persist the cache
func save_dialogue_cache() -> void:
	var file: FileAccess = FileAccess.open(Syntax.CACHE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(dialogue_file_cache))


## Rebuild any files that depend on this path
func recompile_dependent_files(path: String) -> void:
	# Rebuild any files that depend on this one
	var dependents = dialogue_file_cache.values().filter(func(d): return path in d.dependencies)
	for dependent in dependents:
		if dependent.has("path") and dependent.has("resource_path"):
			_import_plugin.compile_file(dependent.path, dependent.resource_path, false)


func update_dialogue_file_cache() -> void:
	var cache: Dictionary = {}
	
	# Open our cache file if it exists
	if FileAccess.file_exists(Syntax.CACHE_PATH):
		var file: FileAccess = FileAccess.open(Syntax.CACHE_PATH, FileAccess.READ)
		cache = JSON.parse_string(file.get_as_text())
	
	# Scan for dialogue files
	var current_files: PackedStringArray = _get_dialogue_files_in_filesystem()
	
	# Add any files to POT generation
	var files_for_pot: PackedStringArray = ProjectSettings.get_setting("internationalization/locale/translations_pot_files", [])
	var files_for_pot_changed: bool = false
	for path in current_files:
		if not files_for_pot.has(path):
			files_for_pot.append(path)
			files_for_pot_changed = true
	
	# Remove any files that don't exist any more
	for path in cache.keys():
		if not path in current_files:
			cache.erase(path)
			DialogueSettings.remove_recent_file(path)
			
			# Remove missing files from POT generation
			if files_for_pot.has(path):
				files_for_pot.remove_at(files_for_pot.find(path))
				files_for_pot_changed = true
	
	# Update project settings if POT changed
	if files_for_pot_changed:
		ProjectSettings.set_setting("internationalization/locale/translations_pot_files", files_for_pot)
		ProjectSettings.save()
	
	dialogue_file_cache = cache


func _make_visible(next_visible: bool) -> void:
	if is_instance_valid(main_view):
		main_view.visible = next_visible

func _clear_project_settings():
	ProjectSettings.clear(SETTING_SOURCE_FOLDER)
	ProjectSettings.clear(SETTING_ID_SUFFIX_LOOKUP_SEPARATOR)
	ProjectSettings.save()

func _edit(object) -> void:
	if is_instance_valid(main_view) and is_instance_valid(object):
		main_view.open_resource(object)


func _apply_changes() -> void:
	if is_instance_valid(main_view):
		main_view.apply_changes()


func _get_dialogue_files_in_filesystem(path: String = "res://") -> PackedStringArray:
	var files: PackedStringArray = []
	
	if DirAccess.dir_exists_absolute(path):
		var dir = DirAccess.open(path)
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var file_path: String = (path + "/" + file_name).simplify_path()
			if dir.current_is_dir():
				if not file_name in [".godot", ".tmp"]:
					files.append_array(_get_dialogue_files_in_filesystem(file_path))
			elif file_name.get_extension() == "bonnie":
				files.append(file_path)
			file_name = dir.get_next()
	
	return files

