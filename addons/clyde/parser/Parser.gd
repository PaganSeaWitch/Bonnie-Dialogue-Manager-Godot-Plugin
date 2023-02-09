class_name Parser
extends RefCounted

var lexer : Lexer = Lexer.new()
var miscNodeParser : MiscNodeParser = MiscNodeParser.new()

func parse(doc) -> DocumentNode:
	var tokenWalker = TokenWalker.new()
	tokenWalker.setLexer(lexer.init(doc))

#	var l = Syntax.new()
#	print(l.init(doc).get_all())

	var result : DocumentNode = miscNodeParser._document(tokenWalker)
	if tokenWalker.peek():
		tokenWalker.consume(TokenArray.eof)

	return result
