class_name SyntaxDictionaries
extends RefCounted

# change word descriptors of logic to the token verison
const logic_descriptive_tokens = {
	"not":Syntax.TOKEN_NOT,
	"and":Syntax.TOKEN_AND,
	"or":Syntax.TOKEN_OR,
	"is":Syntax.TOKEN_EQUAL,
	"isnt":Syntax.TOKEN_NOT_EQUAL,
	"true":Syntax.TOKEN_BOOLEAN_LITERAL,
	"false":Syntax.TOKEN_BOOLEAN_LITERAL,
	"null": Syntax.TOKEN_NULL_TOKEN,
	"set":Syntax.TOKEN_KEYWORD_SET,
	"trigger":Syntax.TOKEN_KEYWORD_TRIGGER,
	"when":Syntax.TOKEN_KEYWORD_WHEN}

const MAX_VALUE_LENGTH : int = 2


# return a token type and length of token for logic symbol
const logic_symbol_tokens_operators_with_side_effects = {
	'==':{"token" :Syntax.TOKEN_EQUAL, "length" : 2},
	'!=':{"token" :Syntax.TOKEN_NOT_EQUAL, "length" : 2},
	'&&':{"token" :Syntax.TOKEN_AND, "length" : 2},
	'||':{"token" :Syntax.TOKEN_OR,"length" : 2},
	'<=':{"token" :Syntax.TOKEN_LE, "length" :2},
	'>=':{"token" :Syntax.TOKEN_GE, "length" :2},
	'<' :{"token" :Syntax.TOKEN_LESS,"length" : 1},
	'>' :{"token" :Syntax.TOKEN_GREATER,"length" : 1}}


# return a token type and length of a token for logic sysmbol
const logic_symbol_tokens_side_operator_without_side_effects = {
	'=' :{"token" :Syntax.TOKEN_ASSIGN,"length" :1},
	'-=':{"token" :Syntax.TOKEN_ASSIGN_SUB, "length" :2},
	'+=':{"token" :Syntax.TOKEN_ASSIGN_SUM,"length" :2},
	'*=':{"token" :Syntax.TOKEN_ASSIGN_MULT,"length" : 2},
	'/=':{"token" :Syntax.TOKEN_ASSIGN_DIV,"length" : 2},
	'^=':{"token" :Syntax.TOKEN_ASSIGN_POW,"length" : 2},
	'%=':{"token" :Syntax.TOKEN_ASSIGN_MOD,"length" :2},
	'+' :{"token" :Syntax.TOKEN_PLUS, "length" :1},
	'-' :{"token" :Syntax.TOKEN_MINUS,"length" : 1},
	'*' :{"token" :Syntax.TOKEN_MULT,"length" : 1},
	'/' :{"token" :Syntax.TOKEN_DIV,"length" :1},
	'^' :{"token" :Syntax.TOKEN_POWER, "length" :1},
	'%' :{"token" :Syntax.TOKEN_MOD, "length" :1},
	',' :{"token" :Syntax.TOKEN_COMMA,"length" :1}}


const random_block_types = {
	Syntax.TOKEN_RANDOM_BLOCK: 'once',
	Syntax.TOKEN_RANDOM_FALLBACK_BLOCK : 'fallback',
	Syntax.TOKEN_RANDOM_STICKY_BLOCK: 'sticky'}


const option_types = {
	Syntax.TOKEN_OPTION: 'once',
	Syntax.TOKEN_STICKY_OPTION: 'sticky',
	Syntax.TOKEN_FALLBACK_OPTION: 'fallback' }

