all:
	cd ./Compiler; \
	yacc -d yacc.y; \
	lex lex.l; \
	gcc -o ../cpanish y.tab.c lex.yy.c node.c operations.c

clean:
	rm -f cpanish; \
	cd ./Compiler; \
	rm -f lex.yy.c; \
	rm -f y.tab.c; \
	rm -f y.tab.h;