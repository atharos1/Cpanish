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

"es un entero"      {return t_entero;}
"es una cadena"     {return t_cadena;}
"que vale"          {return asignar;}
"ahora vale"        {return reasignar;}
"Mostrar"           {return mostrar; }
"."                 {return punto;}
"("                 {return par_abrir;}
")"                 {return par_cerrar;}
"+"                 {return suma;}
"-"                 {return resta;}

\".*\"                          {   char * str = malloc(strlen(yytext)+1);
                                    strcpy(str, yytext);
                                    yylval.value = str;
                                    return cadena;
                                }

-?{digit}+                        {   char * str = malloc(strlen(yytext)+1);
			                        strcpy(str, yytext);
			                        yylval.value = str;
			                        return entero; }

{alpha}({alpha}|{digit})*       {   char * str = malloc(strlen(yytext)+1);
			                        strcpy(str,yytext);
			                        yylval.value = str;
			                        return var_id; }

.                               {   yyerror("Caracter invalido"); }

%%

int yywrap(void){
	return 1;
}