%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <ctype.h>
    #include <getopt.h>

    #include "node.h"    

	int yylex();
	void yyerror(char * s);
    void printHeaders();
    extern int lineCount;
    extern FILE *yyin;
%}

%union {
	struct Node * node;
	char * value;
}

/* Tokens */
%token principal recibe coma t_cadena t_entero asignar reasignar punto par_abrir par_cerrar suma resta mostrar si dos_puntos fin y o igual mayor mayor_igual menor menor_igual distinto repetir_mientras incrementar decrementar es_funcion devuelve devolver
%token<value> cadena entero var_id
%type<node> PROGRAMA PRINCIPAL LISTA_PARAMETROS PARAMETROS PARAMETRO LINEA INSTRUCCION DECLARACION ASIGNACION REASIGNACION TIPO EXPRESION OPERACION FUNCION_BUILTIN MOSTRAR BLOQUE CONDICIONAL COMPARADOR EVALUACION REPETIR INCREMENTACION DECREMENTACION FUNCION FIN DEVOLVER
%start PROGRAMA

/* Producciones */
/* TODO: ELIMINAR REDUNDANCIAS CON TRANSICIONES LAMBDA, AGREGAR VARIABLES GLOBALES, VER TEMA PROTOTIPOS */
%%

PROGRAMA        : PRINCIPAL         {   $$ = newNode(TYPE_EMPTY, NULL);
                                                        append($$, $1);
                                                        printHeaders();
                                                        printInorder($$); }
                | PRINCIPAL FUNCION         {   $$ = newNode(TYPE_EMPTY, NULL);
                                                        append($$, $1);
                                                        append($$, $2);
                                                        printHeaders();
                                                        printInorder($$); }
                | FUNCION PRINCIPAL         {   $$ = newNode(TYPE_EMPTY, NULL);
                                                        append($$, $2);
                                                        append($$, $1);
                                                        printHeaders();
                                                        printInorder($$); }
                | FUNCION PRINCIPAL FUNCION         {   $$ = newNode(TYPE_EMPTY, NULL);
                                                        append($$, $2);
                                                        append($$, $1);
                                                        append($$, $3);
                                                        printHeaders();
                                                        printInorder($$); }
                ;

PRINCIPAL       : principal es_funcion devuelve TIPO dos_puntos LINEA FIN  {   $$ = newNode(TYPE_EMPTY, NULL);
                                                                            append($$, $4);
                                                                            append($$, newNode(TYPE_LITERAL, "main() {\n"));
                                                                            append($$, $6);
                                                                            append($$, newNode(TYPE_LITERAL, "}\n")); }
                ;

FUNCION         : var_id es_funcion devuelve TIPO LISTA_PARAMETROS dos_puntos LINEA FIN     {   $$ = newNode(TYPE_EMPTY, NULL);
                                                                                                append($$, $4);
                                                                                                append($$, newNode(TYPE_LITERAL, $1));
                                                                                                append($$, newNode(TYPE_LITERAL, "("));
                                                                                                append($$, $5);
                                                                                                append($$, newNode(TYPE_LITERAL, ") {\n"));
                                                                                                append($$, $7);
                                                                                                append($$, newNode(TYPE_LITERAL, "}\n")); }
                | var_id es_funcion devuelve TIPO dos_puntos LINEA FIN                {   $$ = newNode(TYPE_EMPTY, NULL);
                                                                                        append($$, $4);
                                                                                        append($$, newNode(TYPE_LITERAL, $1));
                                                                                        append($$, newNode(TYPE_LITERAL, "() {\n"));
                                                                                        append($$, $6);
                                                                                        append($$, newNode(TYPE_LITERAL, "}\n")); }
                ;

LISTA_PARAMETROS : punto recibe dos_puntos PARAMETROS                     {   $$ = $4; }

PARAMETROS      : PARAMETRO coma PARAMETRO                          {   $$ = newNode(TYPE_EMPTY, NULL);
                                                                        append($$, $1);
                                                                        append($$, newNode(TYPE_LITERAL, ","));
                                                                        append($$, $3); }
                | PARAMETRO                                         {   $$ = $1; }
                ;

PARAMETRO       : var_id TIPO                                       {   $$ = newNode(TYPE_EMPTY, NULL);
                                                                        append($$, $2);
                                                                        append($$, newNode(TYPE_LITERAL, $1)); }
                ;

FIN             : fin punto                                             {;}
                ;

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

CONDICIONAL     : si EVALUACION dos_puntos LINEA FIN                    {   $$ = newNode(TYPE_EMPTY, NULL); 
                                                                            append($$, newNode(TYPE_LITERAL, "if(")); 
                                                                            append($$, $2); 
                                                                            append($$, newNode(TYPE_LITERAL, ")"));
                                                                            append($$, newNode(TYPE_LITERAL, "{\n"));
                                                                            append($$, $4); 
                                                                            append($$, newNode(TYPE_LITERAL, "}\n")); }
                ;

REPETIR        : repetir_mientras EVALUACION dos_puntos LINEA FIN       {   $$ = newNode(TYPE_EMPTY, NULL); 
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

    compileC(op.output, op.preserve);
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
    char * strCatFunction = "char * strconcat(char * str1, char * str2) {\n"
                                "\tchar * newstr = malloc( strlen(str1) + strlen(str2) - 1 );\n"
                                "\tstrcpy(newstr, str1);\n"
                                "\tstrcat(newstr, str2);\n"
                                "\treturn newstr;\n"
                            "}\n";

    fprintf(tmpFile, "#include <stdio.h>\n");
    fprintf(tmpFile, "#include <stdlib.h>\n");
    fprintf(tmpFile, "#include <string.h>\n");

    fprintf(tmpFile, strCatFunction);
}