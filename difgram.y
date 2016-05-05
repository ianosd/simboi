%{
#include <stdio.h>
#include "safecat.h"
extern char* yytext;
#define YYSTYPE derres

const char* derivand;
const char* xconst = "x";
//IMPORTANT for memory management: every string in derres(a pair of derived and initial expression)
//is created either in a makeres or a safecat function
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
    | der '*' der {  char* deriv = safecat(4, "(%s)*(%s) + (%s)*(%s)", $1.inittext, $3.dertext, $1.dertext, $3.inittext);
		     char* init =  safecat(2, "%s * %s", $1.inittext, $3.inittext);
                     $$ = makeres(deriv, init);
                  }
    |UNKN { $$ = onVariable(yytext, derivand); }         
    |'(' der ')' {$$ = $2;}
%%
int main(int argc, char** argv){
   if(argc ==1)
       derivand = xconst;
   else
       derivand = argv[1];
   printf("Deriving rel to: %s\n", derivand);
   yyparse();
}

int yyerror(char* str){return -1;}
