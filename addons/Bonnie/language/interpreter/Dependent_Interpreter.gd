class_name DependentInterpreter
extends MiscInterpreter


func handle_line_part_node(line_part : LinePartNode):
	match(line_part.part.get_node_class()):
		"LineNode":
			line_part.part = interpreter.line_interpreter.handle_line_node(line_part.part)
		"LinePartNode":
			return handle_line_part_node(line_part.part)
		"ActionContentNode":
			interpreter.logic_interpreter.handle_action(line_part.part)
			var content = ContentNode.new()
			content.content = line_part.part.content
			var gotten = interpreter.line_interpreter.handle_content_node(content, false)
			if(gotten is LinePartNode):
				line_part = gotten
			else:
				line_part.part = gotten
		"ConditionalContentNode":
			if interpreter.logic_interpreter.check_condition(line_part.part.conditions):
				var content = ContentNode.new()
				content.content = line_part.part.content
				var gotten = interpreter.line_interpreter.handle_content_node(content, false)
				if(gotten is LinePartNode):
					line_part = gotten
				else:
					line_part.part = gotten
			else:
				return interpreter.handle_next_node(stack.stack_head().node)

	if(!line_part.end_line):
		line_part.end_line = check_next_line_part_is_valid(line_part)
	
	if(line_part.part == null):
		return interpreter.handle_next_node(stack.stack_head().node)
	
	return line_part



func check_next_line_part_is_valid(line_part : LinePartNode):
	var content_node = stack.stack_head().node
	if(content_node != null && content_node.get_node_class() == "ContentNode"):
		var index = content_node.content.find(line_part)
		if(index != -1 && content_node.content.back() != line_part):
			for i in range(index + 1, content_node.content.size()):
				var next_part = content_node.content[i]
				if(next_part != null):
					match(next_part.part.get_node_class()):
						"LineNode":
							return false
						"ActionContentNode":
							var content = ContentNode.new()
							if(!next_part.part.content.is_empty()):
								return false
						"ConditionalContentNode":
							if interpreter.logic_interpreter.check_condition(next_part.part.conditions):
								return false
	return true
