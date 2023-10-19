CC=gcc
FLEX=flex
BISON=bison

# Dependency Tree
splc: syntax.tab.c lex.yy.c
	$(CC) syntax.tab.c -lfl -ly -o bin/splc
syntax.tab.c: syntax.y
	$(BISON) -d syntax.y
lex.yy.c: lex.l
	$(FLEX) lex.l

.PHONY: clean
clean:
	rm -f lex.yy.c syntax.tab.c syntax.tab.h bin/splc
