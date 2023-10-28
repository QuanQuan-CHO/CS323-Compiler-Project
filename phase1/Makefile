SHELL=/bin/bash
CC=g++
FLEX=flex
BISON=bison

# Dependency Tree
splc: syntax.tab.* lex.yy.c
	@mkdir -p bin
	$(CC) syntax.tab.c -ll -std=c++17 -o bin/splc
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
	for i in {01..12}; do \
		bin/splc test-base/test_1_r$$i.spl > test-base/test_1_r$$i.myout; \
		diff test-base/test_1_r$$i.myout test-base/test_1_r$$i.out; \
		if (($$? != 0)); then \
			echo "-----error case: test_1_r$$i.spl-----"; exit 1; \
		fi; \
	done

	@echo -e '\nStep2: Test self-written cases'
	for i in {1..5}; do \
		bin/splc test/test_12111611_$$i.spl > test/test_12111611_$$i.myout; \
		diff test/test_12111611_$$i.myout test/test_12111611_$$i.out; \
		if (($$? != 0)); then \
			echo "-----error case: test_12111611_r$$i.spl-----"; exit 1; \
		fi; \
	done

	@echo -e '\nStep3: Test extra cases'
	for i in {1..3}; do \
		bin/splc test-ex/test_$$i.spl > test-ex/test_$$i.myout; \
		diff test-ex/test_$$i.myout test-ex/test_$$i.out; \
		if (($$? != 0)); then \
			echo "-----error case: test_$$i.spl-----"; exit 1; \
		fi; \
	done

clean:
	@rm -rf lex.yy.c syntax.tab.c syntax.tab.h lexer bin **/*.myout
