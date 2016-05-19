#include "derres.h"
#include <stdlib.h>

int getsymid(char* sym){
    return sym[0];
}
node* copyNode(node* n){
  node* ret=NULL;
  if(n!=NULL){
    ret = (node*) malloc(sizeof(node));
    ret->id = n->id;
    ret->next = copyNode(n->next);
  }
  return ret;
}

prodstruct* copyProd(prodstruct* prod){
  prodstruct* copy = (prodstruct*) malloc(sizeof(prodstruct));
  copy->mul = prod->mul;
  copy->term = copyNode(prod->term);
  return copy;
}

sumstruct* copySum(sumstruct* sum){
  sumstruct* copy = NULL;
  if(sum!=NULL)
  {
    copy = (sumstruct*) malloc(sizeof(sumstruct));
    copy->firstTerm = copyProd(sum->term);
    copy->nextTerm = copySum(sum->nextTerm);
  }
  return copy;
}


sumstruct* emptysum(){
    sumstruct* asum = (sumstruct*) malloc(sizeof(sumstruct));
    asum->firstTerm = NULL;
    asum->nextTerm = NULL;
    return asum;
}
sumstruct* termedsum(prodstruct* p){
    sumstruct* asum = (sumstruct*) malloc(sizeof(sumstruct));
    asum->firstTerm = p;
    asum->nextTerm = NULL;
    return asum;
}
prodstruct* emptyprod(){
    prodstruct* aprod = (prodstruct*) malloc(sizeof(prodstruct));
    aprod->mul = 1;
    aprod->term = NULL;
    return aprod;
}


void multerm_num(prodstruct* prod, int n){
    prod->mul *= n;
}

void multerm_sym(prodstruct* prod, char* sym){
    node* n = maketerm(sym);
    n->next = prod->term;
    prod->term = n;
}
void multerms(prodstruct* dest, prodstruct* other){
  dest->mul *= other->mul;
  if(dest->term !=NULL)
    append(dest->term, other->term);
  else
    dest->term = other->term;
}
void mulsums(sumstruct* dst, sumstruct* other){
}  
void addTerm(sumstruct* sum, prodstruct* p){
  if(p->mul !=0){
    sumstruct* termholder = termedsum(p);
    termholder->nextTerm = sum->nextTerm;
    sum->nextTerm = termholder;
  }
}

void append(node* a, node* b){
  if(a->next == NULL){
    a->next = b;
  }
  else append(a->next, b);
}
node* maketerm(char* sym){
    node* nod= (node*) malloc(sizeof(node));
    nod->next = NULL;
    nod->id = getsymid(sym);
    return nod;
}
void printterm(prodstruct* term){
    node* rterm = term->term;
    if(rterm != NULL){
      if(term->mul!=1)
        printf("%d*",term->mul);
      while(rterm->next!=NULL){
        printf("%c*", rterm->id);
        rterm = rterm->next;
      }
      printf("%c", rterm->id);
    }
    else{
      printf("%d", term->mul);
    }
}

void printsum(sumstruct* sum){
    prodstruct* term = sum->firstTerm;
    while(sum->nextTerm != NULL){
        printterm(term);
        printf(" + ");
        sum = sum->nextTerm;
        term = sum->firstTerm;
    }
    printterm(sum->firstTerm);
}

