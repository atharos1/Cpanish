all:
	yacc -d yacc.y
	lex lex.l
	gcc -o comp y.tab.c lex.yy.c node.c

clean:
	rm comp lex.yy.c y.tab.c y.tab.h