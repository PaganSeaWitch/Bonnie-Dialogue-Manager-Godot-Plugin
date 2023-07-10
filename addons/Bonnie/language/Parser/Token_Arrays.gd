class_name TokenArray
extends RefCounted

const expected  : Array[String] = [
	Syntax.TOKEN_EOF,
	Syntax.TOKEN_SPEAKER,
	Syntax.TOKEN_TEXT,
	Syntax.TOKEN_OPTION,
	Syntax.TOKEN_STICKY_OPTION,
	Syntax.TOKEN_FALLBACK_OPTION,
	Syntax.TOKEN_DIVERT,
	Syntax.TOKEN_DIVERT_PARENT,
	Syntax.TOKEN_BRACKET_OPEN,
	Syntax.TOKEN_PLACEMENT_INDEPENENT_OPEN,
	Syntax.TOKEN_LINE_BREAK,
	Syntax.TOKEN_BLOCK, 
	Syntax.TOKEN_RANDOM_BLOCK, 
	Syntax.TOKEN_RANDOM_FALLBACK_BLOCK, 
	Syntax.TOKEN_RANDOM_STICKY_BLOCK,
	Syntax.TOKEN_KEYWORD_BLOCK_REQ,
	Syntax.TOKEN_PLACEMENT_DEPENENT_OPEN,
	Syntax.TOKEN_BEGINNING_BB_CODE_OPEN,
	Syntax.TOKEN_ENDING_BB_CODE_OPEN
]

const acceptable_next : Array[String] = [
	Syntax.TOKEN_SPEAKER,
	Syntax.TOKEN_TEXT,
	Syntax.TOKEN_OPTION,
	Syntax.TOKEN_STICKY_OPTION,
	Syntax.TOKEN_FALLBACK_OPTION,
	Syntax.TOKEN_DIVERT,
	Syntax.TOKEN_DIVERT_PARENT,
	Syntax.TOKEN_BRACKET_OPEN,
	Syntax.TOKEN_PLACEMENT_INDEPENENT_OPEN,
	Syntax.TOKEN_PLACEMENT_DEPENENT_OPEN,
	Syntax.TOKEN_LINE_BREAK,
	Syntax.TOKEN_BEGINNING_BB_CODE_OPEN, 
	Syntax.TOKEN_ENDING_BB_CODE_OPEN
]


const options_acceptable_next  : Array[String] = [Syntax.TOKEN_SPEAKER, 
	Syntax.TOKEN_TEXT, Syntax.TOKEN_INDENT, 
	Syntax.TOKEN_ASSIGN, Syntax.TOKEN_PLACEMENT_INDEPENENT_OPEN]


const operators_and_bracket_close  : Array[String] = [
	Syntax.TOKEN_BRACKET_CLOSE,
	Syntax.TOKEN_ASSIGN,
	Syntax.TOKEN_ASSIGN_SUM,
	Syntax.TOKEN_ASSIGN_SUB,
	Syntax.TOKEN_ASSIGN_MULT,
	Syntax.TOKEN_ASSIGN_DIV,
	Syntax.TOKEN_ASSIGN_POW,
	Syntax.TOKEN_ASSIGN_MOD ]


const operator_literals : Array[String]= [
		Syntax.TOKEN_IDENTIFIER,
		Syntax.TOKEN_NOT,
		Syntax.TOKEN_NUMBER_LITERAL,
		Syntax.TOKEN_STRING_LITERAL,
		Syntax.TOKEN_BOOLEAN_LITERAL,
		Syntax.TOKEN_NULL_TOKEN ]


const operator_assignments : Array[String] =[
		Syntax.TOKEN_ASSIGN,
	Syntax.TOKEN_ASSIGN_SUM,
	Syntax.TOKEN_ASSIGN_SUB,
	Syntax.TOKEN_ASSIGN_MULT,
	Syntax.TOKEN_ASSIGN_DIV,
	Syntax.TOKEN_ASSIGN_POW,
	Syntax.TOKEN_ASSIGN_MOD ]


const operator_mathamatic_symbols : Array[String] =[
		Syntax.TOKEN_AND,
	Syntax.TOKEN_OR,
	Syntax.TOKEN_EQUAL,
	Syntax.TOKEN_NOT_EQUAL,
	Syntax.TOKEN_GREATER,
	Syntax.TOKEN_LESS,
	Syntax.TOKEN_GE,
	Syntax.TOKEN_LE,
	Syntax.TOKEN_PLUS,
	Syntax.TOKEN_MINUS,
	Syntax.TOKEN_MOD,
	Syntax.TOKEN_MULT,
	Syntax.TOKEN_DIV,
	Syntax.TOKEN_POWER ]


const block  : Array[String] = [Syntax.TOKEN_BLOCK]

const blocks_and_reqs : Array[String] = [Syntax.TOKEN_BLOCK, 
				Syntax.TOKEN_RANDOM_BLOCK, 
				Syntax.TOKEN_RANDOM_FALLBACK_BLOCK, 
				Syntax.TOKEN_RANDOM_STICKY_BLOCK,
				Syntax.TOKEN_KEYWORD_BLOCK_REQ]

const curly_brace_open  : Array[String] = [Syntax.TOKEN_PLACEMENT_INDEPENENT_OPEN]

const curly_brace_close : Array[String]  = [Syntax.TOKEN_PLACEMENT_INDEPENENT_CLOSE]

const brace_open : Array[String] = [Syntax.TOKEN_PLACEMENT_DEPENENT_OPEN]

const logic_close : Array[String] = [Syntax.TOKEN_PLACEMENT_INDEPENENT_CLOSE,
									Syntax.TOKEN_PLACEMENT_DEPENENT_CLOSE ]

const logic_open : Array[String] = [Syntax.TOKEN_PLACEMENT_INDEPENENT_OPEN,
									Syntax.TOKEN_PLACEMENT_DEPENENT_OPEN]

const brace_close : Array[String] = [Syntax.TOKEN_PLACEMENT_DEPENENT_CLOSE]

const bracket_open : Array[String]  = [Syntax.TOKEN_BRACKET_OPEN]

const bracket_close  : Array[String] = [Syntax.TOKEN_BRACKET_CLOSE]

const dialogue : Array[String]  = [Syntax.TOKEN_SPEAKER, Syntax.TOKEN_TEXT]
const set_trigger : Array[String]  = [Syntax.TOKEN_KEYWORD_SET,
	Syntax.TOKEN_KEYWORD_TRIGGER]

const logical_not : Array[String] = [Syntax.TOKEN_NOT]
const when  : Array[String] = [Syntax.TOKEN_KEYWORD_WHEN]

const lineBreak  : Array[String] = [Syntax.TOKEN_LINE_BREAK]

const text  : Array[String] = [Syntax.TOKEN_TEXT]

const tag_and_id  : Array[String] = [Syntax.TOKEN_LINE_ID, Syntax.TOKEN_TAG]

const indent  : Array[String] = [Syntax.TOKEN_INDENT]

const options  : Array[String] = [Syntax.TOKEN_OPTION, 
	Syntax.TOKEN_STICKY_OPTION, Syntax.TOKEN_FALLBACK_OPTION]

const end : Array[String]  = [Syntax.TOKEN_DEDENT, Syntax.TOKEN_EOF]

const tag : Array[String]  = [Syntax.TOKEN_TAG]

const id_suffixes : Array[String]  = [Syntax.TOKEN_ID_SUFFIX]

const dedent : Array[String]  = [Syntax.TOKEN_DEDENT]

const divert : Array[String]  = [Syntax.TOKEN_DIVERT, Syntax.TOKEN_DIVERT_PARENT]

const bb_code_open : Array[String] = [Syntax.TOKEN_BEGINNING_BB_CODE_OPEN, Syntax.TOKEN_ENDING_BB_CODE_OPEN]

const bb_code_close : Array[String] = [Syntax.TOKEN_BB_CODE_CLOSE]

const bb_code : Array[String] = [Syntax.TOKEN_BB_CODE]

const eof : Array[String]  = [Syntax.TOKEN_EOF]

const variations : Array[String]  = [Syntax.TOKEN_VARIATIONS_MODE]

const indent_minus  : Array[String] = [Syntax.TOKEN_INDENT, Syntax.TOKEN_MINUS]

const minus  : Array[String] = [Syntax.TOKEN_MINUS]

const set : Array[String]  = [Syntax.TOKEN_KEYWORD_SET]

const trigger : Array[String]  = [Syntax.TOKEN_KEYWORD_TRIGGER]

const comma : Array[String]  = [Syntax.TOKEN_COMMA]

const block_req : Array[String] = [Syntax.TOKEN_KEYWORD_BLOCK_REQ]

const acceptable_req : Array[String] = [Syntax.TOKEN_IDENTIFIER, 
				Syntax.TOKEN_NOT_EQUAL, 
				Syntax.TOKEN_EQUAL, 
				Syntax.TOKEN_PLACEMENT_INDEPENENT_OPEN, Syntax.TOKEN_NOT]

const identifier : Array[String]  = [Syntax.TOKEN_IDENTIFIER]

const block_types : Array[String] = [Syntax.TOKEN_BLOCK, Syntax.TOKEN_RANDOM_BLOCK, 
	Syntax.TOKEN_RANDOM_STICKY_BLOCK, Syntax.TOKEN_RANDOM_FALLBACK_BLOCK]
