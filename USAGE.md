# Clyde Interpreter Usage

For details about Clyde and how to write dialogues, check [Clyde/LANGUAGE.md](https://github.com/viniciusgerevini/clyde/blob/master/LANGUAGE.md)

## Interpreter's interface

This plugin exposes the interpreter as `Bonnie`.

This is `Bonnie`'s interface:

```gdscript
extends Node

signal variable_changed(variable_name, value, previous_vale)
signal event_triggered(event_name)

# Load dialogue file
# file_name: path to the dialogue file.
#            i.e 'my_dialogue', 'res://my_dialogue.bonnie', res://my_dialogue.json

# block: block name to run. This allows keeping
#        multiple dialogues in the same file.
# check_access: whether to use block requirements to check whether to set the block or not. 
func load_dialogue(file_name : String, block  : String= "", check_access: bool = false) -> void:


# Start or restart dialogue. Variables are not reset.
#O ptional check_access which will only start the block if it can be accessed per the rules set by the blocks requirements. 
# Returns whether the block was set
func start(block_name : String = "", check_access: bool = false) -> bool:


# Get next dialogue content.
# The content may be a line, options or null.
# If null, it means the dialogue reached an end.
func get_content() -> BonnieNode:


# Choose one of the available options.
func choose(option_index : int) -> Bonnie:


# Set variable to be used in the dialogue
func set_variable(name : String, value):


# Get current value of a variable inside the dialogue.
# name: variable name
func get_variable(name : String):

```

### Creating an object

You need to instantiate a `Bonnie` object.

``` gdscript
var dialogue = Bonnie.new()
```


### Loading files

The interpreter supports loading parsed JSON files, as well as `.bonnie` files imported in the project.
When only the file name is provided, the interpreter will look into the default folder defined on `Project > Project Settings > Dialogue > Source Folder`.

``` gdscript
dialogue.load_dialogue('my_dialogue')
# or
dialogue.load_dialogue('res://dialogues/my_dialogue.bonnie')
# or
dialogue.load_dialogue('res://dialogues/my_dialogue.json')
```

As you can have more than one dialogue defined in a file through blocks, you can provide the block name to be used.
``` gdscript
dialogue.load_dialogue('level_001', 'first_dialogue')
```

### Starting / Restarting a dialogue

You can use `dialogue.start()` at any time to restart a dialogue or start a different block.

``` gdscript
# starts default dialogue
dialogue.start()

# starts a different block
dialogue.start('block_name')
```
Restarting a dialogue won't reset the variables already set.


### Getting next content

You should use `dialogue.get_content()` to get the next available content.

This method may return one of the following values that are child classes of `BonnieNode`:


#### Line Part
A single part of a line that has been split up by Dependent logic blocks. it contains the actual useful dialogue within it's part.

``` gdscript
class_name LinePartNode

var end_line : bool = false     # Indicates whether this is the end of a line or not
var part : BonnieNode            # The current part of the line, returned as a LineNode

```


#### Line

A dialogue line (`LineNode`).

```gdscript
class_name LineNode
    var value : String                      # The value of the line
    var id : String                         # The ID of the  line
    var speaker : String                    # The speaker of the  line
    
    var tags : Array                        # The tags of the line
    var id_suffixes : Array                 # The id_suffixes of the line 
    var bb_code_before_line : String        # The bb code just before the line, returned with its brackets
```

#### Options

Options list with options/topics the player may choose from (`OptionsNode`).

```gdscript
    class_name OptionsNode

    var id : String                         # The ID of the  Options
    var speaker : String                    # The speaker of the  Options
    
    var tags : Array                        # The tags of the Options
    var id_suffixes : Array                 # The id_suffixes of the Options 
    var content : Array[OptionNode] = []    # The option set that the options holds
    var name : String = ""                  # the name of the options
    var bb_code_before_line : String        # The bb code just before the line, returned with its brackets (NOT FUNCTIONAL)

    
    class_name OptionNode
    
    var id : String                         # The ID of the  Option
    var speaker : String                    # The speaker of the  Option
    
    var tags : Array                        # The tags of the Option
    var id_suffixes : Array                 # The id_suffixes of the Options
    var content : Array[BonnieNode] = []     # The nodes that will be parsed if this option is chosen
    var name : String = ""                  # the name of the option
    var mode : String = ""                  # the mode of the option: 'Once, sticky, fallback'
    var bb_code_before_line : String        # The bb code just before the line, returned with its brackets (NOT FUNCTIONAL)

```

#### Null

If `dialogue.get_content()` returns `Null`, it means the dialogue reached an end.


### Listening to variable changes

You can listen to variable changes by observing the `variable_changed` signal.

``` gdscript
  # ...

  dialogue.connect('variable_changed', self, '_on_variable_changed')


func _on_variable_changed(variable_name, value, previous_vale):
    if variable_name == 'hp' and value < previous_value:
        print('damage taken')

```

### Listening to events

You can listen to events triggered by the dialogue by observing the `event_triggered` signal.

``` gdscript
  # ...

  dialogue.connect('event_triggered', self, '_on_event_triggered')


func _on_event_triggered(event_name):
    if event_name == 'self_destruction_activated':
        _shake_screen()
        _play_explosion()

```

### Data persistence

To be able to use variations, single-use options and internal variables properly, you need to persist the dialogue data after each execution.

If you create a new `Bonnie` without doing it so, the interpreter will show the dialogue as if it was the first time it was run.

You can use `dialogue.get_data()` to retrieve all internal data, and then later use `dialogue.load_data(data)` to re-populate the internal memory.

Data is the `MemoryInterface.InternalMemory` class.

``` gdscript
    class InternalMemory:
        var access    : Dictionary = {}
        var	variables : Dictionary =  {}
        var	internal  : Dictionary = {}
```

Here is a simplified implementation:

``` gdscript
var _dialogue_filename = 'first_dialogue'
var _dialogue

func _ready():
    _dialogue = Bonnie.new()
    _dialogue.load_dialogue(_dialogue_filename)
    _dialogue.load_data(persistence.dialogues[_dialogue_filename]) # load data


func _get_next_content():
    var content = _dialogue.get_content()

    # ...

    if content == null:
        _dialogue_ended()


func _dialogue_ended():
    persistence.dialogues[_dialogue_filename] = _dialogue.get_data() # retrieve data for persistence

```

The example above assumes there is a global object called `persistence`, which is persisted every time the game is saved.

When starting a new dialogue execution, the internal data is loaded from the `persistence` object. When the dialogue ends, we update said object with the new values.

Note that the data is saved in in the dictionary under the dialogue filename key. The internal data should be used only in the same dialogue it was extracted from.

You should not change this object manually. If you want't to change a variable used in the previous execution, you should use `dialogue.set_variable(name, value)`.

``` gdscript
    # ...
    _dialogue = Bonnie.new()
    _dialogue.load_dialogue(_dialogue_filename)
    _dialogue.load_data(persistence.dialogues[_dialogue_filename])

    _dialogue.set_variable("health", character.health)
```


### Translations / Localisation

Godot already comes with a [localisation solution](https://docs.godotengine.org/en/stable/getting_started/workflow/assets/importing_translations.html#doc-importing-translations) built-in.

The interpreter leverages this solution to translate its dialogues. Any dialogue line which contains an id defined will be translated to the current locale if a translation is available.

In case there is no translation for the id provided, the interpreter will return the default line.


## Dialogue folder and organisation

By default, the interpreter will look for files under `res://dialogues/`. In case you want to specify a different default folder, you need to change the configuration in `Project > Project Settings > Dialogue > Source Folder`.

Alternatively, you can use the full path when loading dialogues:

```gdscript
var dialogue = Bonnie.new()

dialogue.load_dialogue("res://samples/banana.bonnie")

```

## Examples

You can find usage examples on [/example/](./example/) folder.


