class_name MemoryInterface
extends RefCounted


class ClydeInternalMemory:
	var access    : Dictionary = {}
	var	variables : Dictionary =  {}
	var	internal  : Dictionary = {}

# Signal to emit when a variable has changed
signal variable_changed(name, value, previous_value)

const SPECIAL_VARIABLE_NAMES : Array[String]= [ 'OPTIONS_COUNT' ];

var clyde_internal_memory : ClydeInternalMemory = ClydeInternalMemory.new()


# Sets the id for a block in access as a key for true
# This will be used to check for whether it has already been accessed
func set_as_accessed(id) -> void:
	clyde_internal_memory.access[str(id)] = true


# Checks whether the access dict has corrosponding id
func was_already_accessed(id) -> bool:
	return clyde_internal_memory.access.has(str(id))


# Gets a variable from corrosponding id
func get_variable(id, default_value = null):
	#Checks if this is internal
	var value;
	if SPECIAL_VARIABLE_NAMES.has(id):
		value = get_internal_variable(id, default_value);
	else:
		value = clyde_internal_memory.variables.get(id);
	
	if (value == null):
		return default_value;
	return value;


# Sets a variable based on its id to a value
func set_variable(id, value):
	variable_changed.emit(id, value, clyde_internal_memory.variables.get(id))
	clyde_internal_memory.variables[id] = value
	return value


# Sets a internal variable based on its id to a value
func set_internal_variable(id, value):
	clyde_internal_memory.internal[str(id)] = value
	return value


# Gets an internal value, if null return a default value
func get_internal_variable(id, default_value):
	return (clyde_internal_memory.internal.get(str(id)) 
		if clyde_internal_memory.internal.get(str(id)) != null else default_value)


# Returns memory object
func get_all() -> ClydeInternalMemory:
	return clyde_internal_memory


# Sets data as memory object
func load_data(data : ClydeInternalMemory) -> void:
	clyde_internal_memory = data


# Resets memory object
func clear() -> void:
	clyde_internal_memory = ClydeInternalMemory.new()
