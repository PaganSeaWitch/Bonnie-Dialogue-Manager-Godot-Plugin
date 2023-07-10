class_name LinePartParser
extends MiscParser


func add_to_line_part(line : BonnieNode, speaker, tags, id, id_suffixes, index : int):
	if(line is LinePartNode):
		return(add_to_line_part(line.part, speaker, tags, id, id_suffixes,index))
	if(speaker != null):
		line.speaker = speaker
	if(tags != null):
		for tag in tags:
			if(!line.tags.has(tag)):
				line.tags.append(tag)
	if(id != null && !id.is_empty()):
		line.id = id + "_" + str(index);
	if(id_suffixes != null):
		for suffix in id_suffixes:
			if(!line.id_suffixes.has(suffix)):
				line.id_suffixes.append(suffix)
	return line 


func _get_from_line_part(node : BonnieNode, member : String, directive : String = ""):
	if(node is LineNode):
		return node.get(member)
	if(node is LinePartNode):
		return _get_from_line_part(node.part, member,directive)
	else:
		if(!node.content.is_empty()):
			if(directive == "last"):
				var something = _get_from_line_part(node.content.back(), member,directive)
				if(something != null):
					return something
			for content in node.content:
				var something = _get_from_line_part(content, member,directive)
				if(something != null && !something.is_empty()):
					return something
		return null


func update_line_parts_in_content(content : Array, speaker, tags, id, id_suffixes,):
		for i in range(content.size()):
			if(content[i] is LinePartNode):
				var inner_line_part : LinePartNode = content[i];
				var part = inner_line_part.part;
				if(part is LineNode):
					inner_line_part.part = add_to_line_part(part, speaker, tags, id, id_suffixes, i)
				else:
					if(!inner_line_part.part.content.is_empty()):
						if(id != null && !id.is_empty()):
							inner_line_part.part.content = update_line_parts_in_content(inner_line_part.part.content, speaker, tags, id+"_"+str(i), id_suffixes)
						else:
							inner_line_part.part.content = update_line_parts_in_content(inner_line_part.part.content, speaker, tags, id, id_suffixes)
			else:
				content[i] = add_to_line_part(content[i], speaker, tags, id , id_suffixes, i)
		return content


func remove_non_value_line_parts_in_content(content):
	var new_content = []
	for i in range(content.size()):
			if(content[i] is LinePartNode):
				var inner_line_part : LinePartNode = content[i];
				var part = inner_line_part.part;
				if(part is LineNode && !(part is ActionContentNode)):
					if(part.value != "" || !part.tags.is_empty() || part.bb_code_before_line != ""):
						new_content.append(inner_line_part)
				else:
					if(!inner_line_part.part.content.is_empty()):
						inner_line_part.part.content = remove_non_value_line_parts_in_content(inner_line_part.part.content)
					new_content.append(inner_line_part)
			else:
				if(content[i].value != "" || !content[i].tags.is_empty() || content[i].bb_code_before_line != ""):
					new_content.append(content[i])
	return new_content


func _update_line_parts(content_node : ContentNode, line_part : LinePartNode):
	if token_walker.peek(TokenArray.lineBreak):
		token_walker.consume(TokenArray.lineBreak)
		line_part.end_line = true
	
	if token_walker.peek(TokenArray.eof):
		line_part.end_line = true

	content_node.content.append(line_part)
	
	if line_part.end_line == false:
		if token_walker.peek(TokenArray.brace_open):
			token_walker.consume(TokenArray.brace_open)
			return parser.dependent_parser.line_part_with_action(null, content_node)
		if token_walker.peek(TokenArray.curly_brace_open):
			token_walker.consume(TokenArray.curly_brace_open)
			return parser.logic_parser.line_with_action(content_node, true)
		if token_walker.peek(TokenArray.bb_code_open):
			token_walker.consume(TokenArray.bb_code_open)
			return parser.bb_code_parser.line_part_with_bb_code(null, content_node)


	var speaker = _get_from_line_part(content_node.content[0].part, "speaker")
	var tags  = _get_from_line_part(content_node.content.back().part, "tags", "last")
	var id  = _get_from_line_part(content_node.content.back().part, "id", "last")
	var id_suffixes = _get_from_line_part(content_node.content.back().part, "id_suffixes", "last")


	content_node.content = update_line_parts_in_content(content_node.content, speaker,tags,id,id_suffixes)

	content_node.content = remove_non_value_line_parts_in_content(content_node.content)
	if(!content_node.content.is_empty()):
		content_node.content.back().end_line = true
	return content_node;
