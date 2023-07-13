class_name RandomBlockInterpreter
extends MiscInterpreter


func set_random_block(check_access : bool = false) -> bool:
	randomize()
	var blocks : Array = _get_visible_blocks()
	blocks.shuffle()


	if(check_access):
		while(!blocks.is_empty()):
			if(interpreter.can_access(blocks.front())):
				memory.set_as_accessed(blocks.front())
				if(!blocks.front().begins_with(".") && interpreter is BonnieManagerInterpreter):
					interpreter.current_file = blocks.front().split(".", false)[0]
				stack.initialise_stack(interpreter.anchors.get(blocks.front()))
				return true
			else:
				blocks.pop_front()
		blocks = _get_fallback_blocks()
		if(!blocks.is_empty()):
			blocks.shuffle()
			memory.set_as_accessed(blocks.front())
			stack.initialise_stack(interpreter.anchors.get(blocks.front()))
			if(!blocks.front().begins_with(".") && interpreter is BonnieManagerInterpreter):
				interpreter.current_file = blocks.front().split(".", false)[0]
			return true
		return false
	else:
		if(blocks.is_empty()):
			blocks = _get_fallback_blocks()
			blocks.shuffle()
		if(blocks.is_empty()):
			return false
		memory.set_as_accessed(blocks.front())
		stack.initialise_stack(interpreter.anchors.get(blocks.front()))
		if(!blocks.front().begins_with(".")):
			interpreter.current_file = blocks.front().split(".", false)[0]
		return true


func _get_visible_blocks() -> Array:
	return interpreter.anchors.keys().filter(_check_if_random_block_not_accessed)


func _get_fallback_blocks() -> Array:
	return interpreter.anchors.keys().filter(_check_for_fallback_blocks)


func _check_for_fallback_blocks(block_name : String):
	var block : BlockNode = interpreter.anchors.get(block_name)
	return block is RandomBlockNode && block.mode == 'fallback' 


func _check_if_random_block_not_accessed(block_name : String):
	var block : BlockNode = interpreter.anchors.get(block_name)
	if(block is RandomBlockNode):
		return block.mode != 'fallback' && !(block.mode == 'once' 
		&& memory.was_already_accessed(block_name))
	return false
