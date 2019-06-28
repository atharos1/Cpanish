%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <ctype.h>
	#include "node.h"

	int yylex();
	void yyerror(char * s);
%}

%union {
	struct Node * node;
	char * value;
}

/* Tokens */
%token t_cadena t_entero asignar reasignar punto
%token<value> cadena entero var_id
%type<node> PROGRAMA LINEA INSTRUCCION DECLARACION ASIGNACION REASIGNACION TIPO EXPRESION
%start PROGRAMA

/* Producciones */
%%

PROGRAMA        : LINEA                             {   $$ = $1;
                                                        printInorder($$); }

LINEA           : LINEA LINEA                       {   $$ = newNode(TYPE_EMPTY, NULL);
                                                        append($$, $1);
                                                        append($$, $2); }
                | INSTRUCCION punto                 {   $$ = newNode(TYPE_EMPTY, NULL);
                                                        append($$, $1);
                                                        append($$, newNode(TYPE_VALUE, ";\n")); }
                ;

INSTRUCCION     : REASIGNACION                      {   $$ = $1; }
                | DECLARACION                       {   $$ = $1; }
                ;

DECLARACION     : var_id TIPO ASIGNACION            {   $$ = newNode(TYPE_EMPTY, NULL);
                                                        append($$, $2);
                                                        append($$, newNode(TYPE_VALUE, $1));
                                                        append($$, $3); }
                ;

ASIGNACION      :                                   {   $$ = NULL; }
                | asignar EXPRESION                 {   $$ = newNode(TYPE_EMPTY, NULL);
                                                        append($$, newNode(TYPE_VALUE, " = "));
                                                        append($$, $2); }               
                ;

REASIGNACION    : var_id reasignar EXPRESION        {   $$ = newNode(TYPE_EMPTY, NULL);
                                                        append($$, newNode(TYPE_VALUE, $1));
                                                        append($$, newNode(TYPE_VALUE, " = "));
                                                        append($$, $3); }
                ;

TIPO            : t_cadena                          {   $$ = newNode(TYPE_VALUE, "char * "); }
                | t_entero                          {   $$ = newNode(TYPE_VALUE, "int "); }
                ;

EXPRESION       : cadena                            {   $$ = newNode(TYPE_STRING, $1); }
                | entero                            {   $$ = newNode(TYPE_INT, $1); }
                ;

%%

int main(void){
    yyparse();
    return 0;
}

void yyerror(char * s){
    fprintf(stderr, "Error\n");
	//fprintf(stderr, "%s\n", s);
	return;
}
