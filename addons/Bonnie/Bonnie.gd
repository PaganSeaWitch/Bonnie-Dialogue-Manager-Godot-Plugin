class_name Bonnie
extends IBonnie
## A Dialogue Manager for Bonnie Dialogue Language files. 
##
## @tutorial(Bonnie Language Docs):            https://github.com/PaganSeaWitch/Bonnie-Dialogue-Manager-Godot-Plugin/blob/4.1/LANGUAGE.md


## Load dialogue file
## file_name: path to the dialogue file.
##            i.e 'my_dialogue', 'res://my_dialogue.bonnie', res://my_dialogue.json
## block: block name to run. This allows keeping
##        multiple dialogues in the same file.
## check_access: when true, will check whether the requirements for accessing this block are met before allowing access
func load_dialogue(file_name : String, block  : String= "", check_access :bool = false) -> void:
	_interpreter = BonnieInterpreter.new()
	super(file_name, block,check_access)







