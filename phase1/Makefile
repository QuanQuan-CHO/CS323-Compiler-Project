CC=gcc
FLEX=flex
BISON=bison

# Dependency Tree
splc: syntax.tab.* lex.yy.c
	$(CC) syntax.tab.c -lfl -ly -o bin/splc
lex.yy.c: lex.l syntax.tab.*
	$(FLEX) lex.l
syntax.tab.*: syntax.y
	$(BISON) -d syntax.y

.PHONY: clean
clean:
	rm -f lex.yy.c syntax.tab.c syntax.tab.h bin/splc
