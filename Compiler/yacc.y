%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <ctype.h>
    #include <getopt.h>
    #include "node.h"
    #include "operations.h"    

    extern int lineCount;
    extern FILE *yyin;

    int yylex();
	void yyerror(char * s);
    void printHeaders();
%}

%union {
	struct Node * node;
	char * value;
}

/* Tokens */
%token principal recibe coma es t_cadena t_entero asignar reasignar punto par_abrir par_cerrar suma resta mult divis mostrar si fin y o 
igual mayor mayor_igual menor menor_igual distinto repetir_mientras incrementar decrementar es_funcion devuelve devolver
%token<value> cadena entero var_id dos_puntos
%type<node> PROGRAMA PRINCIPAL LISTA_PARAMETROS PARAMETROS PARAMETRO LINEA LINEAS INSTRUCCION DECLARACION ASIGNACION REASIGNACION TIPO TIPO_F EXPRESION 
OPERACION FUNCION_BUILTIN MOSTRAR BLOQUE CONDICIONAL COMPARADOR EVALUACION REPETIR INCREMENTACION DECREMENTACION FUNCION FUNCIONES FIN DEVOLVER NEW_SCOPE
%start PROGRAMA

/* Precedencia */
%left suma resta
%left mult divis
%nonassoc igual distinto mayor_igual mayor menor menor_igual
%left y
%left o

/* Producciones */
/* TODO: ELIMINAR REDUNDANCIAS CON TRANSICIONES LAMBDA, AGREGAR VARIABLES GLOBALES, VER TEMA PROTOTIPOS */
%%

PROGRAMA        : FUNCIONES NEW_SCOPE PRINCIPAL                 {   $$ = newNode(TYPE_EMPTY, NULL);
                                                                    append($$, $1);
                                                                    append($$, $3);
                                                                    printHeaders();
                                                                    printInorder($$); }
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
                | var_id es_funcion devuelve TIPO_F dos_puntos FIN                      {   $$ = newNode(TYPE_EMPTY, NULL);
                                                                                            append($$, $4);
                                                                                            append($$, newNode(TYPE_LITERAL, $1));
                                                                                            append($$, newNode(TYPE_LITERAL, "() {\n"));
                                                                                            append($$, $6);
                                                                                            append($$, newNode(TYPE_LITERAL, "}\n")); }
                ;

FUNCIONES       : NEW_SCOPE FUNCION FUNCIONES                   {   $$ = newNode(TYPE_EMPTY, NULL); 
                                                                    append($$, $2);
                                                                    append($$, $3); }
                |                                               {   $$ = NULL; }
                ;

LISTA_PARAMETROS : punto recibe dos_puntos PARAMETROS                     {   $$ = $4; }
                 ;

PARAMETROS      : PARAMETRO coma PARAMETRO                          {   $$ = newNode(TYPE_EMPTY, NULL);
                                                                        append($$, $1);
                                                                        append($$, newNode(TYPE_LITERAL, ", "));
                                                                        append($$, $3); }
                | PARAMETRO                                         {   $$ = $1; }
                ;

PARAMETRO       : TIPO_F var_id                                         {   if (addVar($2, $1->type) == -1)
                                                                                yyerror("Se superó el límite de variables\n");
                                                                            $$ = newNode(TYPE_EMPTY, NULL);
                                                                            append($$, $1);
                                                                            append($$, newNode(TYPE_LITERAL, $2)); }
                ;

FIN             : fin punto                                         {   closeScope(); }
                ;

LINEAS          : LINEA LINEAS                      {   $$ = newNode(TYPE_EMPTY, NULL);
                                                        append($$, $1);
                                                        append($$, $2); }
                | NEW_SCOPE BLOQUE LINEAS           {   $$ = newNode(TYPE_EMPTY, NULL);
                                                        append($$, $2);
                                                        append($$, $3); }
                |                                   {   $$ = NULL; }
                ;

NEW_SCOPE       :                                   {   openScope(); }
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
                                                            yyerror("Variable no declarada previamente\n");
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
                                                            yyerror("Variable no declarada previamente\n");
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
                ;

OPERACION       : EXPRESION suma EXPRESION          {   $$ = addExpressions($1, $3); }
                | EXPRESION resta EXPRESION         {   $$ = subtractExpressions($1, $3); }
                | EXPRESION mult EXPRESION          {   $$ = multiplyExpressions($1, $3); }
                | EXPRESION divis EXPRESION         {   $$ = divideExpressions($1, $3); }
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

CONDICIONAL     : si EVALUACION dos_puntos LINEAS FIN                    {   $$ = newNode(TYPE_EMPTY, NULL); 
                                                                            append($$, newNode(TYPE_LITERAL, "if(")); 
                                                                            append($$, $2); 
                                                                            append($$, newNode(TYPE_LITERAL, ")"));
                                                                            append($$, newNode(TYPE_LITERAL, "{\n"));
                                                                            append($$, $4); 
                                                                            append($$, newNode(TYPE_LITERAL, "}\n")); }
                ;

REPETIR         : repetir_mientras EVALUACION dos_puntos LINEAS FIN       {   $$ = newNode(TYPE_EMPTY, NULL); 
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

struct op_values {
    int preserve;
    char * output;
    char * input;
} op;

void argParse(int argc, char *argv[], struct op_values * op){

    if(argc == 1) {
        fprintf(stderr, "Ingrese la ruta del archivo de código a compilar como primer argumento.\n");
	    exit(1);
    }

    //Valores por defecto
    op->input = argv[1];
    op->preserve = 0;
    op->output = "a.out";

    opterr = 0; //Callar a getopd

    static const struct option op_list[] = {
        {.name = "preserve", .has_arg = no_argument, .val = 'p'},
        {.name = "output", .has_arg = required_argument, .val = 'o'},
        {},
    };
    while(1) {
        int opt = getopt_long(argc, argv, ":o:p", op_list, NULL);
        if (opt == -1)
            break;
        switch (opt) {
        case 'p':
            op->preserve = 1;
            break;
        case 'o':
            op->output = optarg;
            break;
        case ':':
            fprintf(stdout, "Opción '%s' requiere un argumento\n", argv[optind - 1]);
            break;
        case '?': 
        default:
            fprintf(stdout, "Opción '%s' desconocida\n", argv[optind - 1]);
            exit(1);
        }
    }
}

void initializeCompiler(char * inputFile) {
    FILE * read_file = fopen (inputFile, "r");
    if (read_file == NULL) {
        printf ("El archivo de código especificado no se encuentra o no puede abrirse.\n");
        exit(1);
    }

    yyin = read_file;

    tmpFile = fopen(TMP_FILE_NAME, "w");
    if (tmpFile == NULL) {
        printf ("Error al crear archivo temporal. Compilación abortada.\n");
        exit(1);
    }
}

void freeResources() {
    fclose(tmpFile);
    fclose(yyin);
}

void compileC(char * outputFile, int preserveTmp) {
    char commandBuffer[256];
    sprintf(commandBuffer, "gcc %s -o %s", TMP_FILE_NAME, outputFile);

    int gccStatus = system(commandBuffer);

    if(!preserveTmp && remove(TMP_FILE_NAME)) {
        printf ("Error al eliminar el archivo de código intermedio.\n");
        exit(1);
    }

    if(gccStatus != 0) {
        printf ("Error al compilar el código intermedio generado.\n");
        exit(1);
    }
}

int main(int argc, char *argv[]) {

    argParse(argc, argv, &op);

    initializeCompiler(op.input);

    yyparse();

    freeResources();

    //compileC(op.output, op.preserve);
    return 0;
}

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