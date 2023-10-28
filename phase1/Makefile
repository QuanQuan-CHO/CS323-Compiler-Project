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
	@bin/splc test-base/test_1_r01.spl > test-base/test_1_r01.myout
	diff test-base/test_1_r01.myout test-base/test_1_r01.out
	@bin/splc test-base/test_1_r02.spl > test-base/test_1_r02.myout
	diff test-base/test_1_r02.myout test-base/test_1_r02.out
	@bin/splc test-base/test_1_r03.spl > test-base/test_1_r03.myout
	diff test-base/test_1_r03.myout test-base/test_1_r03.out
	@bin/splc test-base/test_1_r04.spl > test-base/test_1_r04.myout
	diff test-base/test_1_r04.myout test-base/test_1_r04.out
	@bin/splc test-base/test_1_r05.spl > test-base/test_1_r05.myout
	diff test-base/test_1_r05.myout test-base/test_1_r05.out
	@bin/splc test-base/test_1_r06.spl > test-base/test_1_r06.myout
	diff test-base/test_1_r06.myout test-base/test_1_r06.out
	@bin/splc test-base/test_1_r07.spl > test-base/test_1_r07.myout
	diff test-base/test_1_r07.myout test-base/test_1_r07.out
	@bin/splc test-base/test_1_r08.spl > test-base/test_1_r08.myout
	diff test-base/test_1_r08.myout test-base/test_1_r08.out
	@bin/splc test-base/test_1_r09.spl > test-base/test_1_r09.myout
	diff test-base/test_1_r09.myout test-base/test_1_r09.out
	@bin/splc test-base/test_1_r10.spl > test-base/test_1_r10.myout
	diff test-base/test_1_r10.myout test-base/test_1_r10.out
	@bin/splc test-base/test_1_r11.spl > test-base/test_1_r11.myout
	diff test-base/test_1_r11.myout test-base/test_1_r11.out
	@bin/splc test-base/test_1_r12.spl > test-base/test_1_r12.myout
	diff test-base/test_1_r12.myout test-base/test_1_r12.out
clean:
	@rm -rf lex.yy.c syntax.tab.c syntax.tab.h lexer bin **/*.myout
