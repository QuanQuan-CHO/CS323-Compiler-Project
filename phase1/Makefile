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
	@mkdir -p out
	@bin/splc test-base/test_1_r01.spl > out/my_test_1_r01.out
	diff out/my_test_1_r01.out test-base/test_1_r01.out
	@bin/splc test-base/test_1_r02.spl > out/my_test_1_r02.out
	diff out/my_test_1_r02.out test-base/test_1_r02.out
	@bin/splc test-base/test_1_r03.spl > out/my_test_1_r03.out
	diff out/my_test_1_r03.out test-base/test_1_r03.out
	@bin/splc test-base/test_1_r04.spl > out/my_test_1_r04.out
	diff out/my_test_1_r04.out test-base/test_1_r04.out
	@bin/splc test-base/test_1_r05.spl > out/my_test_1_r05.out
	diff out/my_test_1_r05.out test-base/test_1_r05.out
	@bin/splc test-base/test_1_r06.spl > out/my_test_1_r06.out
	diff out/my_test_1_r06.out test-base/test_1_r06.out
	@bin/splc test-base/test_1_r07.spl > out/my_test_1_r07.out
	diff out/my_test_1_r07.out test-base/test_1_r07.out
	@bin/splc test-base/test_1_r08.spl > out/my_test_1_r08.out
	diff out/my_test_1_r08.out test-base/test_1_r08.out
	@bin/splc test-base/test_1_r09.spl > out/my_test_1_r09.out
	diff out/my_test_1_r09.out test-base/test_1_r09.out
	@bin/splc test-base/test_1_r10.spl > out/my_test_1_r10.out
	diff out/my_test_1_r10.out test-base/test_1_r10.out
	@bin/splc test-base/test_1_r11.spl > out/my_test_1_r11.out
	diff out/my_test_1_r11.out test-base/test_1_r11.out
	@bin/splc test-base/test_1_r12.spl > out/my_test_1_r12.out
	diff out/my_test_1_r12.out test-base/test_1_r12.out
clean:
	@rm -rf lex.yy.c syntax.tab.c syntax.tab.h lexer bin out