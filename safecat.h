#ifndef SAFECAT_H_INCLUDED
#define SAFECAT_H_INCLUDED

#include <stdarg.h>
#include <stdio.h>

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

derres makeres(char* a, char* b){
    derres d = {a, b};
    return d;
}
#endif
