%{
#include "derres.h"
#include "y.tab.h"
#include "inputstack.h"
extern instack_t myInputStack;

%}
%%

#.* ;//ignore everything beginning with a #
[+*()\[\]D,=!] 	return yytext[0];
[a-z]+'? {char*  copy = malloc(strlen(yytext)+1); strcpy(copy, yytext);  yylval.text = copy; return UNKN;}
[0-9]+ {
#ifdef DOLOG
    printf("Ident text as number");
#endif
yylval.num = atoi(yytext); return NUM;}
[ \t] 
. 	{
    printf("Lexical error");
return 0;}
[\n\0]      return 0;
%%

int yywrap(){
       #ifdef DOLOG
        printf("Reached end of stream\n");
#endif
return 1-popInputStack(&myInputStack, &yyin);
}

void scan_string(char* str){
    printf("Trying to read from string %s\n", str);
    yy_flush_buffer(YY_CURRENT_BUFFER);
    yy_switch_to_buffer(yy_scan_string(str));
}
void done_scan_string(){
    yypop_buffer_state();
}
