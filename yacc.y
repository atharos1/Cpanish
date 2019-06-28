%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <ctype.h>
	#include "node.h"

	int yylex();
	void yyerror(char * s);
    extern int lineCount;
%}

%union {
	struct Node * node;
	char * value;
}

/* Tokens */
%token t_cadena t_entero asignar reasignar punto par_abrir par_cerrar suma resta
%token<value> cadena entero var_id
%type<node> PROGRAMA LINEA INSTRUCCION DECLARACION ASIGNACION REASIGNACION TIPO EXPRESION OPERACION
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
                | var_id                            {   $$ = newNode(TYPE_VALUE, $1); }
                | par_abrir EXPRESION par_cerrar    {   $$ = newNode(TYPE_EMPTY, NULL); 
                                                        append($$, newNode(TYPE_VALUE, "("));
                                                        append($$, $2);
                                                        append($$, newNode(TYPE_VALUE, ")")); }
                | OPERACION                         {   $$ = $1; }
                ;

OPERACION       : EXPRESION suma EXPRESION          {   $$ = newNode(TYPE_EMPTY, NULL);
                                                        append($$, $1);
                                                        append($$, newNode(TYPE_VALUE, " + "));
                                                        append($$, $3); }
                | EXPRESION resta EXPRESION         {   $$ = newNode(TYPE_EMPTY, NULL);
                                                        append($$, $1);
                                                        append($$, newNode(TYPE_VALUE, " - "));
                                                        append($$, $3); }
                ;

%%

int main(void){
    yyparse();
    return 0;
}

void yyerror(char * s){
    fprintf(stderr, "Error on line %d: %s\n", lineCount, s);
	return;
}
