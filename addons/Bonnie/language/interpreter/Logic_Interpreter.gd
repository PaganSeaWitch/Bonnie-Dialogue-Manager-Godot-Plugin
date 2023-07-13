class_name LogicInterpreter
extends MiscInterpreter


func handle_assignment(assignment : AssignmentNode):
	var variable : VariableNode = assignment.variable;
	var source : BonnieNode = assignment.value;
	var value = _get_node_value(source);

	return _handle_assignment_operation(assignment, variable.name, value)


func handle_action_content_node(action_node : ActionContentNode):
	handle_action(action_node)
	var content = ContentNode.new()
	content.content = action_node.content
	return interpreter.line_interpreter.handle_content_node(content)


func handle_conditional_content_node(conditional_node : ConditionalContentNode, 
fallback_node : BonnieNode = stack.stack_head().node):
	if check_condition(conditional_node.conditions):
		var content = ContentNode.new()
		content.content = conditional_node.content
		return interpreter.line_interpreter.handle_content_node(content)
	return interpreter.handle_next_node(fallback_node)


func handle_assignments_node(assignments_node : AssignmentsNode):
	for assignment in assignments_node.assignments:
		handle_assignment(assignment)
	return interpreter.handle_next_node(stack.stack_head().node);


func handle_events_node(events : EventsNode):
	for event in events.events:
		interpreter.emit_signal("event_triggered", event.name)
	return interpreter.handle_next_node(stack.stack_head().node);


func handle_action(action_node : ActionContentNode):
	for action in action_node.actions:
		if action is EventsNode:
			for event in action.events:
				interpreter.emit_signal("event_triggered", event.name)
		if action is AssignmentNode:
			handle_assignment(action)
		if action is AssignmentsNode:
			for assignment in action.assignments:
				handle_assignment(assignment)


func _handle_assignment_operation(assignment : AssignmentNode, var_name : String, value):
	match assignment.operation:
		Syntax.TOKEN_ASSIGN:
			return interpreter.set_variable(var_name, value)
		Syntax.TOKEN_ASSIGN_SUM:
			return interpreter.set_variable(var_name, interpreter.get_variable(var_name) + value)
		Syntax.TOKEN_ASSIGN_SUB:
			return interpreter.set_variable(var_name, interpreter.get_variable(var_name) - value)
		Syntax.TOKEN_ASSIGN_MULT:
			return interpreter.set_variable(var_name, interpreter.get_variable(var_name) * value)
		Syntax.TOKEN_ASSIGN_DIV:
			return interpreter.set_variable(var_name, interpreter.get_variable(var_name) / value)
		Syntax.TOKEN_ASSIGN_POW:
			return interpreter.set_variable(var_name, pow(interpreter.get_variable(var_name), value))
		Syntax.TOKEN_ASSIGN_MOD:
			return interpreter.set_variable(var_name, interpreter.get_variable(var_name) % value)
		_:
			printerr("Unknown operation %s" % assignment.operation)


func _get_node_value(node : BonnieNode):
	match node.get_node_class():
		"LiteralNode","NumberNode", "BooleanNode", "StringNode":
			return node.value
		"VariableNode":
			return interpreter.get_variable(node.name)
		"AssignmentNode":
			return handle_assignment(node)
		"ExpressionNode":
			return check_expression(node)
		"NullTokenNode":
			return null
	printerr("Unknown node in expression %s" % node.type)
	return null


func check_condition(condition : NamedNode):
	match condition.get_node_class():
		"ExpressionNode":
			return check_expression(condition)
		"VariableNode":
			return interpreter.get_variable(condition.name)

	printerr("Unknown condition type %s" % condition.type)


func check_expression(node : ExpressionNode):
	match node.name:
		Syntax.TOKEN_EQUAL:
			return _get_node_value(node.elements[0]) == _get_node_value(node.elements[1])
		Syntax.TOKEN_NOT_EQUAL:
			return _get_node_value(node.elements[0]) != _get_node_value(node.elements[1])
		Syntax.TOKEN_GREATER:
			var a = _get_node_value(node.elements[0])
			var b = _get_node_value(node.elements[1])
			if (a == null || b == null):
				return false
			return a > b
		Syntax.TOKEN_GE:
			var a = _get_node_value(node.elements[0])
			var b = _get_node_value(node.elements[1])
			if (a == null || b == null):
				return false
			return a >= b
		Syntax.TOKEN_LESS:
			var a = _get_node_value(node.elements[0])
			var b = _get_node_value(node.elements[1])
			if (a == null || b == null):
				return false
			return a < b
		Syntax.TOKEN_LE:
			var a = _get_node_value(node.elements[0])
			var b = _get_node_value(node.elements[1])
			if (a == null || b == null):
				return false
			return a <= b
		Syntax.TOKEN_AND:
			return check_condition(node.elements[0]) && check_condition(node.elements[1])
		Syntax.TOKEN_OR:
			return check_condition(node.elements[0]) || check_condition(node.elements[1])
		Syntax.TOKEN_NOT:
			return not check_condition(node.elements[0])
		Syntax.TOKEN_MULT:
			var a = _get_node_value(node.elements[0])
			var b = _get_node_value(node.elements[1])
			if (a == null || b == null):
				return null
			return a * b
		Syntax.TOKEN_DIV:
			var a = _get_node_value(node.elements[0])
			var b = _get_node_value(node.elements[1])
			if (a == null || b == null):
				return null
			return a / b
		Syntax.TOKEN_MINUS:
			var a = _get_node_value(node.elements[0])
			var b = _get_node_value(node.elements[1])
			if (a == null || b == null):
				return null
			return a - b
		Syntax.TOKEN_PLUS:
			var a = _get_node_value(node.elements[0])
			var b = _get_node_value(node.elements[1])
			if (a == null || b == null):
				return null
			return a + b
		Syntax.TOKEN_POWER:
			var a = _get_node_value(node.elements[0])
			var b = _get_node_value(node.elements[1])
			if (a == null || b == null):
				return null
			return pow(a, b)
		Syntax.TOKEN_MOD:
			var a = _get_node_value(node.elements[0])
			var b = _get_node_value(node.elements[1])
			if (a == null || b == null):
				return null
			return a % b

	printerr("Unknown expression %s" % node.name)
