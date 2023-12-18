VPATH=src

CC=g++
FLEX=flex
BISON=bison
SRC=src

# Dependency Tree
splc: syntax.tab.* lex.yy.c
	$(CC) $(SRC)/syntax.tab.c -ll -std=c++17 -o bin/splc
	@chmod +x bin/splc
lex.yy.c: lex.l
	$(FLEX) -o $(SRC)/lex.yy.c $(SRC)/lex.l 
syntax.tab.*: syntax.y
	$(BISON) -o $(SRC)/syntax.tab.c -d $(SRC)/syntax.y

.PHONY: clean

clean:
	@rm -rf **/lex.yy.c **/syntax.tab.c **/syntax.tab.h bin/splc **/irsim.log
