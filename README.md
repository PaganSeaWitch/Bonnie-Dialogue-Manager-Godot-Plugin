# Bonnie Dialogue Plugin for Godot

<p align="center"><img src="icon.png" alt=/></p>

Importer and interpreter for Bonnie based on [Clyde Dialogue Language](https://github.com/viniciusgerevini/clyde). A plugin for that can be found [here](https://github.com/viniciusgerevini/godot-clyde-dialogue). Completely written in GDScript. No external dependencies. Bonnie is entirely backwards compatible with Clyde baring some breaking changes which can be found in the changelog. 

> Bonnie is a language for writing game dialogues. It supports branching dialogues, translations and interfacing with your game through variables and events. now with (shitty) [videos](https://www.youtube.com/playlist?list=PL5jCxg8GFqU4noTnHmy_O1lISN8bFMK8Z)!

```
The Wolf:   Jimmie – lead the way, boys – get to work.
Vincent:    A "please" would be nice.
The Wolf:   Come again?
Vincent:    I said a "please" would be nice.
The Wolf:   Get it straight, Buster. I'm not here to
            say "please."I'm here to tell you what to
            do. And if self-preservation is an
            instinct you possess, you better f****n'
            do it and do it quick. I'm here to help.
            If my help's not appreciated, lotsa luck
            gentlemen.
Jules:      It ain't that way, Mr. Wolf. Your help is
            definitely appreciated.
Vincent:    I don't mean any disrespect. I just don't
            like people barkin' orders at me.
The Wolf:   If I'm curt with you, it's because time is
            a factor. I think fast, I talk fast, and I
            need you guys to act fast if you want to
            get out of this. So pretty please, with
            sugar on top, clean the f****n' car.
```

## Usage

The importer automatically imports `.bonnie` files to be used with the interpreter. This improves performance, as the dialogue is parsed beforehand.

Check [USAGE.md](./USAGE.md) for how to use the interpreter.

You can find a simple usage example on [/example/example.gd](./example/example.gd)

For more about how to write dialogues using Bonnie, check [LANGUAGE.md](https://github.com/PaganSeaWitch/Super-Clyde-Godot-Plugin/blob/master/LANGUAGE.md)

You now have the option to edit Clyde files in the Godot engine itself, helping streamline usage to a single editor. 

## Installation

Follow Godot's [installing plugins guide ]( https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html).


## Settings

Go to `Project > Project Settings > General > Dialogue`.

| Field                   | Description |
| ----------------------- | ----------- |
| Source Folder: | Default folder where the interpreter will look for `.bonnie` files when just the filename is provided. Default: `res://dialogues/` |
| Id Suffix Lookup Separator: | When using id suffixes, this is the separator used in the translation keys. Default. `&`.|
