extends Control

enum POSITION {CENTER, LEFT, RIGHT}
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var charactersCount = 0
@onready var center : Marker2D = %center
@onready var left_side  : Marker2D = %leftSide
@onready var right_side  : Marker2D = %rightSide



var charactersOnScreen : Dictionary ={}



var positionsToCharacters : Dictionary ={
	POSITION.CENTER : "",
	POSITION.LEFT : "",
	POSITION.RIGHT : ""
}


func emote(emotion : String, character : String):
	emotion = emotion.to_lower();
	character = character.to_lower();
	if(charactersOnScreen.has(character) == false):
		printerr(character + " doesn't exist on screen yet!")
		return
	var position : int = charactersOnScreen[character]

	
	match position:
		POSITION.CENTER:
			setEmotion(center, emotion)
		POSITION.LEFT:
			setEmotion(left_side,emotion)
		POSITION.RIGHT:
			setEmotion(right_side,emotion)


func setEmotion(local : Marker2D, emotion : String):
	if(local.get_child_count() == 0):
		printerr(local.name as String + " did not have any children to set emotion to")
		return



func enters(characterName : String):
	characterName = characterName.to_lower();
	charactersCount = charactersCount + 1
	print("character enter")



func setDictionaries(name : String, position : int):
	positionsToCharacters[position] = name
	charactersOnScreen[name] = position


func reset():
	charactersCount = 0
	for child in left_side.get_children():
		child.queue_free()
	for child in center.get_children():
		child.queue_free()
	for child in right_side.get_children():
		child.queue_free()


func exits(character : String):
	print("characters leaving")
	character = character.to_lower();
	if(charactersOnScreen.has(character) == false):
		printerr(character + " doesn't exist on screen yet!")
		return
	var position : int = charactersOnScreen[character]
	positionsToCharacters[POSITION.CENTER] = ""
	match position:
		POSITION.CENTER:
			center.get_child(0).queue_free()
		POSITION.LEFT:
			left_side.get_child(0).queue_free()
		POSITION.RIGHT:
			right_side.get_child(0).queue_free()
	charactersCount = charactersCount - 1
	charactersOnScreen.erase(character)
