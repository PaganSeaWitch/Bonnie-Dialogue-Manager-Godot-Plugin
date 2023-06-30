# Changelog

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

## 8.0.0 (2023-06-29)
- Changed file extension from .clyde to .superclyde

### Breaking Changes
- All files previouslly with the extension .clyde should be changed to .superclyde. Also remove old imports cuz idk those get deleted.

## 7.0.1 (2023-06-29)
- Fixed memory leak

## 7.0.0 (2023-06-26)
- New keyword `req` that goes above blocks and signifies that the identifier or logic block following it it gets checked in order to access the block.
- Fixed functionality of random blocks.
- Fallack blocks cannot use `req` keyword.
- Fall black blocks will now always be the last blocks to be randomly chosen.
- Some minor aesthetic changes to the way ClydeNode's print. 

### Breaking Changes
- you can no longer start a line with `req `.

## 6.1.1 (2023-06-16)
- Fixed plugin so it now works

## 6.1.0 (2023-06-12)
- Took (stole) code from [Dialogue Manager](https://github.com/nathanhoad/godot_dialogue_manager) to allow Clyde files to be edited in Editor! Try it out!

## 6.0.0 (2023-06-06)
- New output visualizer that makes it easy to understand how your clyde file is being turned into nodes.
- Changed Dependent Logic blocks from `[]` to `{[]}`
- Added new `bb_code_before_line` member to `LineNode` 
	- Now all bb codes in lines (NOT Options) is given within the `LineNode` member `bb_code_before_line` rather then just in `value`. This will make it easier to intergrate bb code into your dialogue without having to parse them manually.

## 5.0.0 (2023-05-31)

- Add Dependent Logic blocks for writing intra line logic. 
	- Dependent Logic blocks are siginified with `[ ]` brackets and can be used in lines and variations but not option labels. For more information, check language doc.

### Breaking Changes

- as `[ ]` have now become special characters, they cannot be used without \\\ in front of them.

Old way:
```
[ this is a generic line]
```
New way:
```
\\[ this is a generic line \\]
```

## 4.0.0 (2023-04-12)

- Implemented the entire project in Classes
- Added ability to randomly select blocks


## 3.2.0 (2022-08-25)

### Added

- Implemented support for id suffixes. `dialogue line $id&variable_1&variable_2`.
- Id Suffix Lookup Separator project setttings. `Project > Project Settings > General > Dialogue > Id Suffix Lookup Separator`.

### Fixed
- Remove prop check warning in Output console

## 3.1.0

### Added

- Dialogue source folder project setttings. `Project > Project Settings > General > Dialogue > Source Folder`.
  When only the file name is provided, the interpreter will look for files in the folder set on `dialogue/source_folder`.

### Fixed

- Standalone `{set a}` would pass parser, but break on interpreter. Now, this is equivalent to `{ set a = true }`.
- Fix inconsistencies with logic blocks in tab indented files.

## 3.0.0 (2021-11-22)

### Breaking Changes

- Options won´t print first line as before.
- Brackets (`[]`) used for display-only options are not supported anymore.
- To reproduce previous behaviour, options should contain the new display-option symbol (`=`)

Here is a sample on how to fix your dialogues for this new version:

Old way:
```
+ This will be displayed
* This will be displayed
> This will be displayed

+ [This won't be displayed]
  some text...
* [This won't be displayed]
  some text...
> [This won't be displayed]
  some text...
```
New way:
```
+= This will be displayed
*= This will be displayed
>= This will be displayed

+ This won't be displayed
  some text...
* This won't be displayed
  some text...
> This won't be displayed
  some text...
```

### Changed

- Changed options default behaviour. (check breaking changes)

### Thanks

Thanks to @jcandres and @verillious for suggestions and input.

## 2.0.1 (2021-11-04)

### Fixed

- Used Options and Variations were not loaded correctly after loading previously stringified internal memory.

There is a known related issue with variables that will be fixed in the next major version. Variable names should be string,
but currently their type is not validated. If you define a variable with a number as name, you will only be able to recover it
as string. i.e `dialogue.set_variable(1, "blah")`, after persistence will only be available through `dialogue.get_variable("1")`.

### Thanks

Thanks to @jcandres for spotting this issue.

## 2.0.0 (2021-10-21)

### Breaking Changes

Dialogues starting with single quotes will escape especial characters.

For example:
```
'This is a #quoted text'
```
Would previously return:
```
TEXT: 'this is a
TAG:  quoted
TEXT: text'
```
Now it returns:
```
TEXT: This is a #quoted text
```

### Changed

- support single quotes for logic block string literals and escaping dialogues.
	- `{ set string_literal = 'valid string' }`
	- `'This is a valid escaped dialogue line # $ '`

### Thanks

Thanks to @verillious for suggesting and implementing these changes.

## 1.0.2 (2021-06-04)

### Added

- Condition blocks before line can use the "when" keyword.

### Fixed

- Diverts support conditional blocks before and after line

## 1.0.1 (2021-05-09)

### Fixed

- Extend scripts from `Reference` instead of `Node` to prevent memory leaks.

### Thanks

Thanks to Enes Yesilyurt (@Tols-Toy) for spotting the memory leak and for suggesting a fix for it.

## 1.0.0 (2021-02-18)

Initial release

### Added

- Importer
- Interpreter
