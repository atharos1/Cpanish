all:
	cd ./Compiler; \
	yacc -d yacc.y; \
	lex lex.l; \
	gcc -o ../cspanish y.tab.c lex.yy.c node.c

clean:
	rm -f cspanish; \
	cd ./Compiler; \
	rm -f lex.yy.c; \
	rm -f y.tab.c; \
	rm -f y.tab.h;