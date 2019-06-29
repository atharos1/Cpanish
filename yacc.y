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
%token t_cadena t_entero asignar reasignar punto par_abrir par_cerrar suma resta mostrar si dos_puntos fin y o igual mayor mayor_igual menor menor_igual distinto repetir_mientras incrementar decrementar
%token<value> cadena entero var_id
%type<node> PROGRAMA LINEA INSTRUCCION DECLARACION ASIGNACION REASIGNACION TIPO EXPRESION OPERACION FUNCION_BUILTIN MOSTRAR BLOQUE CONDICIONAL COMPARADOR EVALUACION REPETIR INCREMENTACION DECREMENTACION
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
                | BLOQUE                            {   $$ = newNode(TYPE_EMPTY, NULL);
                                                        append($$, $1); }
                ;

INSTRUCCION     : REASIGNACION                      {   $$ = $1; }
                | DECLARACION                       {   $$ = $1; }
                | FUNCION_BUILTIN                   {   $$ = $1; }
                | INCREMENTACION                    {   $$ = $1; }
                | DECREMENTACION                    {   $$ = $1; }
                ;

INCREMENTACION  : incrementar var_id                {   $$ = newNode(TYPE_EMPTY, NULL);
                                                        append($$, newNode(TYPE_LITERAL, $2));
                                                        append($$, newNode(TYPE_LITERAL, "++")); }
                ;

DECREMENTACION  : decrementar var_id                {   $$ = newNode(TYPE_EMPTY, NULL);
                                                        append($$, newNode(TYPE_LITERAL, $2));
                                                        append($$, newNode(TYPE_LITERAL, "--")); }
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

FUNCION_BUILTIN : MOSTRAR                           {   $$ = $1; }
                ;

MOSTRAR         : mostrar EXPRESION                 {   $$ = newNode(TYPE_EMPTY, NULL); 
                                                        append($$, newNode(TYPE_LITERAL, "printf(\"%s\", ")); 
                                                        append($$, $2); 
                                                        append($$, newNode(TYPE_LITERAL, ")")); }
                ;

BLOQUE          : CONDICIONAL                       {   $$ = $1; }
                | REPETIR                           {   $$ = $1; }
                ;

CONDICIONAL     : si EVALUACION dos_puntos LINEA fin punto                {   $$ = newNode(TYPE_EMPTY, NULL); 
                                                                            append($$, newNode(TYPE_LITERAL, "if(")); 
                                                                            append($$, $2); 
                                                                            append($$, newNode(TYPE_LITERAL, ")"));
                                                                            append($$, newNode(TYPE_LITERAL, "{\n"));
                                                                            append($$, $4); 
                                                                            append($$, newNode(TYPE_LITERAL, "}\n")); }
                ;

REPETIR        : repetir_mientras EVALUACION dos_puntos LINEA fin punto   {   $$ = newNode(TYPE_EMPTY, NULL); 
                                                                            append($$, newNode(TYPE_LITERAL, "while(")); 
                                                                            append($$, $2); 
                                                                            append($$, newNode(TYPE_LITERAL, ")"));
                                                                            append($$, newNode(TYPE_LITERAL, "{\n"));
                                                                            append($$, $4); 
                                                                            append($$, newNode(TYPE_LITERAL, "}\n")); }
                ;


EVALUACION      : EXPRESION COMPARADOR EXPRESION                    {   $$ = newNode(TYPE_EMPTY, NULL); 
                                                                        append($$, $1); 
                                                                        append($$, $2); 
                                                                        append($$, $3); }
                | EVALUACION y EVALUACION                           {   $$ = newNode(TYPE_EMPTY, NULL); 
                                                                        append($$, $1); 
                                                                        append($$, newNode(TYPE_LITERAL, " && "));
                                                                        append($$, $3);                           }
                | EVALUACION o EVALUACION                           {   $$ = newNode(TYPE_EMPTY, NULL); 
                                                                        append($$, $1); 
                                                                        append($$, newNode(TYPE_LITERAL, " || "));
                                                                        append($$, $3);                           }
                | par_abrir EVALUACION par_cerrar                   {   $$ = newNode(TYPE_EMPTY, NULL); 
                                                                        append($$, newNode(TYPE_LITERAL, "(")); 
                                                                        append($$, $2); 
                                                                        append($$, newNode(TYPE_LITERAL, ")"));   }
                | EXPRESION                                         {   $$ = $1;                                  }
                ;

COMPARADOR      : igual                             {   $$ = newNode(TYPE_LITERAL, " == "); }    
COMPARADOR      : mayor                             {   $$ = newNode(TYPE_LITERAL, " > "); }    
COMPARADOR      : mayor_igual                       {   $$ = newNode(TYPE_LITERAL, " >= "); }    
COMPARADOR      : menor                             {   $$ = newNode(TYPE_LITERAL, " < "); }    
COMPARADOR      : menor_igual                       {   $$ = newNode(TYPE_LITERAL, " <= "); }    
COMPARADOR      : distinto                          {   $$ = newNode(TYPE_LITERAL, " != "); }     
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
    puts("/* DEPENDENCIAS DEL COMPILADOR */");
    char * strCatFunction = "char * strconcat(char * str1, char * str2) {\n"
                                "\tchar * newstr = malloc( strlen(str1) + strlen(str2) - 1 );\n"
                                "\tstrcpy(newstr, str1);\n"
                                "\tstrcat(newstr, str2);\n"
                                "\treturn newstr;\n"
                            "}";

    puts("#include <stdio.h>");
    puts("#include <string.h>");

    puts(strCatFunction);
    puts("/* DEPENDENCIAS DEL COMPILADOR */\n");
}