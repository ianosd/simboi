%{
typedef struct{ 
   char* dertext;
   char* inittext;
} derres;
%}
%token NUM, UNKN
%union{
	derres res;
}
%type <res> der
%%
start: der {printf("%s", $1);}
der: der '+' der {$$ = {safecat("%s + %s", $1.dertext, $3.dertext), safecat("%s + %s", %1.inittext, $3.inittext)};}
    |'x' {$$={"1", "x"};}
    | der '*' der { $$ = {safecat("(%s)*(%s) + (%s)*(%s)", $1.inittext, $3.dertext, $1.dertext, $3.inittext), safecat("%s * %s", $1.inittext, $3.inittext)}; }
    |UNKN { $$ = {"0", yytext};}
%%
int main(){
   yyparse();
}

int yyerror(char* str){return -1;}

