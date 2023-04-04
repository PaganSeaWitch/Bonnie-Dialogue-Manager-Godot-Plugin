class_name RandomBlockInterpreter
extends MiscInterpreter


func set_random_block() -> bool:
	randomize()
	var blocks : Array = _get_visible_blocks()
	blocks.shuffle()
	if(blocks.is_empty()):
		printerr("failed to find a random block node")
		return false
	var block : RandomBlockNode = blocks.front()
	memory.set_as_accessed(block.block_name)
	stack.initialise_stack(blocks.front())
	return true


func _get_visible_blocks() -> Array:
	return interpreter.anchors.values().filter(_check_if_random_block_not_accessed)


func _check_if_random_block_not_accessed(block : BlockNode):
	return block is RandomBlockNode && !(block.mode == 'once' 
		&& memory.was_already_accessed(block.block_name))
