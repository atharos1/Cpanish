%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "y.tab.h"

    extern void yyerror(char * s);
    int lineCount = 1;
%}


%option
%x comment

digit			[0-9]
alpha			[a-zA-Z_]
space			[ \t]
newline         [\n]

%%

"/*"                    BEGIN(comment);
<comment>[^*\n]*        {}
<comment>"*"+[^*/\n]*   {}
<comment>\n             lineCount++;
<comment>"*"+"/"        BEGIN(INITIAL);

{space}+            ;/* spaces */
{newline}           {lineCount++;}

\"[^"]*\"                          {   char * str = malloc(strlen(yytext)+1);
                                    strcpy(str, yytext);
                                    yylval.value = str;
                                    return cadena;
                                }

","                 {return coma;}
"un entero"      {return t_entero;}
"una cadena"     {return t_cadena;}
"es "            {return es;}
"que vale"          {return asignar;}
"ahora vale"        {return reasignar;}
"Mostrar"           {return mostrar; }
"."                 {return punto;}
"("                 {return par_abrir;}
")"                 {return par_cerrar;}
"+"                 {return suma;}
"-"                 {return resta;}
"*"                 {return mult;}
"/"                 {return divis;}
"Si"                {return si;}
":"                 {return dos_puntos;}
"Fin"               {return fin;}
" y "               {return y;}
" o "               {return o;}
"es igual a"        {return igual;}
"es mayor a"        {return mayor;}
"es mayor o igual a"   {return mayor_igual;}
"es menor a"           {return menor;}
"es menor o igual a"   {return menor_igual;}
"es distinto a"        {return distinto;}
"sea igual a"        {return igual;}
"sea mayor a"        {return mayor;}
"sea mayor o igual a"   {return mayor_igual;}
"sea menor a"           {return menor;}
"sea menor o igual a"   {return menor_igual;}
"sea distinto a"        {return distinto;}
"evaluada en"           {return evaluada_en;}
"Las funciones seran"   {return protot;}
"Repetir mientras"     {return repetir_mientras;}
"Incrementar "         {return incrementar;}
"Decrementar "         {return decrementar;}
"es una funcion "      {return es_funcion;}
"que devuelve "       {return devuelve;}
"Principal "           {return principal;}
"Devolver "           {return devolver;}
"Recibe"           {return recibe;}

-?{digit}+                      {   char * str = malloc(strlen(yytext)+1);
			                        strcpy(str, yytext);
			                        yylval.value = str;
			                        return entero; }

{alpha}({alpha}|{digit})*       {   char * str = malloc(strlen(yytext)+1);
			                        strcpy(str,yytext);
			                        yylval.value = str;
			                        return var_id; }

.                               {   yyerror("Caracter invalido\n"); }

%%

int yywrap(void){
	return 1;
}