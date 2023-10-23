CC=gcc
FLEX=flex
BISON=bison

# Dependency Tree
splc: syntax.tab.* lex.yy.c
	$(CC) syntax.tab.c -ll -o bin/splc
	@chmod +x bin/splc
lex.yy.c: lex.l
	$(FLEX) lex.l
syntax.tab.*: syntax.y
	$(BISON) -d syntax.y

lexer: syntax.tab.* lex.yy.c  # For debugging lex.l
	$(CC) lex.yy.c -ll -o lexer

.PHONY: clean
clean:
	@rm -rf lex.yy.c syntax.tab.c syntax.tab.h lexer bin
