%{
#include "derres.h"
#include "y.tab.h"
%}
%%
[+*()] 	return yytext[0];
[a-z]+|[0-9]+ {yylval.text = yytext; return UNKN;}
[ \t] 
. 	{printf("Lexical error"); return 0;}
\n      return 0;
%%

int yywrap(){
	return 1;
}
