class_name ClydeInterpreter
extends RefCounted

const DEFAULT_INDEX = -1

signal variable_changed(name, value, previous_value)
signal event_triggered(event_name)

var memory : MemoryInterface
var logic_interpreter : LogicInterpreter = LogicInterpreter.new()
var variations_interpreter : VariationsInterpreter = VariationsInterpreter.new()
var misc_interpreter : MiscInterpreter = MiscInterpreter.new()
var line_interpreter : LineInterpreter = LineInterpreter.new()
var options_interpreter : OptionsInterpreter = OptionsInterpreter.new()
var random_block_interpreter : RandomBlockInterpreter = RandomBlockInterpreter.new()

class Config:
	var id_suffix_lookup_separator : String

var doc : DocumentNode

var stack : InterpreterStack = InterpreterStack.new()

var _handlers = {
		ActionContentNode: logic_interpreter.handle_action_content_node,
		ConditionalContentNode: logic_interpreter.handle_conditional_content_node,
		BlockNode: misc_interpreter.handle_block_node,
		DocumentNode: misc_interpreter.handle_document_node,
		OptionNode: options_interpreter.handle_option_node,
		OptionsNode: options_interpreter.handle_options_node,
		VariationsNode: variations_interpreter.handle_variations_node,
		DivertNode: misc_interpreter.handle_divert_node,
		AssignmentsNode: logic_interpreter.handle_assignments_node,
		LineNode: line_interpreter.handle_line_node,
		EventsNode: logic_interpreter.handle_events_node,
		ContentNode: line_interpreter.handle_content_node }


var anchors = {}
var config : Config = Config.new()


func init(document_dict : Dictionary, interpreter_options :Dictionary = {}) -> void:
	doc = Parser.new().to_node(document_dict) as DocumentNode
	if(doc == null):
		printerr("Failed to load dictionary into nodes")
		return
	doc.node_index = 1
	memory = MemoryInterface.new()
	memory.connect("variable_changed",Callable(self,"_trigger_variable_changed"))


	logic_interpreter.init(self, memory, stack)
	misc_interpreter.init(self, memory, stack)
	variations_interpreter.init(self, memory, stack)
	line_interpreter.init(self,memory, stack)
	options_interpreter.init(self, memory, stack)
	random_block_interpreter.init(self, memory, stack)
	
	config.id_suffix_lookup_separator = interpreter_options.get("id_suffix_lookup_separator", "&")

	_initialise_blocks(doc)
	stack.initialise_stack(doc)


func get_current_node():
	return handle_next_node(stack.stack_head().node)


func select_block(block_name : String = ""):
	#assert(!block_name.is_empty() && anchors.has(block_name),
	#	"Block name was given but no such block exists!")
	if anchors.has(block_name):
		stack.initialise_stack(anchors[block_name])
	else:
		stack.initialise_stack(doc)


func get_variable(name : String):
	return memory.get_variable(name)


func choose(option_index : int):
	options_interpreter.choose(option_index)


func set_random_block() -> bool:
	return random_block_interpreter.set_random_block()


func set_variable(name, value):
	return memory.set_variable(name, value)


func get_data() -> MemoryInterface.InternalMemory:
	return memory.get_all()


func load_data(data : MemoryInterface.InternalMemory) -> void:
	memory.load_data(data)


func clear_data() -> void:
	memory.clear()


func _initialise_blocks(doc : DocumentNode) -> void:
	for i in range(doc.blocks.size()):
		doc.blocks[i].node_index = i + 2
		anchors[doc.blocks[i].block_name] = doc.blocks[i]


func handle_next_node(node : ClydeNode) -> ClydeNode:
	for type in _handlers.keys():
		
		if is_instance_of(node, type):
			return _handlers[type].call(node)
	
	printerr("Unkown node type '%s'" % node.type)
	return null


func _trigger_variable_changed(name, value, previous_value):
	emit_signal("variable_changed", name, value, previous_value)
