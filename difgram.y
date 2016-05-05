%{
#include <stdio.h>
#include "safecat.h"

const char* derivand;
const char* xconst = "x";
//IMPORTANT for memory management: every string in derres(a pair of derived and initial expression)
//is created either in a makeres or a safecat function
%}
%union{
    derres deriv;
    char* text;
}
%token <text> UNKN FUN
%type <deriv> der
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
    |FUN '(' der ')' {char* deriv = safecat(3, "%s(%s)*(%s)", difFun($1), $3.inittext, $3.dertext);
			//TODO should not free $1 here
                       char* init = safecat(2, "%s(%s)", $1, $3.inittext);
		       $$ = makeres(deriv, init);
                       }
    |UNKN { printf("ident(%s) as var\n", $1);$$ = onVariable($1, derivand); }         
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
