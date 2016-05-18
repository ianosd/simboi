%{
#include <stdio.h>
#include "safecat.h"
#include "inputstack.h"

const char* derivand;
const char* xconst = "x";
extern char* yytext;
extern FILE* yyin;
instack_t myInputStack;
int yydebug;
void scan_string(char*);
void done_scan_string();
//IMPORTANT for memory management: every string in derres(a pair of derived and initial expression)
//is created either in a makeres or a safecat function
%}
%union{
    derres deriv;
    char* text;
    int num;
    sumstruct* sum;
    prodstruct* prod;
}
%token <text> UNKN
%token <num> SIN COS EXP LOG NUM
%type <deriv> der
%type <num> fun
%type <sum> expr
%type <prod> term
%left '+'
%left '*'
%%
start: expr {printf("Identified expression\n"); printsum($1);}
expr: term {printf("Made empty sum"); $$=emptysum();addTerm($$, $1);}
    | term '+' expr {$$ = $3; addTerm($$, $1);printf("Add term to sum");}
    | '(' expr ')' {$$ = $2;}
expr: 'D' '[' UNKN {derivand = strdup($3);printf("Diff rel to %s\n", derivand);} 
      ',' der ']'{ //as soon as der text is avalible, add it to the input stack
                addToInputStack(&myInputStack,$6.dertext);
                printf("dErtext = %s\n", $6.dertext);//TODO dealocate derivand}
            } 
            expr {$$=$9;};



term: NUM  {$$ = emptyprod(); multerm_num($$, $1);} 
    | UNKN {$$ = emptyprod(); multerm_sym($$, $1);}
    | NUM '*' term {$$ = $3; multerm_num($$, $1);printf("Mul By Number");}
    | UNKN '*' term {$$ = $3; multerm_sym($$, $1);printf("Mul By Term");}
    | '(' term ')' {$$ = $2;}
der: der '+' der {char* deriv = safecat(2, "%s + %s", $1.dertext, $3.dertext);
		  char* init = safecat(2, "%s + %s", $1.inittext, $3.inittext);
                  $$ = makeres(deriv, init);
                 }
    | der '*' der {  char* deriv = safecat(4, "(%s)*(%s) + (%s)*(%s)", $1.inittext, $3.dertext, $1.dertext, $3.inittext);
		     char* init =  safecat(2, "%s * %s", $1.inittext, $3.inittext);
                     $$ = makeres(deriv, init);
                  }
    |UNKN '(' der ')' {char* deriv = safecat(3, "%s(%s)*(%s)", difFun($1), $3.inittext, $3.dertext);
			//TODO should not free $1 here
                       char* init = safecat(2, "%s(%s)", $1, $3.inittext);
		       $$ = makeres(deriv, init);
                       }
    |fun '(' der ')' {derres dd = kdifFun($1); printf("Der = %s\n", dd);char* deriv = safecat(3, "%s(%s)*(%s)", dd.dertext,  $3.inittext, $3.dertext);
                       char* init = safecat(2, "%s(%s)", dd.inittext, $3.inittext);
		       $$ = makeres(deriv, init);}
    |UNKN { printf("ident(%s) as var\n", $1);$$ = onVariable($1, derivand); }         
    |NUM {printf("Got a number %d\n", $1); $$ = makeres("0", yytext);}
    |'(' der ')' {$$ = $2;}
fun: SIN {$$=$1;}
    |COS {$$=$1;}
    |EXP {$$=$1;}
    |LOG {$$=$1;}
%%
int main(int argc, char** argv){
////   yydebug = 1;
//   if(argc ==1)
//       derivand = xconst;
//   else
//       yyin = fopen(argv[1], "r");
    char input[] = "a + D[x, x*x] + b";
    int i = 0;
    char *aguy = (char*) malloc(strlen(input)+2);
    char *p1 = aguy;
    char *p2 = input;
    while(*p2!=']'){
        *p1 = *p2;
        p1++; p2++;
    }
    *p1 = *p2;//assign ']'
    p1++; *p1 = '\0';//Null terminate string

    p2++;
    char* bguy = ++p1;
    char stop = 0;
    while(!stop)
    {
        stop = (*p2 == '\0');
        *p1 = *p2;
        p1++; p2++;
    }
    printf("s1: %s, s2: %s\n", aguy, bguy);
    init_inStack(&myInputStack);
    addToInputStack(&myInputStack, bguy);
    addToInputStack(&myInputStack, aguy);
    popInputStack(&myInputStack, &yyin);
    yyparse();
}

int yyerror(char* str){return -1;}
