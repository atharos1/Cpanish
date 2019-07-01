%{
	#include <stdio.h>
    #include "node.h"
    #include "operations.h"    
    #include "compiler.h"

    extern int lineCount;

    int yylex();
	void yyerror(char * s);
    void printHeaders();
%}

%union {
	struct Node * node;
	char * value;
}

/* Tokens */
%token principal recibe coma es t_cadena t_entero asignar reasignar punto par_abrir par_cerrar suma resta mult divis mostrar 
si fin y o protot igual mayor mayor_igual menor menor_igual distinto repetir_mientras incrementar decrementar es_funcion devuelve 
devolver evaluada_en dos_puntos prototipo_funciones variables_globales
%token<value> cadena entero var_id
%type<node> PROGRAMA PRINCIPAL LISTA_PARAMETROS PARAMETROS PARAMETRO LINEA LINEAS INSTRUCCION DECLARACION ASIGNACION REASIGNACION 
TIPO TIPO_F EXPRESION OPERACION FUNCION_BUILTIN MOSTRAR BLOQUE CONDICIONAL COMPARADOR EVALUACION REPETIR INCREMENTACION DECREMENTACION 
FUNCION FUNCIONES FIN DEVOLVER NUEVO_ALCANCE ARGUMENTOS EVALUAR_FUNC PROTOTIPO PROTOTIPOS LISTA_VAR LISTA_PROTO VARIABLE VARIABLES
%start PROGRAMA

/* Precedencia */
%left suma resta
%left mult divis
%nonassoc igual distinto mayor_igual mayor menor menor_igual
%left y
%left o

/* Producciones */
%%

PROGRAMA        : LISTA_VAR LISTA_PROTO NUEVO_ALCANCE PRINCIPAL FUNCIONES       {   $$ = newNode(TYPE_EMPTY, NULL);
                                                                                    append($$, $1);
                                                                                    append($$, $2);
                                                                                    append($$, $4);
                                                                                    append($$, $5);
                                                                                    printHeaders();
                                                                                    printInorder($$); }
                ;

LISTA_VAR       : variables_globales VARIABLES                              {   $$ = $2; }
                |                                                           {   $$ = NULL; }
                ;

VARIABLES       : VARIABLE punto VARIABLES                                          {   $$ = newNode(TYPE_EMPTY, NULL);
                                                                                        append($$, $1);
                                                                                        append($$, newNode(TYPE_LITERAL, ";\n"));
                                                                                        append($$, $3); }
                |                                                                   {   $$ = NULL; }
                ;

LISTA_PROTO     : prototipo_funciones PROTOTIPOS                {   $$ = $2; }
                |                                               {   $$ = NULL; }
                ;

PROTOTIPOS      : NUEVO_ALCANCE PROTOTIPO punto PROTOTIPOS      {   $$ = newNode(TYPE_EMPTY, NULL);
                                                                    append($$, $1);
                                                                    append($$, newNode(TYPE_LITERAL, ");\n"));
                                                                    append($$, $3); }
                |                                               {   $$ = NULL; }
                ;

PROTOTIPO       : var_id es_funcion devuelve TIPO_F LISTA_PARAMETROS FIN_PARAMS         {   if (addVar($1, $4->type) == -1)
                                                                                            yyerror("Se superó el límite de variables\n");
                                                                                        $$ = newNode(TYPE_EMPTY, NULL);
                                                                                        append($$, $4);
                                                                                        append($$, newNode(TYPE_LITERAL, $1));
                                                                                        append($$, newNode(TYPE_LITERAL, "("));
                                                                                        append($$, $5); }

FIN_PARAMS      :                                                                       {   closeScope(); }
                ;

VARIABLE        : REASIGNACION                      {   $$ = $1; }
                | DECLARACION                       {   $$ = $1; }
                ;

PRINCIPAL       : principal es_funcion devuelve TIPO_F dos_puntos LINEAS FIN        {   $$ = newNode(TYPE_EMPTY, NULL);
                                                                                        append($$, $4);
                                                                                        append($$, newNode(TYPE_LITERAL, "main() {\n"));
                                                                                        append($$, $6);
                                                                                        append($$, newNode(TYPE_LITERAL, "}\n")); }
                ;

FUNCION         : var_id es_funcion devuelve TIPO_F LISTA_PARAMETROS dos_puntos LINEAS FIN      {   $$ = newNode(TYPE_EMPTY, NULL);
                                                                                                    append($$, $4);
                                                                                                    append($$, newNode(TYPE_LITERAL, $1));
                                                                                                    append($$, newNode(TYPE_LITERAL, "("));
                                                                                                    append($$, $5);
                                                                                                    append($$, newNode(TYPE_LITERAL, ") {\n"));
                                                                                                    append($$, $7);
                                                                                                    append($$, newNode(TYPE_LITERAL, "}\n")); }
                ;

FUNCIONES       : NUEVO_ALCANCE FUNCION FUNCIONES               {   $$ = newNode(TYPE_EMPTY, NULL); 
                                                                    append($$, $2);
                                                                    append($$, $3); }
                |                                               {   $$ = NULL; }
                ;

LISTA_PARAMETROS : punto recibe dos_puntos PARAMETROS           {   $$ = $4; }
                 |                                              {   $$ = NULL; }
                 ;

PARAMETROS      : PARAMETRO coma PARAMETROS                     {   $$ = newNode(TYPE_EMPTY, NULL);
                                                                    append($$, $1);
                                                                    append($$, newNode(TYPE_LITERAL, ", "));
                                                                    append($$, $3); }
                | PARAMETRO                                     {   $$ = $1; }
                ;

PARAMETRO       : TIPO_F var_id                                 {   if (addVar($2, $1->type) == -1)
                                                                        yyerror("Se superó el límite de variables\n");
                                                                    $$ = newNode(TYPE_EMPTY, NULL);
                                                                    append($$, $1);
                                                                    append($$, newNode(TYPE_LITERAL, $2)); }
                ;

FIN             : fin punto                                     {   closeScope(); }
                ;

LINEAS          : LINEA LINEAS                      {   $$ = newNode(TYPE_EMPTY, NULL);
                                                        append($$, $1);
                                                        append($$, $2); }
                | NUEVO_ALCANCE BLOQUE LINEAS       {   $$ = newNode(TYPE_EMPTY, NULL);
                                                        append($$, $2);
                                                        append($$, $3); }
                |                                   {   $$ = NULL; }
                ;

NUEVO_ALCANCE       :                               {   openScope(); }
                ;

LINEA           : INSTRUCCION punto                 {   $$ = newNode(TYPE_EMPTY, NULL);
                                                        append($$, $1);
                                                        append($$, newNode(TYPE_LITERAL, ";\n")); }
                ;

BLOQUE          : CONDICIONAL                       {   $$ = $1; }
                | REPETIR                           {   $$ = $1; }
                ;

INSTRUCCION     : REASIGNACION                      {   $$ = $1; }
                | DECLARACION                       {   $$ = $1; }
                | FUNCION_BUILTIN                   {   $$ = $1; }
                | INCREMENTACION                    {   $$ = $1; }
                | DECREMENTACION                    {   $$ = $1; }
                | DEVOLVER                          {   $$ = $1; }
                | EXPRESION                         {   $$ = $1; }
                ;


DEVOLVER        : devolver EXPRESION                {   $$ = newNode(TYPE_EMPTY, NULL);
                                                        append($$, newNode(TYPE_LITERAL, "return "));
                                                        append($$, $2); }
                ;

INCREMENTACION  : incrementar var_id                {   $$ = newNode(TYPE_EMPTY, NULL);
                                                        append($$, newNode(TYPE_LITERAL, $2));
                                                        append($$, newNode(TYPE_LITERAL, "++")); }
                ;

DECREMENTACION  : decrementar var_id                {   $$ = newNode(TYPE_EMPTY, NULL);
                                                        append($$, newNode(TYPE_LITERAL, $2));
                                                        append($$, newNode(TYPE_LITERAL, "--")); }
                ;

DECLARACION     : var_id TIPO ASIGNACION            {   if (isInCurrentScope($1) == 1)
                                                            yyerror("Variable ya declarada previamente\n");
                                                        if (addVar($1, $2->type) == -1)
                                                            yyerror("Se superó el límite de variables\n");
                                                        if ($3 != NULL && $2->type != $3->type) {
                                                            yyerror("Asignación entre tipos incompatibles\n");
                                                        }
                                                        $$ = newNode(TYPE_EMPTY, NULL);
                                                        append($$, $2);
                                                        append($$, newNode(TYPE_LITERAL, $1));
                                                        append($$, $3); }
                ;

ASIGNACION      :                                   {   $$ = NULL; }
                | asignar EXPRESION                 {   $$ = newNode($2->type, NULL);
                                                        append($$, newNode(TYPE_LITERAL, " = "));
                                                        append($$, $2); }               
                ;

REASIGNACION    : var_id reasignar EXPRESION        {   int type = getType($1);
                                                        if (type == -1)
                                                            yyerror("Variable o funcion no declarada previamente\n");
                                                        if (type != $3->type)
                                                            yyerror("Asignación entre tipos incompatibles\n");
                                                        $$ = newNode(TYPE_EMPTY, NULL);
                                                        append($$, newNode(TYPE_LITERAL, $1));
                                                        append($$, newNode(TYPE_LITERAL, " = "));
                                                        append($$, $3); }
                ;

TIPO            : es t_cadena                       {   $$ = newNode(TYPE_STRING, "char * "); }
                | es t_entero                       {   $$ = newNode(TYPE_INT, "int "); }
                ;

TIPO_F          : t_cadena                          {   $$ = newNode(TYPE_STRING, "char * "); }
                | t_entero                          {   $$ = newNode(TYPE_INT, "int "); }
                ;

EXPRESION       : cadena                            {   $$ = newNode(TYPE_STRING, $1); }
                | entero                            {   $$ = newNode(TYPE_INT, $1); }
                | var_id                            {   int type = getType($1);
                                                        if (type == -1)
                                                            yyerror("Variable o funcion no declarada previamente\n");
                                                        $$ = newNode(type, NULL);
                                                        append($$, newNode(TYPE_LITERAL, $1)); }
                | par_abrir EXPRESION par_cerrar    {   if ($2->value != NULL) {
                                                            $$ = $2;
                                                        } else  {
                                                            $$ = newNode($2->type, NULL); 
                                                            append($$, newNode(TYPE_LITERAL, "("));
                                                            append($$, $2);
                                                            append($$, newNode(TYPE_LITERAL, ")")); 
                                                        } }
                | OPERACION                         {   $$ = $1; }
                | EVALUAR_FUNC                      {   $$ = $1; }
                ;

OPERACION       : EXPRESION suma EXPRESION          {   $$ = addExpressions($1, $3); }
                | EXPRESION resta EXPRESION         {   $$ = subtractExpressions($1, $3); }
                | EXPRESION mult EXPRESION          {   $$ = multiplyExpressions($1, $3); }
                | EXPRESION divis EXPRESION         {   $$ = divideExpressions($1, $3); }
                ;

EVALUAR_FUNC    : var_id evaluada_en ARGUMENTOS     {   int type = getType($1);
                                                        if (type == -1)
                                                            yyerror("Funcion no declarada previamente\n");
                                                        $$ = newNode(type, NULL);
                                                        append($$, newNode(TYPE_LITERAL, $1));
                                                        append($$, newNode(TYPE_LITERAL, "("));
                                                        append($$, $3);
                                                        append($$, newNode(TYPE_LITERAL, ")"));
                                                    }

ARGUMENTOS      : EXPRESION coma ARGUMENTOS         {   $$ = newNode(TYPE_EMPTY, NULL);
                                                        append($$, $1);
                                                        append($$, newNode(TYPE_LITERAL, ", "));
                                                        append($$, $3); }
                | EXPRESION                         {   $$ = $1; }
                ;

FUNCION_BUILTIN : MOSTRAR                           {   $$ = $1; }
                ;

MOSTRAR         : mostrar EXPRESION                 {   $$ = newNode(TYPE_EMPTY, NULL);
                                                        if ($2->type == TYPE_STRING)
                                                            append($$, newNode(TYPE_LITERAL, "printf(\"%s\", "));
                                                        if ($2->type == TYPE_INT)
                                                            append($$, newNode(TYPE_LITERAL, "printf(\"%d\", "));
                                                        append($$, $2); 
                                                        append($$, newNode(TYPE_LITERAL, ")")); }
                ;

CONDICIONAL     : si EVALUACION dos_puntos LINEAS FIN               {   $$ = newNode(TYPE_EMPTY, NULL); 
                                                                        append($$, newNode(TYPE_LITERAL, "if(")); 
                                                                        append($$, $2); 
                                                                        append($$, newNode(TYPE_LITERAL, ")"));
                                                                        append($$, newNode(TYPE_LITERAL, "{\n"));
                                                                        append($$, $4); 
                                                                        append($$, newNode(TYPE_LITERAL, "}\n")); }
                ;

REPETIR         : repetir_mientras EVALUACION dos_puntos LINEAS FIN {   $$ = newNode(TYPE_EMPTY, NULL); 
                                                                        append($$, newNode(TYPE_LITERAL, "while(")); 
                                                                        append($$, $2); 
                                                                        append($$, newNode(TYPE_LITERAL, ")"));
                                                                        append($$, newNode(TYPE_LITERAL, "{\n"));
                                                                        append($$, $4); 
                                                                        append($$, newNode(TYPE_LITERAL, "}\n")); }
                ;

EVALUACION      : EXPRESION COMPARADOR EXPRESION                    {   $$ = newNode(TYPE_EMPTY, NULL);
                                                                        if ($1->type == TYPE_STRING && $3->type == TYPE_STRING) {
                                                                            append($$, newNode(TYPE_LITERAL, "strcmp("));
                                                                            append($$, $1);
                                                                            append($$, newNode(TYPE_LITERAL, ", "));
                                                                            append($$, $3);
                                                                            append($$, newNode(TYPE_LITERAL, ")"));
                                                                            append($$, $2);
                                                                            append($$, newNode(TYPE_LITERAL, "0"));
                                                                        } else if ($1->type == TYPE_INT && $3->type == TYPE_INT) {
                                                                            append($$, $1); 
                                                                            append($$, $2); 
                                                                            append($$, $3);
                                                                        } else {
                                                                            yyerror("Comparación entre tipos incompatibles");
                                                                        } }
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
                | mayor                             {   $$ = newNode(TYPE_LITERAL, " > "); }    
                | mayor_igual                       {   $$ = newNode(TYPE_LITERAL, " >= "); }    
                | menor                             {   $$ = newNode(TYPE_LITERAL, " < "); }    
                | menor_igual                       {   $$ = newNode(TYPE_LITERAL, " <= "); }    
                | distinto                          {   $$ = newNode(TYPE_LITERAL, " != "); }     
                ;             

%%

void yyerror(char * s){
    fprintf(stderr, "Error en la linea %d: %s\n", lineCount, s);
    
    freeResources();

    if(remove(TMP_FILE_NAME)) {
        printf ("Error al eliminar el archivo de código intermedio.\n");
        exit(1);
    }

	exit(1);
}

void printHeaders() {
    fprintf(tmpFile, "#include <stdio.h>\n");
    fprintf(tmpFile, "#include <stdlib.h>\n");
    fprintf(tmpFile, "#include <string.h>\n");

    fprintf(tmpFile, "%s" , strCatFunction);
    fprintf(tmpFile, "%s" , strIntCatFunction);
    fprintf(tmpFile, "%s" , strIntMultFunction);
}