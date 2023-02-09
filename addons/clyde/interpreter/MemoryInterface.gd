class_name MemoryInterface
extends RefCounted

# signal to emit when a variable has changed
signal variable_changed(name, value, previous_value)

const SPECIAL_VARIABLE_NAMES = [ 'OPTIONS_COUNT' ];

var internalMemory : InternalMemory = InternalMemory.new()



#sets the id for a block in access as a key for true
#This will be used to check for whether it has already been accessed
func set_as_accessed(id):
	internalMemory.access[str(id)] = true


#Checks whether the access dict has corrosponding id
func was_already_accessed(id):
	return internalMemory.access.has(str(id))


#Gets a variable from corrosponding id
func get_variable(id, default_value = null):
	#Checks if this is internal
	var value;
	if SPECIAL_VARIABLE_NAMES.has(id):
		value = get_internal_variable(id, default_value);
	else:
		value = internalMemory.variables.get(id);
	
	if (value == null):
		return default_value;
	return value;


#sets a variable based on its id to a value
func set_variable(id, value):
	variable_changed.emit(id, value, internalMemory.variables.get(id))
	internalMemory.variables[id] = value
	return value


#sets a internal variable based on its id to a value
func set_internal_variable(id, value):
	internalMemory.internal[str(id)] = value
	return value


#gets an internal value, if null return a default value
func get_internal_variable(id, default_value):
	return internalMemory.internal.get(str(id));


#Returns memory object
func get_all():
	return internalMemory


#Sets data as memory object
func load_data(data):
	internalMemory = data


#Resets memory object
func clear():
	internalMemory = InternalMemory.new()
