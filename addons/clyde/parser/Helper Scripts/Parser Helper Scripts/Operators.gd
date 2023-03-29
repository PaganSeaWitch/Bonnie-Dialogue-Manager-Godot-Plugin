class_name ParserOperators
extends RefCounted


const operators : Dictionary = {
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
