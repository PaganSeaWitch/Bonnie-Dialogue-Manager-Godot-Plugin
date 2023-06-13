class_name GutTestFunctions
extends GutTest



func _parse(input, print= false):
	var parser = ClydeParser.new()
	var obj = parser.parse(input)
	print(obj)
	return parser.to_JSON_object(parser.parse(input), print)


func _line(line):
	var tags = line.get("tags") if line.get("tags") != null else []
	var value = line.get("value") if line.get("value") != null else ""
	var speaker = line.get("speaker") if line.get("speaker") != null else ""
	var id = line.get("id") if line.get("id") != null else ""
	var bb_code = line.get("bb_code_before_line") if line.get("bb_code_before_line") != null else ""
	return {
		"type": NodeFactory.NODE_TYPES.LINE,
		"value": value,
		"speaker": speaker,
		"id": id,
		"tags": tags,
		"id_suffixes": line.get("id_suffixes") if line.get("id_suffixes") != null else [],
		"bb_code_before_line" : bb_code,
	}


func _assignments(assignments):
	return {
		"type" : NodeFactory.NODE_TYPES.ASSIGNMENTS,
		"assignments" : assignments
	}


func _expression(expression):
	return {
		"type" : NodeFactory.NODE_TYPES.EXPRESSION,
		"elements" : expression.get("elements") if expression.get("elements") != null else [],
		"name": expression.get("name") if expression.get("name") != null else "",
	}


func _assignment(assignment):
	var value = assignment.get("value") 
	var operation = assignment.get("operation") if assignment.get("operation") != null else ""
	var variable = assignment.get("variable")
	return {
		"type": NodeFactory.NODE_TYPES.ASSIGNMENT,
		"variable": variable,
		"operation": operation,
		"value": value,
	}


func _divert(divert):
	return {
		"type" : NodeFactory.NODE_TYPES.DIVERT,
		"target" : divert
	}

func _number(number):
	return {
		"type" : NodeFactory.NODE_TYPES.NUMBER_LITERAL,
		"value":number
	}


func _bool(truth):
	return {
		"type": NodeFactory.NODE_TYPES.BOOLEAN_LITERAL,
		"value": truth
	}

func _event(event):
	return {
		"type" : NodeFactory.NODE_TYPES.EVENT,
		"name" : event,
	}

func _string(string):
	return {
		"type" : NodeFactory.NODE_TYPES.STRING_LITERAL,
		"value" : string
	}

func _events(events):
	return {
		"type" : NodeFactory.NODE_TYPES.EVENTS,
		"events" : events
	}

func _variable(variable):
	return {
		"type" : NodeFactory.NODE_TYPES.VARIABLE,
		"name": variable
	}


func _conditional_content(conditional_content):
	var content = conditional_content.get("content") if conditional_content.get("content") != null else []
	var conditions = conditional_content.get("conditions")
	return {
		"type" : NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
		"content" : content,
		"conditions" : conditions,
	}


func _action_content(actionContent):
	var actions = actionContent.get("actions") if actionContent.get("actions") != null else []
	var result = _option(actionContent)
	result["type"] = NodeFactory.NODE_TYPES.ACTION_CONTENT
	result["actions"] = actions
	return result;


func _options(options):
	var content = options.get("content") if options.get("content") != null else []
	var result = _line(options)
	result["type"] = NodeFactory.NODE_TYPES.OPTIONS
	result["content"] = content
	return result


func _option(option):
	var mode = option.get("mode") if option.get("mode") != null else ""
	var result = _options(option)
	result["type"] = NodeFactory.NODE_TYPES.OPTION
	result["mode"] = mode
	return result;


func _get_next_options_content(dialogue):
	var content = ClydeParser.new().to_JSON_object(dialogue.get_content())
	while content.type != NodeFactory.NODE_TYPES.OPTIONS:
		content = ClydeParser.new().to_JSON_object(dialogue.get_content())
	return content


func _get_lexer_json_tokens(string : String):
	var lexer = ClydeLexer.new()
	var tokens = lexer.init(string).get_all()
	var jsonTokens : Array = []
	for token in tokens:
		jsonTokens.append(Token.to_JSON_object(token))
	return jsonTokens


func _line_part(part : Dictionary, end_line = false):
	return {
		"type" : NodeFactory.NODE_TYPES.LINE_PART,
		"part": part,
		"end_line": end_line
	}


func _block(block):
	return {
		"type" : NodeFactory.NODE_TYPES.BLOCK,
		"block_name" : block.get("block_name") if block.get("block_name") != null else "",
		"content" : block.get("content") if block.get("content") != null else []
	}


func _variations(variation):
	return{
		"type": NodeFactory.NODE_TYPES.VARIATIONS,
		"mode": variation.get("mode") if variation.get("mode") != null else "",
		"content" : variation.get("content") if variation.get("content") != null else []
	}

func _create_doc_payload(content = [], blocks = []):
	return {
		"type":  NodeFactory.NODE_TYPES.DOCUMENT,
		"content": content,
		"blocks": blocks
	}


func _create_content_payload(content = []):
	return {
		"type": NodeFactory.NODE_TYPES.CONTENT,
		"content": content
	}
