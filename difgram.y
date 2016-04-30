%{
#include "safecat.h"
extern char* yytext;
#define YYSTYPE derres
%}
%token NUM UNKN
%left '+'
%left '*'
%%
start: der {printf("%s", $1);}
der: der '+' der {char* deriv = safecat(2, "%s + %s", $1.dertext, $3.dertext);
		  char* init = safecat(2, "%s + %s", $1.inittext, $3.inittext);
                  $$ = makeres(deriv, init);
                 }
    |'x' {$$=makeres("1", "x");}
    | der '*' der {  char* deriv = safecat(4, "(%s)*(%s) + (%s)*(%s)", $1.inittext, $3.dertext, $1.dertext, $3.inittext);
		     char* init =  safecat(2, "%s * %s", $1.inittext, $3.inittext);
                     $$ = makeres(deriv, init);
                  }
    |UNKN { char* copy = (char*) malloc(strlen(yytext)); strcpy(copy, yytext);
	    $$=makeres("0", copy);
          }
    |'(' der ')' {$$ = $2;}
%%
int main(){
   yyparse();
}

int yyerror(char* str){return -1;}

