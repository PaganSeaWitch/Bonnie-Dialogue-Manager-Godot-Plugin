class_name BonnieInterpreter
extends IBonnieInterpreter


func select_block(block_name : String = "", check_access : bool = false) -> bool:
	return super(block_name, check_access)


func get_variable(name : String):
	return memory.get_variable(name)


func set_random_block(check_access : bool = false) -> bool:
	return random_block_interpreter.set_random_block(check_access)

func get_block_from_anchor(block_name : String) -> BonnieNode:
	if(anchors.has(block_name)):
		return anchors.get(block_name)
	return super(block_name)

 
func set_variable(name, value):
	return memory.set_variable(name, value)


func clear_data() -> void:
	memory.clear()


func _initialise_blocks(doc : DocumentNode) -> void:
	super(doc)
