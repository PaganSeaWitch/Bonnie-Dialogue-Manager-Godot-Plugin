extends VBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var textOptions : Dictionary  = {}


func setUpOptions(options : Dictionary) -> void:
	var i : int = 0
	for key in options.keys():
		if(i < 5):
			self.get_child(i).visible = true
			self.get_child(i).text = key
			i = i + 1
	self.textOptions = options


func _on_option_pressed() -> void:
	for child in self.get_children():
		if(child.has_focus()):
			get_parent().parseChoice(child.get_index(), textOptions[child.text])
		child.visible = false
		child.text = ""
	
