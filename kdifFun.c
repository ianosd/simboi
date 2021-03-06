#include "safecat.h"
#include "y.tab.h"

derres makeres(const char* a,const char* b){
    char* copy_a = (char*)malloc(strlen(a)*sizeof(char));
    char* copy_b = (char*)malloc(strlen(b)*sizeof(char));
    strcpy(copy_a, a);
    strcpy(copy_b, b);
    derres d = {copy_a, copy_b};
    return d;
}
char* safecat(int n, char* format, ...)
{
    va_list argptr;
    va_start(argptr, format);
    int size = 0;
    int i;
    for(i = 0; i<n; i++){
        size += strlen(va_arg(argptr, char*));
    }
    va_end(argptr);
    char* result = (char*) malloc((size+strlen(format))*sizeof(char));
    va_start(argptr, format);
    vsprintf(result, format, argptr);
    va_end(argptr); 
    return result;
}
derres kdifFun(int funCode){
#ifdef DOLOG
    printf("Switching on code: %d\n", funCode);
#endif
    switch(funCode){
        case SIN:
            return makeres("cos", "sin");
        case COS:
            return makeres("-sin", "cos");
        case EXP:
            return makeres("exp", "exp");
        case LOG:
            return makeres("inv", "log");
        }
        }
derres onVariable(const char* varname,const char* derivand){
    if(strcmp(varname, derivand) == 0)
        return makeres("1", derivand);
    return makeres("0", varname);
}
char* difFun(const char* infun){
   if(strcmp(infun, "sqr")==0) 
	return "double";
   else if(strcmp(infun, "sin")==0)
        return "cos";
   else {
       char* newchar = (char*) malloc(sizeof(infun) + 2);
       strcpy(newchar, infun);
       strcat(newchar, "'");
       return newchar;
    }
}
