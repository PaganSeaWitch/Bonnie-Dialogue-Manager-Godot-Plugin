extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
@onready var name_text = $"%nameText"
@onready var dialogue_text = $"%dialogueText"
@onready var text_timer = $"%textTimer"
@onready var name_box = $"%NameBox"
var speaker : String = ""
var line : String = ""
var linePartion : int = 0

signal finishedText

var bbcodesToSymbols ={
	"[b]" : "╔",
	"[/b]" : "╩",
	"[i]" : "╦",
	"[/i]" : "╠",
	"[u]" : "═",
	"[/u]" : "╬",
	"[/s]" : "╧",
	"[s]" : "╨",
}


var SymbolsToBbcodes ={
	"╔" : "[b]" ,
	"╩" : "[/b]" ,
	"╦" :"[i]",
	"╠": "[/i]",
	"═": "[u]" ,
	"╬": "[/u]" ,
	"╧": "[/s]",
"╨" : "[s]",
}


func reset() -> void:
	text_timer.stop()
	setSpeaker("")
	setDialogueLine("")
	linePartion = 0


func setSpeaker(newSpeaker : String)-> void:
	speaker = newSpeaker
	if(speaker == "Narration"):
		name_box.visible = false
	else:
		name_box.visible = true


func setDialogueLine(newLine : String) -> void:
	newLine = newLine.capitalize();

	for key in bbcodesToSymbols.keys():
		newLine = newLine.replacen(key, bbcodesToSymbols[key])

	line = newLine


func beginDialogue():
	name_text.text = speaker
	_on_Timer_timeout()


func _on_Timer_timeout():
	var currentChar := line.substr(linePartion, 1)

	if(SymbolsToBbcodes.has(currentChar)):
		var front := line.substr(0, linePartion)
		line = front + SymbolsToBbcodes[currentChar] + line.substr(linePartion+1)
		linePartion = linePartion + SymbolsToBbcodes[currentChar].length()
		dialogue_text.text = line.substr(0, linePartion)
	else:
		dialogue_text.text = line.substr(0, linePartion)
		linePartion = linePartion + 1
	if(linePartion <= line.length()):
		text_timer.start()
	else:
		linePartion = 1
		text_timer.stop()
		emit_signal("finishedText")
