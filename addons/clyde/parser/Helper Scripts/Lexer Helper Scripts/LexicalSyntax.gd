class_name Syntax
extends RefCounted

const TOKEN_TEXT = "TEXT"
const TOKEN_INDENT = "INDENT"
const TOKEN_DEDENT = "DEDENT"
const TOKEN_OPTION = "OPTION"
const TOKEN_STICKY_OPTION = "STICKY_OPTION"
const TOKEN_FALLBACK_OPTION = "FALLBACK_OPTION"
const TOKEN_BRACKET_OPEN = "BRACKET_OPEN"
const TOKEN_BRACKET_CLOSE = "BRACKET_CLOSE"
const TOKEN_EOF = "EOF"
const TOKEN_SPEAKER = "SPEAKER"
const TOKEN_LINE_ID = "LINE_ID"
const TOKEN_ID_SUFFIX = "ID_SUFFIX"
const TOKEN_TAG = "TAG"
const TOKEN_BLOCK = "BLOCK"
const TOKEN_DIVERT = "DIVERT"
const TOKEN_DIVERT_PARENT = "DIVERT_PARENT"
const TOKEN_VARIATIONS_MODE = "VARIATIONS_MODE"
const TOKEN_MINUS = "-"
const TOKEN_PLUS = "+"
const TOKEN_MULT = "*"
const TOKEN_DIV = "/"
const TOKEN_POWER = "^"
const TOKEN_MOD = "%"
const TOKEN_BRACE_OPEN = "{"
const TOKEN_BRACE_CLOSE = "}"
const TOKEN_AND = "AND"
const TOKEN_OR = "OR"
const TOKEN_NOT ="NOT"
const TOKEN_EQUAL = "==, is"
const TOKEN_NOT_EQUAL = "!=, isnt"
const TOKEN_GE = ">="
const TOKEN_LE = "<="
const TOKEN_GREATER = "GREATER"
const TOKEN_LESS = "LESS"
const TOKEN_NUMBER_LITERAL = "number"
const TOKEN_NULL_TOKEN = "null"
const TOKEN_BOOLEAN_LITERAL = "boolean"
const TOKEN_STRING_LITERAL = "string"
const TOKEN_IDENTIFIER = "identifier"
const TOKEN_KEYWORD_SET = "set"
const TOKEN_KEYWORD_TRIGGER = "trigger"
const TOKEN_KEYWORD_WHEN = "when"
const TOKEN_ASSIGN = "="
const TOKEN_ASSIGN_SUM = "+="
const TOKEN_ASSIGN_SUB = "-="
const TOKEN_ASSIGN_DIV = "/="
const TOKEN_ASSIGN_MULT = "*="
const TOKEN_ASSIGN_POW = "^="
const TOKEN_ASSIGN_MOD = "%="
const TOKEN_COMMA = ","
const TOKEN_LINE_BREAK = "line break"


const MODE_DEFAULT = "DEFAULT"
const MODE_OPTION = "OPTION"
const MODE_QSTRING = "QSTRING"
const MODE_LOGIC = "LOGIC"
const MODE_VARIATIONS = "VARIATIONS"


const VARIATIONS_MODE_SEQUENCE = "sequence"
const VARIATIONS_MODE_SHUFFLE = "shuffle"
const VARIATIONS_MODE_ONCE = "once"
const VARIATIONS_MODE_CYCLE = "cycle"
const VARIATIONS_MODE_SHUFFLE_SEQUENCE = "shuffle sequence"
const VARIATIONS_MODE_SHUFFLE_ONCE = "shuffle once"
const VARIATIONS_MODE_SHUFFLE_CYCLE = "shuffle cycle"


const _token_hints = {
	TOKEN_TEXT: 'text',
	TOKEN_INDENT: 'INDENT',
	TOKEN_DEDENT: 'DEDENT',
	TOKEN_OPTION: '*',
	TOKEN_STICKY_OPTION: '+',
	TOKEN_FALLBACK_OPTION: '>',
	TOKEN_BRACKET_OPEN: '(',
	TOKEN_BRACKET_CLOSE: ')',
	TOKEN_EOF: 'EOF',
	TOKEN_SPEAKER: '<speaker name>:',
	TOKEN_LINE_ID: '$id',
	TOKEN_ID_SUFFIX: '&id_suffix',
	TOKEN_TAG: '#tag',
	TOKEN_BLOCK: '== <block name>',
	TOKEN_DIVERT: '-> <target name>',
	TOKEN_DIVERT_PARENT: '<-',
	TOKEN_VARIATIONS_MODE: '<variations mode>',
	TOKEN_BRACE_OPEN: '{',
	TOKEN_BRACE_CLOSE: '}',
	TOKEN_AND: '&&, and',
	TOKEN_OR: '||, or',
	TOKEN_NOT:' not, !',
	TOKEN_EQUAL: '==, is',
	TOKEN_NOT_EQUAL: '!=, isnt',
	TOKEN_GE: '>=',
	TOKEN_LE: '<=',
	TOKEN_GREATER: '>',
	TOKEN_LESS: '<',
}

const _keywords = [
	'is', 'isnt', 'or', 'and', 'not', 'true', 'false', 'null',
	'set', 'trigger', 'when'
]

const _variations_modes = [VARIATIONS_MODE_SEQUENCE, VARIATIONS_MODE_ONCE, 
	VARIATIONS_MODE_CYCLE, VARIATIONS_MODE_SHUFFLE, 
	VARIATIONS_MODE_SHUFFLE_SEQUENCE,
	VARIATIONS_MODE_SHUFFLE_ONCE, VARIATIONS_MODE_SHUFFLE_CYCLE ]
