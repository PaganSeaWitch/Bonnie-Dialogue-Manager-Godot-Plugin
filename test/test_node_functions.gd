class_name GutTestFunctions
extends GutTest



func _parse(input, print= false):
	var parser = BonnieParser.new()
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
		"document_name" : line.get("document_name") if line.get("document_name") != null else ""
	}


func _assignments(assignments):
	return {
		"type" : NodeFactory.NODE_TYPES.ASSIGNMENTS,
		"assignments" : assignments,
		"document_name" : ""
	}


func _expression(expression):
	return {
		"type" : NodeFactory.NODE_TYPES.EXPRESSION,
		"elements" : expression.get("elements") if expression.get("elements") != null else [],
		"name": expression.get("name") if expression.get("name") != null else "",
		"document_name" : expression.get("document_name") if expression.get("document_name") != null else ""
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
		"document_name" : assignment.get("document_name") if assignment.get("document_name") != null else ""
	}


func _divert(divert):
	return {
		"type" : NodeFactory.NODE_TYPES.DIVERT,
		"target" : divert,
		"document_name" : ""
	}

func _number(number):
	return {
		"type" : NodeFactory.NODE_TYPES.NUMBER_LITERAL,
		"value":number,
		"document_name" :""
	}


func _bool(truth):
	return {
		"type": NodeFactory.NODE_TYPES.BOOLEAN_LITERAL,
		"value": truth,
		"document_name" : ""
	}

func _event(event):
	return {
		"type" : NodeFactory.NODE_TYPES.EVENT,
		"name" : event,
		"document_name" : ""
	}

func _string(string):
	return {
		"type" : NodeFactory.NODE_TYPES.STRING_LITERAL,
		"value" : string,
		"document_name" : ""
	}

func _events(events):
	return {
		"type" : NodeFactory.NODE_TYPES.EVENTS,
		"events" : events,
		"document_name" :  ""
	}

func _variable(variable):
	return {
		"type" : NodeFactory.NODE_TYPES.VARIABLE,
		"name": variable,
		"document_name" : ""
	}


func _conditional_content(conditional_content):
	var content = conditional_content.get("content") if conditional_content.get("content") != null else []
	var conditions = conditional_content.get("conditions")
	return {
		"type" : NodeFactory.NODE_TYPES.CONDITIONAL_CONTENT,
		"content" : content,
		"conditions" : conditions,
		"document_name" : conditional_content.get("document_name") if conditional_content.get("document_name") != null else ""
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
	var content = BonnieParser.new().to_JSON_object(dialogue.get_content())
	while content.type != NodeFactory.NODE_TYPES.OPTIONS:
		content = BonnieParser.new().to_JSON_object(dialogue.get_content())
	return content


func _get_lexer_json_tokens(string : String):
	var lexer = BonnieLexer.new()
	var tokens = lexer.init(string).get_all()
	var jsonTokens : Array = []
	for token in tokens:
		jsonTokens.append(Token.to_JSON_object(token))
	return jsonTokens


func _line_part(part : Dictionary, end_line = false):
	return {
		"type" : NodeFactory.NODE_TYPES.LINE_PART,
		"part": part,
		"end_line": end_line,
		"document_name" : part.get("document_name") if part.get("document_name") != null else ""
	}


func _block(block):
	return {
		"type" : NodeFactory.NODE_TYPES.BLOCK,
		"block_not_requirements" : block.get("block_not_requirements") if block.get("block_not_requirements") != null else [],
		"block_requirements" : block.get("block_requirements") if block.get("block_requirements") != null else [],
		"conditions": block.get("conditions") if block.get("conditions") != null else [],
		"block_name" : block.get("block_name") if block.get("block_name") != null else "",
		"content" : block.get("content") if block.get("content") != null else [],
		"document_name" : block.get("document_name") if block.get("document_name") != null else ""
	}

func _random_block(block):
	var gotten_block = _block(block)
	gotten_block["type"] = NodeFactory.NODE_TYPES.RANDOM_BLOCK
	gotten_block["mode"] = block.get("mode") if block.get("mode") != null else ""
	return gotten_block


func _variations(variation):
	return{
		"type": NodeFactory.NODE_TYPES.VARIATIONS,
		"mode": variation.get("mode") if variation.get("mode") != null else "",
		"content" : variation.get("content") if variation.get("content") != null else [],
		"document_name" : variation.get("document_name") if variation.get("document_name") != null else ""
	}

func _create_doc_payload(content = [], blocks = []):
	return {
		"type":  NodeFactory.NODE_TYPES.DOCUMENT,
		"content": content,
		"blocks": blocks,
		"document_name" : ""
	}


func _create_content_payload(content = []):
	return {
		"type": NodeFactory.NODE_TYPES.CONTENT,
		"content": content,
		"document_name" : ""
	}
