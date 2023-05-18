class_name VariationsInterpreter
extends MiscInterpreter


var _variation_mode_handlers = {
	Syntax.VARIATIONS_MODE_CYCLE : Callable(self, "_handle_cycle_variation"),
	Syntax.VARIATIONS_MODE_ONCE : Callable(self, "_handle_once_variation"),
	Syntax.VARIATIONS_MODE_SEQUENCE : Callable(self, "_handle_sequence_variation"),
	Syntax.VARIATIONS_MODE_SHUFFLE : Callable(self, "_handle_shuffle_variation"),
	Syntax.VARIATIONS_MODE_SHUFFLE_CYCLE : 
		Callable(self, "_handle_shuffle_variation").bind(Syntax.VARIATIONS_MODE_CYCLE),
	Syntax.VARIATIONS_MODE_SHUFFLE_ONCE : 
		Callable(self, "_handle_shuffle_variation").bind(Syntax.VARIATIONS_MODE_ONCE),
	Syntax.VARIATIONS_MODE_SHUFFLE_SEQUENCE : 
		Callable(self, "_handle_shuffle_variation").bind(Syntax.VARIATIONS_MODE_SEQUENCE)}


func handle_variations_node(variations : VariationsNode, attempt : int = 0):
	if (variations.node_index == ClydeInterpreter.DEFAULT_INDEX):
		variations.node_index = stack.generate_index()
		for node_index in range(variations.content.size()):
			var node_array : Array = variations.content[node_index]
			for node in node_array:
				node.node_index = stack.generate_index() * 100 + node_index

	var next_index : int = _handle_variation_mode(variations)
	if next_index == -1 || attempt > variations.content.size():
		return interpreter.handle_next_node(stack.stack_head().node)

	var next_array = variations.content[next_index]
	
	if (next_array.size() == 1 
	&& is_instance_of(next_array[0], ConditionalContentNode)):
		if !interpreter.logic_interpreter.check_condition(next_array[0].conditions):
			return handle_variations_node(variations, attempt + 1)
	var content_node = ContentNode.new()
	content_node.content = next_array
	return interpreter.handle_next_node(content_node);


func _handle_variation_mode(variations : VariationsNode):
	if(_variation_mode_handlers.has(variations.mode)):
		var function : Callable = _variation_mode_handlers.get(variations.mode)
		return function.call(variations)
	printerr("Variation mode '%s' is unknown" % variations.mode)


func _handle_cycle_variation(variations : VariationsNode):
	var current_index : int = memory.get_internal_variable(variations.node_index, -1);
	if current_index < variations.content.size() - 1:
		current_index += 1;
	else:
		current_index = 0

	memory.set_internal_variable(variations.node_index, current_index)
	return current_index;


func _handle_once_variation(variations : VariationsNode) -> int:
	var current_index : int = memory.get_internal_variable(variations.node_index, -1);
	var node_index : int = current_index + 1;
	if node_index <= variations.content.size() - 1:
		memory.set_internal_variable(variations.node_index, node_index)
		return node_index

	return ClydeInterpreter.DEFAULT_INDEX;


func _handle_sequence_variation(variations : VariationsNode) -> int:
	var current_index : int  = memory.get_internal_variable(variations.node_index, -1)
	if current_index < variations.content.size() - 1:
		current_index += 1;
		memory.set_internal_variable(variations.node_index, current_index)

	return current_index;


func _handle_shuffle_variation(variations : VariationsNode, mode : String = 'cycle') -> int:
	var SHUFFLE_VISITED_KEY : String = "%s_shuffle_visited" % variations.node_index;
	var LAST_VISITED_KEY : String = "%s_last_index" % variations.node_index;
	var visited_items : Array = memory.get_internal_variable(SHUFFLE_VISITED_KEY, []);
	var remaining_options : Array = []
	for node_array in variations.content:
		for node in node_array:
			if !visited_items.has(node.node_index):
				remaining_options.push_back(node_array)

	if remaining_options.size() == 0:
		if mode == 'once':
			return ClydeInterpreter.DEFAULT_INDEX

		if mode == 'cycle':
			memory.set_internal_variable(SHUFFLE_VISITED_KEY, []);
			return _handle_shuffle_variation(variations, mode)
		return memory.get_internal_variable(LAST_VISITED_KEY, -1);

	randomize()
	var random = randi() % remaining_options.size()
	var node_index = variations.content.find(remaining_options[random]);

	visited_items.push_back(remaining_options[random][0].node_index);

	memory.set_internal_variable(LAST_VISITED_KEY, node_index);
	memory.set_internal_variable(SHUFFLE_VISITED_KEY, visited_items);

	return node_index;
