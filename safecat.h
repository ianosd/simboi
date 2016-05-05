#ifndef SAFECAT_H_INCLUDED
#define SAFECAT_H_INCLUDED

#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

typedef struct stringpair{ 
   char* dertext;
   char* inittext;
} derres;

char* safecat(int n, char* format, ...){
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

derres makeres(const char* a,const char* b){
    char* copy_a = (char*)malloc(strlen(a)*sizeof(char));
    char* copy_b = (char*)malloc(strlen(b)*sizeof(char));
    strcpy(copy_a, a);
    strcpy(copy_b, b);
    derres d = {copy_a, copy_b};
    return d;
}
derres onVariable(const char* varname,const char* derivand){
    if(strcmp(varname, derivand) == 0)
        return makeres("1", derivand);
    return makeres("0", varname);
}
#endif
