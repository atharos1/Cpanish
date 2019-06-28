all:
	yacc -d yacc.y
	lex lex.l
	gcc -o compiler y.tab.c lex.yy.c node.c

clean:
	rm compiler lex.yy.c y.tab.c y.tab.h