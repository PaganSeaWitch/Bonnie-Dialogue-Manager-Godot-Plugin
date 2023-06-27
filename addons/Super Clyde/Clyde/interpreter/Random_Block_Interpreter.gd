class_name RandomBlockInterpreter
extends MiscInterpreter


func set_random_block(check_access : bool = false) -> bool:
	randomize()
	var blocks : Array = _get_visible_blocks()
	blocks.shuffle()


	if(check_access):
		while(!blocks.is_empty()):
			if(interpreter.can_access(blocks.front().block_name)):
				memory.set_as_accessed(blocks.front().block_name)
				stack.initialise_stack(blocks.front())
				return true
			else:
				blocks.pop_front()
		blocks = _get_fallback_blocks()
		if(!blocks.is_empty()):
			blocks.shuffle()
			memory.set_as_accessed(blocks.front().block_name)
			stack.initialise_stack(blocks.front())
			return true
		return false
	else:
		if(blocks.is_empty()):
			blocks = _get_fallback_blocks()
			blocks.shuffle()
		if(blocks.is_empty()):
			return false
		memory.set_as_accessed(blocks.front().block_name)
		stack.initialise_stack(blocks.front())
		return true


func _get_visible_blocks() -> Array:
	return interpreter.anchors.values().filter(_check_if_random_block_not_accessed)


func _get_fallback_blocks() -> Array:
	return interpreter.anchors.values().filter(_check_for_fallback_blocks)

func _check_for_fallback_blocks(block : BlockNode):
	return block is RandomBlockNode && block.mode == 'fallback' 

func _check_if_random_block_not_accessed(block : BlockNode):
	if(block is RandomBlockNode):
		return block.mode != 'fallback' && !(block.mode == 'once' 
		&& memory.was_already_accessed(block.block_name))
	return false
