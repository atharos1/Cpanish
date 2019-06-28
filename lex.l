%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "y.tab.h"
%}


%option 
digit			[0-9]
alpha			[a-zA-Z_]
space			[ \t\n]

%%

"/*"(.|\n)*"*/"		;/* comments */
{space}+            ;/* spaces */ 

"es un entero"      {return t_entero;}
"es una cadena"     {return t_cadena;}
"que vale"          {return asignar;}
"ahora vale"        {return reasignar;}
"."                 {return punto;}

\".*\"                          {   char * str = malloc(strlen(yytext)+1);
                                    strcpy(str, yytext);
                                    yylval.value = str;
                                    return cadena;
                                }

{digit}+                        {   char * str = malloc(strlen(yytext)+1);
			                        strcpy(str, yytext);
			                        yylval.value = str;
			                        return entero; }

{alpha}({alpha}|{digit})*       {   char * str = malloc(strlen(yytext)+1);
			                        strcpy(str,yytext);
			                        yylval.value = str;
			                        return var_id; }

%%

int yywrap(void){
	return 1;
}
