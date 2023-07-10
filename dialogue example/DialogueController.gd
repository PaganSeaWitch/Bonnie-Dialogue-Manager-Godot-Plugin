extends Node



#nodes for actions
@onready var sound_effect_player = $"%soundEffectPlayer"
@onready var background = $"%Background"

@onready var dialogue_container = $"%dialogueContainer"
@onready var options_container = $"%optionsContainer"
@onready var stage_controller = %StageController

var dialogue : Bonnie
var clydeFile : String

var playerName := ""
var dialogueStarted := false
var line : String
var speaker : String
var danielLove : int = 0
var firstDown : bool = true
var pauseForOptions : bool = false
var dialogueLoaded : bool = false
signal dialogue_finished()
signal change_character_stat(character, stat, typeOfChange)


func _ready():
	loadDialogue("simple_lines", "", [], true)

func loadDialogue(file: String, block : String, startingValues : Array, loadInFirstLine : bool = false):
	clydeFile = file

	dialogue = Bonnie.new();
	dialogue.load_dialogue(clydeFile)

	if(!block.is_empty()):
		dialogue.start(block)
	else:
		dialogue.start()
	
	dialogueLoaded = true

	if(loadInFirstLine):
		parseContent(dialogue.get_content())


func _input(event : InputEvent):
	if(event is InputEventMouseButton && dialogueLoaded == true):
		if(event.button_index == MOUSE_BUTTON_RIGHT && event.pressed == true && pauseForOptions == false):
			if(self.visible == false):
				self.visible = true
			parseContent(dialogue.get_content())


# Parses the choice player made
func parseChoice(indexOfChoice : int, contentOfChoice : Array) -> void:
	for tag in contentOfChoice:
		resolveOptionTag(tag)
	dialogue.choose(indexOfChoice)
	parseContent(dialogue.get_content())
	pauseForOptions = false


# Parses the content taken from clyde file
func parseContent(content : BonnieNode) -> void:
	if(content != null):
		dialogue_container.reset()
		print(content)
		if(content is LineNode):
			parseLine(content)
		if(content is OptionsNode):
			parseOptions(content)
		if(content.get("tags") != null):
			for tag in content.get("tags"):
				resolveLineTag(tag)
		dialogue_container.beginDialogue()
	else:
		dialogue_container.reset()
		self.visible = false
		print("end of dialogue!")
		dialogueLoaded = false
		emit_signal("dialogue_finished")
		stage_controller.reset()


# Parses a clyde line
func parseLine(line : LineNode) -> void:
	if(line.value == null || line.speaker == null):
		printerr("line is not correctly formatted!")
		printerr(line)
		return
	dialogue_container.setDialogueLine(line.value)
	dialogue_container.setSpeaker(line.speaker)


#parses a clyde option set
func parseOptions(options: OptionsNode) -> void:
		options_container.visible = false
		pauseForOptions = true
		if(options.name == null || options.speaker == null):
			printerr("line is not correctly formatted!")
			printerr(options)
			return
		dialogue_container.setDialogueLine(options.name)
		dialogue_container.setSpeaker(options.speaker)
		var optionDictionary : Dictionary = {}
		for option in options.content:
			optionDictionary[option.name]= option.tags	
		options_container.setUpOptions(optionDictionary)


# parses a tag for a line
func resolveLineTag(tag: String) -> void:
	var prefix : String = tag.get_slice("_", 0)
	var suffix : String = tag.get_slice("_", 1)
	prefix = prefix.to_lower();
	suffix = suffix.to_lower();
	match prefix:
		"hidden":
			dialogue_container.setSpeaker("???")
		"e":
			stage_controller.emote(suffix, tag.get_slice("_",2))
		"thoughts":
			print('in thots')
		"se":
			sound_effect_player.playSoundEffect(suffix)
		"exits":
			stage_controller.exits(suffix)
		"sc":
			background.showSpecialScene(suffix)
		"ve":
			printerr("visual effect tag not implemented yet!")
		"b":
			printerr("background tag not implemented yet!")
		"enters":
			stage_controller.enters(suffix)
		_:
			printerr("the tag with the prefix: " + prefix + " and the suffix: " + suffix +" couldn't be parsed!")


#parses a tag for an option
func resolveOptionTag(tag : String) -> void:
	var prefix : String = tag.get_slice("_", 0)
	var suffix : String = tag.get_slice("_", 1)
	prefix = prefix.to_lower();
	suffix = suffix.to_lower();
	match prefix:
		"affection":
			print(suffix + "'s affection toward you will " + tag.get_slice("_",2))
		_:
			printerr("the tag with the prefix:" + prefix + " and the suffix: " + suffix +  " couldn't be parsed!")


func _on_dialogue_container_finished_text() -> void:
	if(pauseForOptions):
		options_container.visible = true
