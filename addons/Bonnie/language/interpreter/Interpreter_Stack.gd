class_name InterpreterStack
extends RefCounted


var _stack : Array[StackElement] = []


class StackElement:
	var node : BonnieNode
	var content_index : int = -1


func stack_head() -> StackElement:
	return _stack[_stack.size() - 1]


func stack_pop() -> StackElement:
	return _stack.pop_back()


func initialise_stack(root : BonnieNode) -> void:
	var element : StackElement = StackElement.new()
	element.node = root
	_stack.append(element)


func add_to_stack(node : BonnieNode) -> void:
	if stack_head().node != node:
		var element : StackElement = StackElement.new()
		element.node = node
		_stack.push_back(element)


func generate_index() -> int:
	return (10 * stack_head().node.node_index) + stack_head().content_index


func size() -> int:
	return _stack.size()
