class_name IBonnieInterpreter
extends RefCounted


const DEFAULT_INDEX = -1

signal variable_changed(name, value, previous_value)
signal event_triggered(event_name)

var memory : MemoryInterface
var logic_interpreter : LogicInterpreter 
var variations_interpreter : VariationsInterpreter 
var misc_interpreter : MiscInterpreter 
var line_interpreter : LineInterpreter 
var options_interpreter : OptionsInterpreter 
var random_block_interpreter : RandomBlockInterpreter
var dependent_interpreter : DependentInterpreter 

class Config:
	var id_suffix_lookup_separator : String

var doc : DocumentNode

var stack : InterpreterStack 

var anchors = {}
var config : Config 


func init(document_dict : Dictionary, interpreter_options :Dictionary = {}) -> void:
	doc = BonnieParser.new().to_node(document_dict) as DocumentNode
	if(doc == null):
		printerr("Failed to load dictionary into nodes")
		return
	doc.node_index = 1
	memory = MemoryInterface.new()
	memory.connect("variable_changed",Callable(self,"_trigger_variable_changed"))
	stack = InterpreterStack.new()
	config = Config.new()
	logic_interpreter = LogicInterpreter.new()
	variations_interpreter = VariationsInterpreter.new()
	misc_interpreter = MiscInterpreter.new()
	line_interpreter = LineInterpreter.new()
	options_interpreter = OptionsInterpreter.new()
	random_block_interpreter = RandomBlockInterpreter.new()
	dependent_interpreter = DependentInterpreter.new()
	logic_interpreter.init(self, memory, stack)
	misc_interpreter.init(self, memory, stack)
	variations_interpreter.init(self, memory, stack)
	line_interpreter.init(self,memory, stack)
	options_interpreter.init(self, memory, stack)
	random_block_interpreter.init(self, memory, stack)
	dependent_interpreter.init(self,memory, stack)
	config.id_suffix_lookup_separator = interpreter_options.get("id_suffix_lookup_separator", "&")

	_initialise_blocks(doc)
	stack.initialise_stack(doc)


func get_current_node():
	return handle_next_node(stack.stack_head().node)


func select_block(block_name : String = "", check_access : bool = false) -> bool:
	#assert(!block_name.is_empty() && anchors.has(block_name),
	#	"Block name was given but no such block exists!")
	if(!check_access):
		if anchors.has(block_name):
			memory.set_as_accessed(block_name)
			stack.initialise_stack(anchors[block_name])
		else:
			stack.initialise_stack(doc)
		return true
	else:
		if anchors.has(block_name) && can_access(block_name):
			memory.set_as_accessed(block_name)
			stack.initialise_stack(anchors[block_name])
			return true
		else:
			stack.initialise_stack(doc)
		return false


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
	return memory.get_variable(name)


func choose(option_index : int):
	options_interpreter.choose(option_index)


func set_random_block(check_access : bool = false) -> bool:
	return random_block_interpreter.set_random_block(check_access)


func set_variable(name, value):
	return memory.set_variable(name, value)


func get_data() -> MemoryInterface.ClydeInternalMemory:
	return memory.get_all()


func load_data(data : MemoryInterface.ClydeInternalMemory) -> void:
	memory.load_data(data)


func get_block_from_anchor(block_name : String) -> BonnieNode:
	assert(false, "failed to find block!")
	return null


func clear_data() -> void:
	memory.clear()


func _initialise_blocks(doc : DocumentNode) -> void:
	for i in range(doc.blocks.size()):
		doc.blocks[i].node_index = i + 2
		anchors[doc.blocks[i].block_name] = doc.blocks[i]


func handle_next_node(node : BonnieNode) -> BonnieNode:
	var handlers = {
		"ActionContentNode": logic_interpreter.handle_action_content_node,
		"AssignmentsNode": logic_interpreter.handle_assignments_node,
		"BlockNode": misc_interpreter.handle_block_node,
		"ConditionalContentNode": logic_interpreter.handle_conditional_content_node,
		"ContentNode": line_interpreter.handle_content_node,
		"DocumentNode": misc_interpreter.handle_document_node,
		"DivertNode": misc_interpreter.handle_divert_node,
		"EventsNode": logic_interpreter.handle_events_node,
		"LineNode": line_interpreter.handle_line_node,
		"OptionNode": options_interpreter.handle_option_node,
		"OptionsNode": options_interpreter.handle_options_node,
		"VariationsNode": variations_interpreter.handle_variations_node,
		"LinePartNode": dependent_interpreter.handle_line_part_node,
		"RandomBlockNode":misc_interpreter.handle_block_node
	}
	if handlers.has(node.get_node_class()):
		return handlers[node.get_node_class()].call(node)
	
	printerr("Unkown node type '%s'" % node.type)
	return null


func _trigger_variable_changed(name, value, previous_value):
	emit_signal("variable_changed", name, value, previous_value)
