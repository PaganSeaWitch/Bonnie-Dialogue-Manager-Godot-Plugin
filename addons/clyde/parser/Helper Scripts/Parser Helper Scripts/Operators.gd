class_name ParserOperators
extends RefCounted


const operators = {
	Syntax.TOKEN_AND: { "precedence": 1, "associative": 'LEFT' },
	Syntax.TOKEN_OR: { "precedence": 1, "associative": 'LEFT' },
	Syntax.TOKEN_EQUAL: { "precedence": 2, "associative": 'LEFT' },
	Syntax.TOKEN_NOT_EQUAL: { "precedence": 2, "associative": 'LEFT' },
	Syntax.TOKEN_GREATER: { "precedence": 2, "associative": 'LEFT' },
	Syntax.TOKEN_LESS: { "precedence": 2, "associative": 'LEFT' },
	Syntax.TOKEN_GE: { "precedence": 2, "associative": 'LEFT' },
	Syntax.TOKEN_LE: { "precedence": 2, "associative": 'LEFT' },
	Syntax.TOKEN_PLUS: { "precedence": 3, "associative": 'LEFT' },
	Syntax.TOKEN_MINUS: { "precedence": 3, "associative": 'LEFT' },
	Syntax.TOKEN_MOD: { "precedence": 4, "associative": 'LEFT' },
	Syntax.TOKEN_MULT: { "precedence": 5, "associative": 'LEFT' },
	Syntax.TOKEN_DIV: { "precedence": 5, "associative": 'LEFT' },
	Syntax.TOKEN_POWER: { "precedence": 7, "associative": 'RIGHT' },
}

const _assignment_operators = {
	Syntax.TOKEN_ASSIGN: 'assign',
	Syntax.TOKEN_ASSIGN_SUM: 'assign_sum',
	Syntax.TOKEN_ASSIGN_SUB: 'assign_sub',
	Syntax.TOKEN_ASSIGN_MULT: 'assign_mult',
	Syntax.TOKEN_ASSIGN_DIV: 'assign_div',
	Syntax.TOKEN_ASSIGN_POW: 'assign_pow',
	Syntax.TOKEN_ASSIGN_MOD: 'assign_mod',
}

const operator_labels = {
	Syntax.TOKEN_PLUS: 'add',
	Syntax.TOKEN_MINUS: 'sub',
	Syntax.TOKEN_MULT: 'mult',
	Syntax.TOKEN_DIV: 'div',
	Syntax.TOKEN_MOD: 'mod',
	Syntax.TOKEN_POWER: 'pow',
	Syntax.TOKEN_AND: 'and',
	Syntax.TOKEN_OR: 'or',
	Syntax.TOKEN_EQUAL: 'equal',
	Syntax.TOKEN_NOT_EQUAL: 'not_equal',
	Syntax.TOKEN_GREATER: 'greater_than',
	Syntax.TOKEN_LESS: 'less_than',
	Syntax.TOKEN_GE: 'greater_or_equal',
	Syntax.TOKEN_LE: 'less_or_equal',
}

const operator_literals = [
		Syntax.TOKEN_IDENTIFIER,
		Syntax.TOKEN_NOT,
		Syntax.TOKEN_NUMBER_LITERAL,
		Syntax.TOKEN_STRING_LITERAL,
		Syntax.TOKEN_BOOLEAN_LITERAL,
		Syntax.TOKEN_NULL_TOKEN
	]
