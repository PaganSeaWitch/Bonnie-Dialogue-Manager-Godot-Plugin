extends MarginContainer

var _dialogue

func _ready():
	_dialogue = Bonnie.new()
	_dialogue.load_dialogue('pulp_with_blocks')

	_dialogue.connect("event_triggered",Callable(self,'_on_event_triggered'))
	_dialogue.connect("variable_changed",Callable(self,'_on_variable_changed'))


func _get_next_dialogue_line():
	var content = _dialogue.get_content()
	if not content:
		$line.hide()
		$options.hide()
		$dialogue_ended.show()
		return

	if content.get_node_class() == 'LineNode':
		_set_up_line(content)
		$line.show()
		$options.hide()
	else:
		_set_up_options(content)
		$options.show()
		$line.hide()


func _set_up_line(content):
	$line/speaker.text = content.get('speaker') if content.get('speaker') != null else ''
	$line/text.text = content.value


func _set_up_options(options):
	for c in $options/items.get_children():
		c.queue_free()

	$options/name.text = options.get('name') if options.get('name') != null else ''
	$options/speaker.text = options.get('speaker') if options.get('speaker') != null else ''

	var index = 0
	for option in options.content:
		var btn = Button.new()
		btn.text = option.value
		btn.connect("button_down",Callable(self,"_on_option_selected").bind(index))
		$options/items.add_child(btn)
		index += 1


func _on_option_selected(index):
	_dialogue.choose(index)
	_get_next_dialogue_line()


func _gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		_get_next_dialogue_line()


func _on_event_triggered(event_name):
	print("Event received: %s" % event_name)


func _on_variable_changed(variable_name, new_value, previous_value):
	print("variable changed: %s old %s new %s" % [variable_name, previous_value, new_value])


func _on_restart_pressed():
	$dialogue_ended.hide()
	_dialogue.clear_data()
	_dialogue.load_dialogue('pulp_with_blocks')
	_dialogue.start()
	_get_next_dialogue_line()
