class_name TokenArray
extends RefCounted

const expected = [
	Syntax.TOKEN_EOF,
	Syntax.TOKEN_SPEAKER,
	Syntax.TOKEN_TEXT,
	Syntax.TOKEN_OPTION,
	Syntax.TOKEN_STICKY_OPTION,
	Syntax.TOKEN_FALLBACK_OPTION,
	Syntax.TOKEN_DIVERT,
	Syntax.TOKEN_DIVERT_PARENT,
	Syntax.TOKEN_BRACKET_OPEN,
	Syntax.TOKEN_BRACE_OPEN,
	Syntax.TOKEN_LINE_BREAK,
	Syntax.TOKEN_BLOCK
]

const acceptable_next = [
	Syntax.TOKEN_SPEAKER,
	Syntax.TOKEN_TEXT,
	Syntax.TOKEN_OPTION,
	Syntax.TOKEN_STICKY_OPTION,
	Syntax.TOKEN_FALLBACK_OPTION,
	Syntax.TOKEN_DIVERT,
	Syntax.TOKEN_DIVERT_PARENT,
	Syntax.TOKEN_BRACKET_OPEN,
	Syntax.TOKEN_BRACE_OPEN,
	Syntax.TOKEN_LINE_BREAK,
]
const optionsAcceptableNext = [Syntax.TOKEN_SPEAKER, Syntax.TOKEN_TEXT, Syntax.TOKEN_INDENT, Syntax.TOKEN_ASSIGN, Syntax.TOKEN_BRACE_OPEN]
const block = [Syntax.TOKEN_BLOCK]

const braceOpen = [Syntax.TOKEN_BRACE_OPEN]

const bracketOpen = [Syntax.TOKEN_BRACKET_OPEN]

const bracketClose = [Syntax.TOKEN_BRACKET_CLOSE]

const dialogue = [Syntax.TOKEN_SPEAKER, Syntax.TOKEN_TEXT]

const setTrigger = [Syntax.TOKEN_KEYWORD_SET, Syntax.TOKEN_KEYWORD_TRIGGER]

const when = [Syntax.TOKEN_KEYWORD_WHEN]

const lineBreak = [Syntax.TOKEN_LINE_BREAK]

const text = [Syntax.TOKEN_TEXT]

const tagAndId = [Syntax.TOKEN_LINE_ID, Syntax.TOKEN_TAG]

const indent = [Syntax.TOKEN_INDENT]

const options = [Syntax.TOKEN_OPTION, Syntax.TOKEN_STICKY_OPTION, Syntax.TOKEN_FALLBACK_OPTION]

const end = [Syntax.TOKEN_DEDENT, Syntax.TOKEN_EOF]

const tag = [Syntax.TOKEN_TAG]

const idSuffixes = [Syntax.TOKEN_ID_SUFFIX]

const dedent = [Syntax.TOKEN_DEDENT]

const divert = [Syntax.TOKEN_DIVERT, Syntax.TOKEN_DIVERT_PARENT]

const eof = [Syntax.TOKEN_EOF]

const variations = [Syntax.TOKEN_VARIATIONS_MODE]

const indentMinus = [Syntax.TOKEN_INDENT, Syntax.TOKEN_MINUS]

const minus = [Syntax.TOKEN_MINUS]

const set = [Syntax.TOKEN_KEYWORD_SET]

const trigger = [Syntax.TOKEN_KEYWORD_TRIGGER]

const comma = [Syntax.TOKEN_COMMA]

const braceClose = [Syntax.TOKEN_BRACE_CLOSE]

const identifier = [Syntax.TOKEN_IDENTIFIER]
