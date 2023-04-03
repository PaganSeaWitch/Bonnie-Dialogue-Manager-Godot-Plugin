class_name ClydeInterpreter
extends RefCounted

const DEFAULT_INDEX = -1

signal variable_changed(name, value, previous_value)
signal event_triggered(event_name)

var memory : MemoryInterface
var logicInterpreter : ClydeLogicInterpreter 

class StackElement:
	var node : ClydeNode
	var content_index : int = -1

class Config:
	var id_suffix_lookup_separator : String

var _doc : DocumentNode
var _stack : Array[StackElement] = []
var _handlers = {
		ActionContentNode: Callable(self, "_handle_action_content_node"),
		ConditionalContentNode: Callable(self, "_handle_conditional_content_node"),
		BlockNode: Callable(self, "_handle_block_node"),
		DocumentNode: Callable(self, "_handle_document_node"),
		OptionNode: Callable(self, "_handle_option_node"),
		LineNode: Callable(self, "_handle_line_node"),
		OptionsNode: Callable(self, "_handle_options_node"),
		VariationsNode: Callable(self, "_handle_variations_node"),
		DivertNode: Callable(self, "_handle_divert_node"),
		AssignmentsNode: Callable(self, "_handle_assignments_node"),
		EventsNode: Callable(self, "_handle_events_node"),
		ContentNode: Callable(self, "_handle_content_node"),
	}


var _variation_mode_handlers = {
	Syntax.VARIATIONS_MODE_CYCLE : Callable(self, "_handle_cycle_variation"),
	Syntax.VARIATIONS_MODE_ONCE : Callable(self, "_handle_once_variation"),
	Syntax.VARIATIONS_MODE_SEQUENCE : Callable(self, "_handle_sequence_variation"),
	Syntax.VARIATIONS_MODE_SHUFFLE : Callable(self, "_handle_shuffle_variation"),
	Syntax.VARIATIONS_MODE_SHUFFLE_CYCLE : Callable(self, "_handle_shuffle_variation").bind(Syntax.VARIATIONS_MODE_CYCLE),
	Syntax.VARIATIONS_MODE_SHUFFLE_ONCE : Callable(self, "_handle_shuffle_variation").bind(Syntax.VARIATIONS_MODE_ONCE),
	Syntax.VARIATIONS_MODE_SHUFFLE_SEQUENCE : Callable(self, "_handle_shuffle_variation").bind(Syntax.VARIATIONS_MODE_SEQUENCE),
}


var _anchors = {}
var _config : Config = Config.new()


func init(documentDict : Dictionary, interpreter_options :Dictionary = {}) -> void:
	_doc = Parser.new().to_node(documentDict) as DocumentNode
	_doc.index = 1
	memory = MemoryInterface.new()
	memory.connect("variable_changed",Callable(self,"_trigger_variable_changed"))
	logicInterpreter = ClydeLogicInterpreter.new()
	logicInterpreter.init(memory)

	_config.id_suffix_lookup_separator = interpreter_options.get("id_suffix_lookup_separator", "&")

	_initialise_blocks(_doc)
	_initialise_stack(_doc)



func get_current_node():
	return _handle_next_node(_stack_head().node)


func choose(option_index):
	var head = _stack_head()
	if head.node is OptionsNode:
		var content = _get_visible_options(head.node.content)

		if option_index >= content.size():
			printerr("Index %s not available." % option_index)
			return

		memory.set_as_accessed(content[option_index].index)
		memory.set_internal_variable('OPTIONS_COUNT', _get_visible_options(head.node.content).size())
		content[option_index].index = content[option_index].index;

		if content[option_index] is ActionContentNode:
			content[option_index].content.content.index = content[option_index].content.index
			_handle_action(content[option_index]);
			_add_to_stack(content[option_index].content);
			_add_to_stack(content[option_index].content.content);
		else:
			_add_to_stack(content[option_index])
			var newContent : ContentNode = ContentNode.new()
			newContent.content = content[option_index].content
			_add_to_stack(newContent)
	else:
		printerr("Nothing to select")


func select_block(block_name : String = ""):
	assert(block_name.is_empty() && !_anchors.has(block_name),"Block name was given but no such block exists!")
	if _anchors.has(block_name):
		_initialise_stack(_anchors[block_name])
	else:
		_initialise_stack(_doc)


func get_variable(name):
	return memory.get_variable(name)


func set_variable(name, value):
	return memory.set_variable(name, value)


func get_data():
	return memory.get_all()


func load_data(data):
	return memory.load_data(data)


func clear_data():
	return memory.clear()


func _initialise_stack(root : ClydeNode):
	var element = StackElement.new()
	element.node = root
	_stack.append(element)


func _initialise_blocks(doc : DocumentNode) -> void:
	for i in range(doc.blocks.size()):
		doc.blocks[i].index = i + 2
		_anchors[doc.blocks[i].blockName] = doc.blocks[i]


func _stack_head() -> StackElement:
	return _stack[_stack.size() - 1]


func _stack_pop() -> StackElement:
	return _stack.pop_back()


func _add_to_stack(node : ClydeNode):
	if _stack_head().node != node:
		var element = StackElement.new()
		element.node = node
		_stack.push_back(element)


func _generate_index() -> int:
	return (10 * _stack_head().node.index) + _stack_head().content_index


func _handle_document_node(_node : DocumentNode) -> DialogueNode:
	var currentNode : StackElement = _stack_head()
	return getAllContentNodes(currentNode, _node)


func _handle_content_node(content_node : ContentNode) -> DialogueNode:
	if content_node.index == DEFAULT_INDEX:
		content_node.index = _generate_index()
	_add_to_stack(content_node)

	var currentNode = _stack_head()
	#Get all new nodes
	var node  = getAllContentNodes(currentNode, content_node)
	if(node != null): return node
	_stack_pop()
	return _handle_next_node(_stack_head().node);


func getAllContentNodes(stackElement : StackElement, currentContent : ContentNode) -> DialogueNode:
	var content_index : int = stackElement.content_index + 1
	if content_index < stackElement.node.content.size():
		stackElement.content_index = content_index
		return _handle_next_node(stackElement.node.content[content_index])
	return null


func _handle_line_node(line_node : LineNode) -> LineNode:
	if line_node.index == DEFAULT_INDEX:
		line_node.index = _generate_index()

	line_node.value = _replace_variables(_translate_text(line_node.id, line_node.value, line_node.id_suffixes))
	return line_node
 

func _handle_options_node(options_node : OptionsNode) -> OptionsNode:
	if options_node.index == DEFAULT_INDEX:
		options_node.index = _generate_index()
		memory.set_internal_variable('OPTIONS_COUNT', options_node.content.size())
	_add_to_stack(options_node)

	var options = _get_visible_options(options_node.content)
	memory.set_internal_variable('OPTIONS_COUNT', options.size())

	if options.size() == 0:
		_stack_pop()
		return _handle_next_node(_stack_head().node)

	if options.size() == 1 && options[0].mode == 'fallback':
		choose(0)
		return _handle_next_node(_stack_head().node)
	
	options_node.name = _replace_variables(_translate_text(options_node.id, options_node.name, options_node.id_suffixes))
	options_node.content = options
	return options_node


func _get_visible_options(options : Array) -> Array:
	return options.map(func (e : ClydeNode):
		return _prepare_option(e, options.find(e))
	).filter(_check_if_option_not_accessed)


func _prepare_option(option : ClydeNode, index : int) -> ClydeNode:
	if option.index == DEFAULT_INDEX:
		option.index = _generate_index() * 100 + index

	if option is ConditionalContentNode:
		if(option.content.size() > 0):
			option.content[0].index = option.index;
			if logicInterpreter.check_condition(option.conditions):
				return _prepare_option(option.content[0], index)
		return null

	if option is ActionContentNode:
		if(option.content.size() > 0):
			option.content[0].index = option.index
			option.mode = option.content[0].mode
			return _prepare_option(option.content[0], index)
		return null

	return option;


func _check_if_option_not_accessed(option : ClydeNode):
	return option != null && !(option.mode == 'once' && memory.was_already_accessed(option.index))


func _handle_option_node(_option_node : OptionNode):
	# this is called when the contents inside the option
	# were read. option list default behavior is to quit
	# so we need to remove_at both option and option list from the stack.
	_stack_pop()
	_stack_pop()
	return _handle_next_node(_stack_head().node);


func _handle_action_content_node(action_node : ActionContentNode):
	_handle_action(action_node)
	var content = ContentNode.new()
	content.content = action_node.content
	return _handle_content_node(content)


func _handle_action(action_node : ActionContentNode):
	for action in action_node.action:
		if action is EventsNode:
			for event in action.events:
				emit_signal("event_triggered", event.name)
		if action is AssignmentNode:
			logicInterpreter.handle_assignment(action)
		if action is AssignmentsNode:
			_handle_assignments_node(action)


func _handle_conditional_content_node(conditional_node : ConditionalContentNode, fallback_node = _stack_head().node):
	if logicInterpreter.check_condition(conditional_node.conditions):
		var content = ContentNode.new()
		content.content = conditional_node.content
		return _handle_content_node(content)
	return _handle_next_node(fallback_node)


func _handle_variations_node(variations : VariationsNode, attempt : int = 0):
	if (variations.index == DEFAULT_INDEX):
		variations.index = _generate_index()
		for index in range(variations.content.size()):
			var node : ClydeNode = variations.content[index]
			node.index = _generate_index() * 100 + index

	var next_index : int = _handle_variation_mode(variations)
	if next_index == -1 || attempt > variations.content.size():
		return _handle_next_node(_stack_head().node)

	if variations.content[next_index].content.size() == 1 && is_instance_of(variations.content[next_index].content[0], ConditionalContentNode):
		if !logicInterpreter.check_condition(variations.content[next_index].content[0].conditions):
			return _handle_variations_node(variations, attempt + 1)

	return _handle_next_node(variations.content[next_index]);


func _handle_block_node(block : BlockNode):
	_add_to_stack(block)
	var head : StackElement = _stack_head()
	var content_index : int = head.content_index + 1

	if content_index < head.node.content.size():
		head.content_index = content_index
		var next = head.node.content[content_index]
		return _handle_next_node(head.node.content[content_index]);


func _handle_divert_node(divert : DivertNode):
	if divert.target == '<parent>':
		var target_parents : Array = [DocumentNode, BlockNode, OptionNode, OptionsNode]
		var is_target_parent : bool = false
		while !is_target_parent:
			for target_parent in target_parents:
				is_target_parent = is_instance_of(_stack_head().node, target_parent)
				if(is_target_parent): break
			if(!is_target_parent):
				_stack_pop()

		if _stack.size() > 1:
			_stack_pop()
			return _handle_next_node(_stack_head().node)
	elif divert.target == '<end>':
		_initialise_stack(_doc)
		_stack_head().content_index = _stack_head().node.content.size();
	else:
		return _handle_next_node(_anchors[divert.target])



func _handle_assignments_node(assignments_node : AssignmentsNode):
	for assignment in assignments_node.assignments:
		logicInterpreter.handle_assignment(assignment)



func _handle_events_node(events : EventsNode):
	for event in events.events:
		emit_signal("event_triggered", event.name)

	return _handle_next_node(_stack_head().node);


func _handle_next_node(node : ClydeNode):
	for type in _handlers.keys():
		
		if is_instance_of(node, type):
			return _handlers[type].call(node)
	
	printerr("Unkown node type '%s'" % node.type)


func _translate_text(key : String, text : String, id_suffixes : Array):
	if key.is_empty():
		return text

	if !id_suffixes.is_empty():
		var lookup_key : String = key
		for ids in id_suffixes:
			var value = memory.get_variable(ids)
			if value:
				lookup_key += "%s%s" % [_config.id_suffix_lookup_separator, value]
		var position = tr(lookup_key)

		if position != lookup_key:
			return position

	var position = tr(key)
	if position == key:
		return text
	return position


func _replace_variables(text : String) -> String:
	if text.is_empty():
		return text
	var regex = RegEx.new()
	regex.compile("\\%(?<variable>[A-z0-9]*)\\%")
	for result in regex.search_all(text):
		var value = memory.get_variable(result.get_string("variable"))
		text = text.replace(result.get_string(), value if value else "")

	return text


func _handle_variation_mode(variations : VariationsNode):
	if(_variation_mode_handlers.has(variations.mode)):
		var function : Callable = _variation_mode_handlers.get(variations.mode)
		return function.call(variations)
	printerr("Variation mode '%s' is unknown" % variations.mode)


func _handle_cycle_variation(variations : VariationsNode):
	var current_index : int = memory.get_internal_variable(variations.index, -1);
	if current_index < variations.content.size() - 1:
		current_index += 1;
	else:
		current_index = 0

	memory.set_internal_variable(variations.index, current_index)
	return current_index;


func _handle_once_variation(variations : VariationsNode) -> int:
	var current_index : int = memory.get_internal_variable(variations.index, -1);
	var index : int = current_index + 1;
	if index <= variations.content.size() - 1:
		memory.set_internal_variable(variations.index, index)
		return index

	return DEFAULT_INDEX;


func _handle_sequence_variation(variations : VariationsNode) -> int:
	var current_index : int  = memory.get_internal_variable(variations.index, -1)
	if current_index < variations.content.size() - 1:
		current_index += 1;
		memory.set_internal_variable(variations.index, current_index)

	return current_index;


func _handle_shuffle_variation(variations : VariationsNode, mode : String = 'cycle') -> int:
	var SHUFFLE_VISITED_KEY : String = "%s_shuffle_visited" % variations.index;
	var LAST_VISITED_KEY : String = "%s_last_index" % variations.index;
	var visited_items : Array = memory.get_internal_variable(SHUFFLE_VISITED_KEY, []);
	var remaining_options : Array = []
	for o in variations.content:
		if not visited_items.has(o.index):
			remaining_options.push_back(o)

	if remaining_options.size() == 0:
		if mode == 'once':
			return DEFAULT_INDEX

		if mode == 'cycle':
			memory.set_internal_variable(SHUFFLE_VISITED_KEY, []);
			return _handle_shuffle_variation(variations, mode)
		return memory.get_internal_variable(LAST_VISITED_KEY, -1);

	randomize()
	var random = randi() % remaining_options.size()
	var index = variations.content.find(remaining_options[random]);

	visited_items.push_back(remaining_options[random].index);

	memory.set_internal_variable(LAST_VISITED_KEY, index);
	memory.set_internal_variable(SHUFFLE_VISITED_KEY, visited_items);

	return index;


func _trigger_variable_changed(name, value, previous_value):
	emit_signal("variable_changed", name, value, previous_value)
