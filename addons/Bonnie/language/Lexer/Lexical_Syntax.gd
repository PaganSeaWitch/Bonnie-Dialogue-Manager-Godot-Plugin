class_name Syntax
extends RefCounted

# Tokens
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
const TOKEN_RANDOM_STICKY_BLOCK = "RANDOM_STICKY_BLOCK"
const TOKEN_RANDOM_FALLBACK_BLOCK = "RANDOM_FALLBACK_BLOCK"
const TOKEN_RANDOM_BLOCK = "RANDOM_BLOCK"
const TOKEN_DIVERT = "DIVERT"
const TOKEN_DIVERT_PARENT = "DIVERT_PARENT"
const TOKEN_VARIATIONS_MODE = "VARIATIONS_MODE"
const TOKEN_MINUS = "MINUS"
const TOKEN_PLUS = "PLUS"
const TOKEN_MULT = "MULTIPLY"
const TOKEN_DIV = "DIVIDE"
const TOKEN_POWER = "POWER"
const TOKEN_MOD = "MOD"
const TOKEN_PLACEMENT_INDEPENENT_OPEN = "{"
const TOKEN_PLACEMENT_INDEPENENT_CLOSE = "}"
const TOKEN_PLACEMENT_DEPENENT_OPEN = "[{"
const TOKEN_PLACEMENT_DEPENENT_CLOSE = "}]"
const TOKEN_BEGINNING_BB_CODE_OPEN = "["
const TOKEN_BB_CODE_CLOSE = "]"
const TOKEN_ENDING_BB_CODE_OPEN = "[/"
const TOKEN_BB_CODE = "BB_CODE"

const TOKEN_AND = "AND"
const TOKEN_OR = "OR"
const TOKEN_NOT ="NOT"
const TOKEN_EQUAL = "LOGICAL_EQUAL"
const TOKEN_NOT_EQUAL = "LOGICAL_NOT_EQUAL"
const TOKEN_GE = "GREATER_OR_EQUAL_THEN"
const TOKEN_LE = "LESS_OR_EQUAL_THEN"
const TOKEN_GREATER = "GREATER_THEN"
const TOKEN_LESS = "LESS_THEN"
const TOKEN_NUMBER_LITERAL = "number"
const TOKEN_NULL_TOKEN = "null"
const TOKEN_BOOLEAN_LITERAL = "boolean"
const TOKEN_STRING_LITERAL = "string"
const TOKEN_IDENTIFIER = "identifier"
const TOKEN_KEYWORD_SET = "set"
const TOKEN_KEYWORD_BLOCK_REQ = "req"
const TOKEN_KEYWORD_TRIGGER = "trigger"
const TOKEN_KEYWORD_WHEN = "when"
const TOKEN_ASSIGN = "ASSIGN"
const TOKEN_ASSIGN_SUM = "SUM_ASSIGN"
const TOKEN_ASSIGN_SUB = "SUBTRACTION_ASSIGN"
const TOKEN_ASSIGN_DIV = "DIVISION_ASSIGN"
const TOKEN_ASSIGN_MULT = "MULITPLICATION_ASSIGN"
const TOKEN_ASSIGN_POW = "POWER_ASSIGN"
const TOKEN_ASSIGN_MOD = "MOD_ASSIGN"
const TOKEN_COMMA = ","
const TOKEN_LINE_BREAK = "line break"


# Modes
const MODE_DEFAULT = "DEFAULT"
const MODE_OPTION = "OPTION"
const MODE_QSTRING = "QSTRING"
const MODE_LOGIC = "LOGIC"
const MODE_VARIATIONS = "VARIATIONS"
const MODE_BB_CODE = "BB_CODE"
const MODE_BLOCK_REQ = "BLOCK_REQ"
# Sequence Modes
const VARIATIONS_MODE_SEQUENCE = "sequence"
const VARIATIONS_MODE_SHUFFLE = "shuffle"
const VARIATIONS_MODE_ONCE = "once"
const VARIATIONS_MODE_CYCLE = "cycle"
const VARIATIONS_MODE_SHUFFLE_SEQUENCE = "shuffle sequence"
const VARIATIONS_MODE_SHUFFLE_ONCE = "shuffle once"
const VARIATIONS_MODE_SHUFFLE_CYCLE = "shuffle cycle"

const CACHE_PATH = "user://super_clyde_cache.json"
const USER_CONFIG_PATH = "user://super_clyde_user_config.json"
# hints for tokens
const token_hints = {
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
	TOKEN_PLACEMENT_INDEPENENT_OPEN: '{',
	TOKEN_PLACEMENT_INDEPENENT_CLOSE: '}',
	TOKEN_PLACEMENT_DEPENENT_OPEN: '[',
	TOKEN_PLACEMENT_DEPENENT_CLOSE: ']',
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

const keywords = [
	'is', 'isnt', 'or', 'and', 'not', 'true', 'false', 'null',
	'set', 'trigger', 'when'
]

const variations_modes = [VARIATIONS_MODE_SEQUENCE, VARIATIONS_MODE_ONCE, 
	VARIATIONS_MODE_CYCLE, VARIATIONS_MODE_SHUFFLE, 
	VARIATIONS_MODE_SHUFFLE_SEQUENCE,
	VARIATIONS_MODE_SHUFFLE_ONCE, VARIATIONS_MODE_SHUFFLE_CYCLE ]

static func translate(string: String) -> String:
	var language: String = TranslationServer.get_tool_locale().substr(0, 2)
	var translations_path: String = "res://addons/Bonnie/l10n/%s.po" % language
	var fallback_translations_path: String = "res://addons/Bonnie/l10n/en.po"
	var translations: Translation = load(translations_path if FileAccess.file_exists(translations_path) else fallback_translations_path)
	return translations.get_message(string)



