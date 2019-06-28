%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <ctype.h>
	#include "node.h"

	int yylex();
	void yyerror(char * s);
    void printHeaders();
    extern int lineCount;
%}

%union {
	struct Node * node;
	char * value;
}

/* Tokens */
%token t_cadena t_entero asignar reasignar punto par_abrir par_cerrar suma resta mostrar
%token<value> cadena entero var_id
%type<node> PROGRAMA LINEA INSTRUCCION DECLARACION ASIGNACION REASIGNACION TIPO EXPRESION OPERACION FUNCION MOSTRAR
%start PROGRAMA

/* Producciones */
%%

PROGRAMA        : LINEA                             {   $$ = $1;
                                                        printHeaders();
                                                        printInorder($$); }

LINEA           : LINEA LINEA                       {   $$ = newNode(TYPE_EMPTY, NULL);
                                                        append($$, $1);
                                                        append($$, $2); }
                | INSTRUCCION punto                 {   $$ = newNode(TYPE_EMPTY, NULL);
                                                        append($$, $1);
                                                        append($$, newNode(TYPE_LITERAL, ";\n")); }
                ;

INSTRUCCION     : REASIGNACION                      {   $$ = $1; }
                | DECLARACION                       {   $$ = $1; }
                | FUNCION                           {   $$ = $1; }
                ;

DECLARACION     : var_id TIPO ASIGNACION            {   $$ = newNode(TYPE_EMPTY, NULL);
                                                        append($$, $2);
                                                        append($$, newNode(TYPE_LITERAL, $1));
                                                        append($$, $3); }
                ;

ASIGNACION      :                                   {   $$ = NULL; }
                | asignar EXPRESION                 {   $$ = newNode(TYPE_EMPTY, NULL);
                                                        append($$, newNode(TYPE_LITERAL, " = "));
                                                        append($$, $2); }               
                ;

REASIGNACION    : var_id reasignar EXPRESION        {   $$ = newNode(TYPE_EMPTY, NULL);
                                                        append($$, newNode(TYPE_LITERAL, $1));
                                                        append($$, newNode(TYPE_LITERAL, " = "));
                                                        append($$, $3); }
                ;

TIPO            : t_cadena                          {   $$ = newNode(TYPE_LITERAL, "char * "); }
                | t_entero                          {   $$ = newNode(TYPE_LITERAL, "int "); }
                ;

EXPRESION       : cadena                            {   $$ = newNode(TYPE_STRING, $1); }
                | entero                            {   $$ = newNode(TYPE_INT, $1); }
                | var_id                            {   $$ = newNode(TYPE_LITERAL, $1); }
                | par_abrir EXPRESION par_cerrar    {   $$ = newNode(TYPE_EMPTY, NULL); 
                                                        append($$, newNode(TYPE_LITERAL, "("));
                                                        append($$, $2);
                                                        append($$, newNode(TYPE_LITERAL, ")")); }
                | OPERACION                         {   $$ = $1; }
                ;

OPERACION       : EXPRESION suma EXPRESION          {   $$ = newNode(TYPE_EMPTY, NULL);
                                                        append($$, $1);
                                                        append($$, newNode(TYPE_LITERAL, " + "));
                                                        append($$, $3); }
                | EXPRESION resta EXPRESION         {   $$ = newNode(TYPE_EMPTY, NULL);
                                                        append($$, $1);
                                                        append($$, newNode(TYPE_LITERAL, " - "));
                                                        append($$, $3); }
                ;

FUNCION         : MOSTRAR                           {   $$ = $1; }
                ;

MOSTRAR         : mostrar EXPRESION                 {   $$ = newNode(TYPE_EMPTY, NULL); 
                                                        append($$, newNode(TYPE_LITERAL, "printf(\"%s\", ")); 
                                                        append($$, $2); 
                                                        append($$, newNode(TYPE_LITERAL, ")")); }
                ;

%%

int main(void){
    yyparse();
    return 0;
}

void yyerror(char * s){
    fprintf(stderr, "Error en la linea %d: %s\n", lineCount, s);
	exit(1);
}

void printHeaders() {
    //TODO
}