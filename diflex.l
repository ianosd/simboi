%{
#include "y.tab.h"
%}
%%
[x+*()] 	return yytext[0];
[a-w]+|[0-9]+ return UNKN;
[ \t] 
. 	{printf("Lexical error"); return 0;}
\n      return 0;
%%

int yywrap(){
	return 1;
}
