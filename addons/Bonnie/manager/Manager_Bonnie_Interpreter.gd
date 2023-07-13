class_name BonnieManagerInterpreter
extends IBonnieInterpreter

var current_file : String = ""


func init(document_dict : Dictionary, interpreter_options :Dictionary = {}) -> void:
	if(memory == null):
		super(document_dict,interpreter_options)
	else:
		doc = BonnieParser.new().to_node(document_dict) as DocumentNode
		current_file = doc.document_name
		if(doc == null):
			printerr("Failed to load dictionary into nodes")
			return
		_initialise_blocks(doc)
		stack.initialise_stack(doc)


func get_current_node():
	var node = super()
	if(node == null):
		current_file = doc.document_name
	return node


func select_block(block_name : String = "", check_access : bool = false) -> bool:
	if(block_name.contains(".")):
		if(!check_access):
			if anchors.has(block_name):
				memory.set_as_accessed(block_name)
				stack.initialise_stack(anchors[block_name])
				if(!block_name.begins_with(".")):
					current_file = block_name.split(".", false)[0]
			else:
				stack.initialise_stack(doc)
			return true
		else:
			if anchors.has(block_name) && can_access(block_name):
				memory.set_as_accessed(block_name)
				stack.initialise_stack(anchors[block_name])
				if(!block_name.begins_with(".")):
					current_file = block_name.split(".", false)[0]
				return true
			else:
				stack.initialise_stack(doc)
			return false
	else:
		return select_block(current_file + "." + block_name, check_access)


func get_block_from_anchor(block_name : String) -> BonnieNode:
	if(block_name.contains(".")):
		if(anchors.has(block_name)):
			return anchors.get(block_name)
	else:
		block_name = current_file + "." + block_name
		if(anchors.has(block_name)):
			return anchors.get(block_name)
	return super(block_name)


func can_access(block_name : String) -> bool:
	var block : BlockNode = anchors[block_name]
	var block_reqs = true
	for name in block.block_requirements:
		block_reqs = block_reqs && memory.was_already_accessed(name)
	for name in block.block_not_requirements:
		block_reqs = block_reqs && !memory.was_already_accessed(name)
	for condition in block.conditions:
		block_reqs = block_reqs && logic_interpreter.check_condition(condition)
	return block_reqs


func get_variable(name : String):
	if(name.begins_with("@") || name.contains(".")):
		return memory.get_variable(name)
	
	return memory.get_variable(current_file + "." +name)


func set_random_block(check_access : bool = false) -> bool:
	return random_block_interpreter.set_random_block(check_access)


func set_variable(name, value):
	if(name.begins_with("@") || name.contains(".")):
		return memory.set_variable(name, value)
	return memory.set_variable(current_file + "." +name, value)


func clear_data() -> void:
	memory.clear()


func get_data() -> MemoryInterface.ClydeInternalMemory:
	var data = super()
	data.internal["current_file"] = current_file
	return data


func load_data(data : MemoryInterface.ClydeInternalMemory) -> void:
	if(data.internal.has("current_file")):
		current_file = data.internal["current_file"]
	super(data)


func _initialise_blocks(doc : DocumentNode) -> void:
	for i in range(doc.blocks.size()):
		doc.blocks[i].node_index = i + 2
		var block = doc.blocks[i]
		for j in range(block.block_requirements.size()):
			var name : String = block.block_requirements[j]
			if(!name.contains(".")):
				block.block_requirements[j] = current_file + "." + name
		for j in range(block.block_not_requirements.size()):
			var name : String = block.block_not_requirements[j]
			if(!name.contains(".")):
				block.block_not_requirements[j] = current_file + "." + name
				
		anchors[current_file+"." + doc.blocks[i].block_name] = block
