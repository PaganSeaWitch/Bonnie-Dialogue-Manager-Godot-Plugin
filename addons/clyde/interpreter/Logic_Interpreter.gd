class_name ClydeLogicInterpreter
extends MiscInterpreter


func handle_assignment(assignment : AssignmentNode):
	var variable : VariableNode = assignment.variable;
	var source : ClydeNode = assignment.value;
	var value = _get_node_value(source);

	return _handle_assignment_operation(assignment, variable.name, value)


func _handle_assignment_operation(assignment : AssignmentNode, var_name : String, value):
	match assignment.operation:
		Syntax.TOKEN_ASSIGN:
			return memory.set_variable(var_name, value)
		Syntax.TOKEN_ASSIGN_SUM:
			return memory.set_variable(var_name, memory.get_variable(var_name) + value)
		Syntax.TOKEN_ASSIGN_SUB:
			return memory.set_variable(var_name, memory.get_variable(var_name) - value)
		Syntax.TOKEN_ASSIGN_MULT:
			return memory.set_variable(var_name, memory.get_variable(var_name) * value)
		Syntax.TOKEN_ASSIGN_DIV:
			return memory.set_variable(var_name, memory.get_variable(var_name) / value)
		Syntax.TOKEN_ASSIGN_POW:
			return memory.set_variable(var_name, pow(memory.get_variable(var_name), value))
		Syntax.TOKEN_ASSIGN_MOD:
			return memory.set_variable(var_name, memory.get_variable(var_name) % value)
		_:
			printerr("Unknown operation %s" % assignment.operation)


func _get_node_value(node : ClydeNode):
	match node.get_node_class():
		"LiteralNode","NumberNode", "BooleanNode":
			return node.value
		"VariableNode":
			return memory.get_variable(node.name)
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
			return memory.get_variable(condition.name)

	printerr("Unknown condition type %s" % condition.type)


func check_expression(node : ExpressionNode):
	print(node)
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
		Syntax.TOKEN_MULT:
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
