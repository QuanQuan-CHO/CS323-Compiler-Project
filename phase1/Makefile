CC=gcc
FLEX=flex
BISON=bison

# Dependency Tree
splc: syntax.tab.* lex.yy.c
	$(CC) syntax.tab.c -ll -ly -o bin/splc
lex.yy.c: lex.l
	$(FLEX) lex.l
syntax.tab.*: syntax.y
	$(BISON) -d syntax.y

lexer: syntax.tab.* lex.yy.c  # For debugging lex.l
	$(CC) lex.yy.c -ll -o lexer

.PHONY: clean
clean:
	rm -f lex.yy.c syntax.tab.c syntax.tab.h lexer bin/splc
