%{
#include <stdio.h>
#include "safecat.h"
#include "inputstack.h"
#include "bindings.h"

sumstruct* bindings[MAX_BINDINGS];
const char* derivand;
const char* xconst = "x";
extern char* yytext;
extern FILE* yyin;
instack_t myInputStack;
int yydebug;
void scan_string(char*);
void done_scan_string();

//to get rid of those warnings
int yylex();
int yyerror(const char* err);
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
%right '='
%left '+'
%left '*'
%left '!'
%%
/*arithmetic-specific gramar*/

start: expr {printf("ans = "); printsum($1); bind("ans", $1); printf("\n");}
     | UNKN '=' expr {bind($1, $3); printf("%s = ", $1); printsum($3); printf("\n");}
expr: term {
#ifdef DOLOG
          printf("Made empty sum");
#endif
          $$=termedsum($1);}
    | '!' UNKN {$$ = findbinding($2); }
    | '(' expr ')' {$$ = $2;}
    | expr '*' expr { 
#ifdef DOLOG
        printf("Multiplying two sum expressions\n");
#endif
    $$ = $1; mulsums($$, $3); }
    | expr '+' expr {$$ = $1; addsums($$, $3);}

/*this one to allow derivatives to be expressions*/
expr: 'D' '[' UNKN  
    {
        derivand = strdup($3);
#ifdef DOLOG
        printf("Diff rel to %s\n", derivand);
#endif
    } 
      ',' der ']'
    { 
        //as soon as derivative text is avalible,
        //add it to the input stack
        addToInputStack(&myInputStack,$6.dertext);
        //now the parser is reading from the explicited derivative
#ifdef DOLOG
        printf("derivative = %s\n", $6.dertext);
#endif
//TODO dealocate derivand
//parse the derivative, resulting in an expression
    } 
            expr {$$=$9;};



term: NUM  {$$ = emptyprod(); multerm_num($$, $1);} 
    | UNKN {$$ = emptyprod(); multerm_sym($$, $1);}
    /*the last rule is for function identification, it will just
    treat a function term "f(arg)" as a symbol*/
    | UNKN '(' UNKN ')' {char* sym = safecat(2, "%s(%s)", $1, $3); $$ = emptyprod(); multerm_sym($$, sym);}
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
    |fun '(' der ')' {derres dd = kdifFun($1); 
    #ifdef DOLOG
        printf("Der = %s\n", dd);
#endif
char* deriv = safecat(3, "%s(%s)*(%s)", dd.dertext,  $3.inittext, $3.dertext);
                       char* init = safecat(2, "%s(%s)", dd.inittext, $3.inittext);
		       $$ = makeres(deriv, init);}
    |UNKN { 
    #ifdef DOLOG
        printf("ident(%s) as var\n", $1);
#endif
$$ = onVariable($1, derivand); } 
    |NUM {
#ifdef DOLOG
    printf("Got a number %d\n", $1);
#endif
    $$ = makeres("0", yytext);}
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

    initVarHash();
    initBindings();

    FILE* input_file = NULL;
    char input[100] = "\0notexit";
    if(argc >1)
    {
        input_file = fopen(argv[1], "r");
    }

    if(input_file == NULL)
    {
        printf("No input file, running in interactive mode\n");
        input_file = stdin;
    }
    char *a, *b;
    while(strcmp(input, "exit")!=0){

        input[0] = 0;
        fscanf(input_file, "%[^\n]99s", input);
        if(fgetc(input_file) == EOF)
        {
            printf("Finished parsing input, switching to interactive mode\n");
            fclose(input_file);
            input_file = stdin;
        }
#ifdef DOLOG
        printf("Input = %s\n", input);
#endif

        splitByChar(']', input, &a, &b);

#ifdef DOLOG
        printf("s1: %s, s2: %s\n", a, b);
#endif

        init_inStack(&myInputStack);
        addToInputStack(&myInputStack, b);
        addToInputStack(&myInputStack, a);
        popInputStack(&myInputStack, &yyin);
        yyparse();

#ifdef DOLOG
        printf("(Done)\n");
#endif

    }
}

int yyerror(const char* str){return -1;}
