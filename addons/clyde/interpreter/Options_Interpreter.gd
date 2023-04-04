class_name OptionsInterpreter
extends MiscInterpreter


func choose(option_index : int):
	var head : InterpreterStack.StackElement = stack.stack_head()
	if head.node is OptionsNode:
		var content = _get_visible_options(head.node.content)

		if option_index >= content.size():
			printerr("Index %s not available." % option_index)
			return

		memory.set_internal_variable('OPTIONS_COUNT', _get_visible_options(head.node.content).size())
		content[option_index].node_index = content[option_index].node_index;

		if content[option_index] is ActionContentNode:
			content[option_index].content.content.node_index = content[option_index].content.node_index
			interpreter.misc_interpreter.handle_action(content[option_index]);
			stack.add_to_stack(content[option_index].content);
			stack.add_to_stack(content[option_index].content.content);
		else:
			stack.add_to_stack(content[option_index])
			var newContent : ContentNode = ContentNode.new()
			newContent.content = content[option_index].content
			stack.add_to_stack(newContent)
	else:
		printerr("Nothing to select")


func handle_options_node(options_node : OptionsNode) -> OptionsNode:
	if options_node.node_index == ClydeInterpreter.DEFAULT_INDEX:
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
	
	options_node.name = interpreter.line_interpreter.replace_variables(
		interpreter.line_interpreter.translate_text(
			options_node.id, options_node.name, options_node.id_suffixes))
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
	return options.map(func (e : ClydeNode):
		return _prepare_option(e, options.find(e))
	).filter(_check_if_option_not_accessed)


func _prepare_option(option : ClydeNode, node_index : int) -> ClydeNode:
	if option.node_index == ClydeInterpreter.DEFAULT_INDEX:
		option.node_index = stack.generate_index() * 100 + node_index

	if option is ConditionalContentNode:
		if(option.content.size() > 0):
			option.content[0].node_index = option.node_index;
			if interpreter.logic_interpreter.check_condition(option.conditions):
				return _prepare_option(option.content[0], node_index)
		return null

	if option is ActionContentNode:
		if(option.content.size() > 0):
			option.content[0].node_index = option.node_index
			option.mode = option.content[0].mode
			return _prepare_option(option.content[0], node_index)
		return null

	return option;


func _check_if_option_not_accessed(option : ClydeNode):
	return option != null && !(option.mode == 'once' 
		&& memory.was_already_accessed(option.node_index))
