class_name LineInterpreter
extends MiscInterpreter


func handle_content_node(content_node : ContentNode, fallback = true) -> DialogueNode:
	if content_node.node_index == BonnieInterpreter.DEFAULT_INDEX:
		content_node.node_index = stack.generate_index()
	stack.add_to_stack(content_node)

	var current_node : InterpreterStack.StackElement = stack.stack_head()
	# Get all new nodes
	
	var node : DialogueNode = get_all_content_nodes(current_node)
	if(node != null): 
		return node
	stack.stack_pop()
	if(fallback):
		return interpreter.handle_next_node(stack.stack_head().node);
	return null


func get_all_content_nodes(stack_element : InterpreterStack.StackElement) -> DialogueNode:
	var content_index : int = stack_element.content_index + 1
	if content_index < stack_element.node.content.size():
		stack_element.content_index = content_index
		return interpreter.handle_next_node(stack_element.node.content[content_index])
	return null


func handle_line_node(line_node : LineNode) -> LineNode:
	if line_node.node_index == BonnieInterpreter.DEFAULT_INDEX:
		line_node.node_index = stack.generate_index()

	line_node.value = replace_variables(translate_text(line_node.id, line_node.value, line_node.id_suffixes))
	return line_node


func translate_text(key : String, text : String, id_suffixes : Array):
	if key.is_empty():
		return text

	if !id_suffixes.is_empty():
		var lookup_key : String = key
		for ids in id_suffixes:
			var value = interpreter.get_variable(ids)
			if value:
				lookup_key += "%s%s" % [interpreter.config.id_suffix_lookup_separator, value]
		var position = tr(lookup_key)

		if position != lookup_key:
			return position

	var position = tr(key)
	if position == key:
		return text
	return position


func replace_variables(text : String) -> String:
	if text.is_empty():
		return text
	var regex = RegEx.new()
	regex.compile("\\%(?<variable>[A-z0-9]*)\\%")
	for result in regex.search_all(text):
		var value = interpreter.get_variable(result.get_string("variable"))
		text = text.replace(result.get_string(), str(value) if value != null else "")

	return text
