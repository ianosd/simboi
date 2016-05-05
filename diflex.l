%{
#include "y.tab.h"
%}
%%
[+*()] 	return yytext[0];
[a-z]+|[0-9]+ return UNKN;
[ \t] 
. 	{printf("Lexical error"); return 0;}
\n      return 0;
%%

int yywrap(){
	return 1;
}
