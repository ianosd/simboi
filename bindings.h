#ifndef BIND_H_INCLUDED
#define BIND_H_INCLUDED
#include "derres.h"
#define MAX_BINDINGS 255

extern sumstruct* bindings[MAX_BINDINGS];

void initBindings(){
  int i = 0;
  for(i = 0; i<MAX_BINDINGS; i++)
    bindings[i] = NULL;
}

void bind(const char* sym, const sumstruct* exp){
  bindings[getsymid(sym)] = copySum(exp);
}

sumstruct* findbinding(const char* sym){
  int id = getsymid(sym);
  sumstruct* b0 = bindings[id];
  if(b0!=NULL)
    return copySum(b0);
  
  prodstruct* term = emptyprod();
  multerm_sym(term, sym);
  return termedsum(term);
}

#endif
