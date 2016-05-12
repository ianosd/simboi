#ifndef SAFECAT_H_INCLUDED
#define SAFECAT_H_INCLUDED

#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "derres.h"

char* safecat(int n, char* format, ...);

derres makeres(const char* a,const char* b);
derres onVariable(const char* varname,const char* derivand);
char* difFun(const char* infun);
derres kdifFun(int funcode);
#endif
