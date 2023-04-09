class_name MiscInterpreter
extends RefCounted


var memory : MemoryInterface
var stack : InterpreterStack
var interpreter : ClydeInterpreter


func init(_interpreter : ClydeInterpreter, mem : MemoryInterface, _stack:  InterpreterStack) -> void:
	interpreter = _interpreter
	memory = mem
	stack = _stack


func handle_action_content_node(action_node : ActionContentNode):
	handle_action(action_node)
	var content = ContentNode.new()
	content.content = action_node.content
	return interpreter.line_interpreter.handle_content_node(content)


func handle_action(action_node : ActionContentNode):
	for action in action_node.action:
		if action is EventsNode:
			for event in action.events:
				interpreter.emit_signal("event_triggered", event.name)
		if action is AssignmentNode:
			interpreter.logic_interpreter.handle_assignment(action)
		if action is AssignmentsNode:
			for assignment in action.assignments:
				interpreter.logic_interpreter.handle_assignment(assignment)


func handle_conditional_content_node(conditional_node : ConditionalContentNode, 
fallback_node : ClydeNode = stack.stack_head().node):
	if interpreter.logic_interpreter.check_condition(conditional_node.conditions):
		var content = ContentNode.new()
		content.content = conditional_node.content
		return interpreter.line_interpreter.handle_content_node(content)
	return interpreter.handle_next_node(fallback_node)


func handle_block_node(block : BlockNode):
	stack.add_to_stack(block)
	var head : InterpreterStack.StackElement = stack.stack_head()
	var content_index : int = head.content_index + 1

	if content_index < head.node.content.size():
		head.content_index = content_index
		var next = head.node.content[content_index]
		return interpreter.handle_next_node(head.node.content[content_index]);


func handle_divert_node(divert : DivertNode):
	if divert.target == '<parent>':
		var target_parents : Array = [DocumentNode, BlockNode, OptionNode, OptionsNode]
		var is_target_parent : bool = false
		while !is_target_parent:
			for target_parent in target_parents:
				is_target_parent = is_instance_of(stack.stack_head().node, target_parent)
				if(is_target_parent): break
			if(!is_target_parent):
				stack.stack_pop()

		if stack.size() > 1:
			stack.stack_pop()
			return interpreter.handle_next_node(stack.stack_head().node)
	elif divert.target == '<end>':
		stack.initialise_stack(interpreter.doc)
		stack.stack_head().content_index = stack.stack_head().node.content.size();
	else:
		return interpreter.handle_next_node(interpreter.anchors[divert.target])


func handle_assignments_node(assignments_node : AssignmentsNode):
	for assignment in assignments_node.assignments:
		interpreter.logic_interpreter.handle_assignment(assignment)
	return interpreter.handle_next_node(stack.stack_head().node);


func handle_events_node(events : EventsNode):
	for event in events.events:
		interpreter.emit_signal("event_triggered", event.name)
	return interpreter.handle_next_node(stack.stack_head().node);


func handle_document_node(node : DocumentNode) -> DialogueNode:
	var current_node : InterpreterStack.StackElement = stack.stack_head()
	return interpreter.line_interpreter.get_all_content_nodes(current_node)
