%{
#include "derres.h"
#include "y.tab.h"
%}
%%
sin {yylval.fvalue = SIN; return SIN;}
cos {yylval.fvalue = COS; return COS;}
exp {yylval.fvalue = EXP; return EXP;}
log {yylval.fvalue = LOG; return LOG;}
[+*()\[\]D,] 	return yytext[0];
[a-z]+|[0-9]+ {char*  copy = malloc(strlen(yytext)+1); strcpy(copy, yytext);  yylval.text = copy; return UNKN;}
[ \t] 
. 	{printf("Lexical error"); return 0;}
\n      return 0;
%%

int yywrap(){
	return 1;
}
