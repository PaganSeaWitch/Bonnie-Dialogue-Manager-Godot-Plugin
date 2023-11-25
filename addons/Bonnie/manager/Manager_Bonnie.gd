class_name BonnieManager
extends IBonnie


var accessed_files : Array[String] = []

func _init():
	_interpreter = BonnieManagerInterpreter.new()


func load_dialogue(file_name : String, block  : String= "", check_access :bool = false) -> void:
	var file_name_without_anything = file_name.replace(".bonnie", "")
	var new_file_name = ""
	for i in range(file_name_without_anything.length()-1,-1, -1):
		if(file_name_without_anything[i] == "/"):
			break
		new_file_name =  file_name_without_anything[i] + new_file_name
	_interpreter.current_file = new_file_name
	
	if(!accessed_files.has(new_file_name)):
		accessed_files.append(new_file_name)
	super(file_name,block,check_access)


func load_selected_dialogue_files(files : Array[String]) -> void:
	for file in files:
		load_dialogue(file)


## Return all variables and internal variables. Useful for persisting the dialogue's internal
## data, such as options already choosen and random variations states.
func get_data() -> MemoryInterface.ClydeInternalMemory:
	var data = super()
	data.internal["accessed_files"] = accessed_files
	return data


## Load internal data
func load_data(data : MemoryInterface.ClydeInternalMemory) -> void:
	if(data.internal.has("accessed_files")):
		accessed_files = data.internal["accessed_files"]
	_interpreter.load_data(data)



func load_dialogue_files_in_directory(directory_path : String = dialogue_folder) -> void:
	var path = _get_source_folder(directory_path)
	var files = []
	var dir = DirAccess.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		if(file.get_extension() == "bonnie"):
			load_dialogue(file)

	dir.list_dir_end()
