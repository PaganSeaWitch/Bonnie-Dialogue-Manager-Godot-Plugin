# Introduction

Bonnie is an easy language to modify. The process involves some knowlege of code and gdscript but nothing too complicated beyond that. 
Essentially we will create new lexer, parser and interpreter files as well as a new node file if necessary. 

## Step 1: Test Cases

Before modifying the actual code of Bonnie, one should create new Test cases for this functionality in order to test whether it is working.
Making Good test cases can be difficult but at least cover the base case of the new functionality; what Bonnie will take in and what will it output. 
Bonnie relies on the test case tools of GUT and you can learn more about that [here](https://github.com/bitwes/Gut).
but for easy set up, create a file with the prefix test_ extending test.gd and every test function begining with the prefix test_.


## Step 2: (Optional) Create new Node

If the new functionality you wish to implement requires a new node, you should create a file in the Nodes folder that extends `BonnieNode` and has a unique class name. 
The file should also implmenet the `get_node_class()` function which returns a string of the class name. The properites of the node should then be defined as much as they can be. 


## Step 3: Update the syntax

create a new token in the lexical_snytax file that represents what gets consumed in ur new functionality.

## Step 3: Create new Lexer

Create a new Lexer sub file in the Lexer folder that extends MiscLexer. 
The functions within this file should not deal with checking for the symbol that causes this function to occur.
In other words, if your using the symbol ';' then you shouldn't search for that symbol in the function that handles that symbol.

Once you've written your function, add the symbol inside of the `_get_next_tokens()` function and add your lexer to the Lexer file and initialize it in the init file.


## Step 4: Create new Parser

Create a new Parser sub file in the Parser Flder that extends MiscParser.
The functions within this file should consume the token/s that you craeted in step 3. it then creates the node you created in step 2 or a another node if you didnt create a new one.


## Step 5: Create new Interpreter 

Create a new interpreter sub file in the Interpreter folder that extends MiscInterpreter.
The functions within this file should take the node that was created from the parser and determined what should occur and whether it should return something. Keep in mind what is returned should be able to be used as dialogue. 
