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
/*arithmetic-specific gramar*/

start: expr {printf("Identified expression:\n"); printsum($1);}
expr: term {printf("Made empty sum"); $$=termedsum($1);}
    | '(' expr ')' {$$ = $2;}
    | expr '*' expr { printf("Multiplying two sum expressions\n");$$ = $1; mulsums($$, $3); }
    | expr '+' expr {$$ = $1; addsums($$, $3);}

/*this one to allow derivatives to be expressions*/
expr: 'D' '[' UNKN {derivand = strdup($3);printf("Diff rel to %s\n", derivand);} 
      ',' der ']'{ //as soon as der text is avalible, add it to the input stack
                addToInputStack(&myInputStack,$6.dertext);
                printf("dErtext = %s\n", $6.dertext);//TODO dealocate derivand}
            } 
            expr {$$=$9;};



term: NUM  {$$ = emptyprod(); multerm_num($$, $1);} 
    | UNKN {$$ = emptyprod(); multerm_sym($$, $1);}
    /*| term '*' term {$$ = $3; multerms($$, $1);printf("Mut term*term\n");}*/
    /*| '(' term ')' {$$ = $2;}*/

/*end of arithmetic gramar*/

der: der '+' der {char* deriv = safecat(2, "(%s + %s)", $1.dertext, $3.dertext);
		  char* init = safecat(2, "(%s + %s)", $1.inittext, $3.inittext);
                  $$ = makeres(deriv, init);
                 }
    | der '*' der {  char* deriv = safecat(4, "((%s)*(%s) + (%s)*(%s))", $1.inittext, $3.dertext, $1.dertext, $3.inittext);
		     char* init =  safecat(2, "((%s) * (%s))", $1.inittext, $3.inittext);
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
    |'(' der ')' {char* dert = safecat(1, "(%s)", $2.dertext); char* text = safecat(1, "(%s)", $2.inittext); $$ = makeres(dert, text);}

fun: SIN {$$=$1;}
    |COS {$$=$1;}
    |EXP {$$=$1;}
    |LOG {$$=$1;}
%%
void splitByChar(char c, const char *input, char** a, char** b){
    char* aguy = (char*) malloc(strlen(input)+2);
    char *bguy;
    char *p1 = aguy;
    const char *p2 = input;
    while(*p2!=c && *p2 != '\0'){
        *p1 = *p2;
        p1++; p2++;
    }
    *p1 = *p2;//assign ']'
    p1++; *p1 = '\0';//Null terminate string
    if(*p2 == 0){
      bguy = p1;
    }
    else{
    p2++;
    bguy = ++p1;
    char stop = 0;
    while(!stop)
    {
      stop = (*p2 == '\0');
      *p1 = *p2;
      p1++; p2++;
    }}
    *a = aguy;
    *b = bguy;
}
int main(int argc, char** argv){
    char input[100] = "notexit";
    if(argc ==1)
        derivand = xconst;
    else
        strcpy(input, argv[1]);
    char *a, *b;
    while(strcmp(input, "exit")!=0){
        printf("Input = %s\n", input);
        splitByChar(']', input, &a, &b);
        printf("s1: %s, s2: %s\n", a, b);
        init_inStack(&myInputStack);
        addToInputStack(&myInputStack, b);
        addToInputStack(&myInputStack, a);
        popInputStack(&myInputStack, &yyin);
        yyparse();
        printf("(Done)\n");
        scanf("%99s", input);
    }
}

int yyerror(char* str){return -1;}
