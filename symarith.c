#include "derres.h"
#include <stdlib.h>

int getsymid(char* sym){
    return sym[0];
}

sumstruct* emptysum(){
    sumstruct* asum = (sumstruct*) malloc(sizeof(sumstruct));
    asum->firstTerm = NULL;
    return asum;
}
prodstruct* emptyprod(){
    prodstruct* aprod = (prodstruct*) malloc(sizeof(prodstruct));
    aprod->mul = 1;
    aprod->term = NULL;
    aprod->nextterm = NULL;
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
    if(term->mul!=1)
    printf("%d",term->mul);
    while(rterm!=NULL){
        printf("*%c", rterm->id);
        rterm = rterm->next;
    }
}

void printsum(sumstruct* sum){
    prodstruct* term = sum->firstTerm;
    while(term != NULL){
        printterm(term);
        printf(" + ");
        term = term->nextterm;
    }
    printf("0");
}

