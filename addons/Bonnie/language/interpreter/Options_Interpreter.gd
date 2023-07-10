class_name OptionsInterpreter
extends MiscInterpreter


func choose(option_index : int):
	var head : InterpreterStack.StackElement = stack.stack_head()
	if head.node is OptionsNode:
		var content = _get_visible_options(head.node.content)

		if option_index >= content.size():
			printerr("Index %s not available." % option_index)
			return

		memory.set_as_accessed(content[option_index].node_index)
		memory.set_internal_variable('OPTIONS_COUNT', _get_visible_options(head.node.content).size())
		content[option_index].node_index = content[option_index].node_index;

		if content[option_index] is ActionContentNode:
			content[option_index].content[0].content[0].node_index = content[option_index].content[0].node_index
			interpreter.logic_interpreter.handle_action(content[option_index]);
			stack.add_to_stack(content[option_index].content[0]);
			var newContent : ContentNode = ContentNode.new()
			newContent.content = content[option_index].content[0].content
			stack.add_to_stack(newContent)
		else:
			stack.add_to_stack(content[option_index])
			var newContent : ContentNode = ContentNode.new()
			newContent.content = content[option_index].content
			stack.add_to_stack(newContent)
	else:
		printerr("Nothing to select")


func handle_options_node(options_node : OptionsNode) -> OptionsNode:
	if options_node.node_index == BonnieInterpreter.DEFAULT_INDEX:
		options_node.node_index = stack.generate_index()
		memory.set_internal_variable('OPTIONS_COUNT', options_node.content.size())
	stack.add_to_stack(options_node)


	var options : Array = _get_visible_options(options_node.content)
	memory.set_internal_variable('OPTIONS_COUNT', options.size())

	if options.size() == 0:
		stack.stack_pop()
		return interpreter.handle_next_node(stack.stack_head().node)

	if (options.size() == 1 
	&& options[0].mode == 'fallback'):
		choose(0)
		return interpreter.handle_next_node(stack.stack_head().node)
	
	options_node.value = interpreter.line_interpreter.replace_variables(
		interpreter.line_interpreter.translate_text(
			options_node.id, options_node.value, options_node.id_suffixes))
	options_node.content = options
	return options_node


func handle_option_node(_option_node : OptionNode):
	# this is called when the contents inside the option
	# were read. option list default behavior is to quit
	# so we need to remove_at both option and option list from the stack.
	stack.stack_pop()
	stack.stack_pop()
	return interpreter.handle_next_node(stack.stack_head().node);


func _get_visible_options(options : Array) -> Array:
	return options.map(func (e : BonnieNode):
		return _prepare_option(e, options.find(e))
	).filter(_check_if_option_not_accessed)


func _prepare_option(node : BonnieNode, node_index : int) -> BonnieNode:
	var option : OptionNode = OptionNode.new()
	
	if node.node_index == BonnieInterpreter.DEFAULT_INDEX:
		node.node_index = stack.generate_index() * 100 + node_index

	if node is ConditionalContentNode:
		if(node.content.size() > 0):
			node.content[0].node_index = node.node_index
			if interpreter.logic_interpreter.check_condition(node.conditions):
				return _prepare_option(node.content[0], node_index)
		return null

	if node is ActionContentNode:
		if(node.content.size() > 0):
			node.content[0].node_index = node.node_index

			var content =  _prepare_option(node.content[0], node_index)
			if(content == null):
				return null
			else:
				node.value = node.content[0].value
				node.id = node.content[0].id
				
				node.mode = node.content[0].mode
				node.tags = node.content[0].tags
				node.id_suffixes = node.content[0].id_suffixes

	node.value = interpreter.line_interpreter.replace_variables(
			interpreter.line_interpreter.translate_text(
			node.id, node.value, node.id_suffixes))
	return node;


func _check_if_option_not_accessed(option : BonnieNode):
	if(option is ActionContentNode):
		return option.content[0] != null && !(option.content[0].mode == 'once' 
		&& memory.was_already_accessed(option.content[0].node_index))
	return option != null && !(option.mode == 'once' 
		&& memory.was_already_accessed(option.node_index))
