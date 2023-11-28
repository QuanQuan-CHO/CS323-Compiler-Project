SHELL=/bin/bash
CC=g++
FLEX=flex
BISON=bison

# Dependency Tree
splc: syntax.tab.* lex.yy.c
	@mkdir -p bin
	$(CC) syntax.tab.c err.cpp check.cpp -ll -std=c++17 -o bin/splc
	@chmod +x bin/splc
lex.yy.c: lex.l
	$(FLEX) lex.l
syntax.tab.*: syntax.y
	$(BISON) -d syntax.y

lexer: syntax.tab.* lex.yy.c  # For debugging lex.l
	$(CC) lex.yy.c -ll -o lexer

.PHONY: test clean
test: splc
	@echo -e '\nStep1: Test base cases'

	@echo -e '\nStep2: Test self-written cases'

	@echo -e '\nStep3: Test extra cases'

	@echo "----------test success----------"

clean:
	@rm -rf lex.yy.c syntax.tab.c syntax.tab.h lexer bin **/*.myout
