#include "derres.h"
#include <stdlib.h>
#include <stdio.h>

int sign(int a){
    if(a>0)
    return 1;
    else if (a<0) return -1;
    else return 0;
}


int termcmp(node* a, node* b){
    if(a == NULL){
        if(b == NULL)
            return 0;
        else return -1;//a is shorter than b
    }
    else if (b == NULL) return 1; //a is longer than b
    else{
    int so = symord(a->id, b->id);
    if(so == 0)
        return termcmp(a->next, b->next);
    else return so;
    }
}
//returns the sign of "a-b"(as symbolic expressions)
int prodcmp(prodstruct* a, prodstruct* b){
    if(a->term == NULL){
        if(b->term == NULL)
            return 0;
        else
            return -1;//free expression is always smaller
    }
    else if(b->term == NULL) return 1;//b is free, bigger than a
    else return termcmp(a->term, b->term);
}

void append(node* a, node* b){
    if(b!=NULL){
        if(a->next == NULL){
            a->next = b;
        }
        else {
            node* nexta, *nextb;
            if(symord(a->next->id, b->id)<=0){
                nexta = a->next;
                nextb = b;
            }
            else{
                nexta = b;
                nextb = a->next;
                a->next = b;
            }
            append(nexta, nextb);
        }
    }
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

prodstruct* copyProd(const prodstruct* prod){
  prodstruct* copy = (prodstruct*) malloc(sizeof(prodstruct));
  copy->mul = prod->mul;
  copy->term = copyNode(prod->term);
  return copy;
}

sumstruct* copySum(const sumstruct* sum){
  sumstruct* copy = NULL;
  if(sum!=NULL)
  {
    copy = (sumstruct*) malloc(sizeof(sumstruct));
    copy->firstTerm = copyProd(sum->firstTerm);
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

void multerm_sym(prodstruct* prod, const char* sym){
    node* n = maketerm(sym);
    n->next = prod->term;
    prod->term = n;
}

void multerms(prodstruct* dest, const prodstruct* otherorig){
prodstruct* other = copyProd(otherorig);
#ifdef LOG
    printf("mul: ");printterm(dest);printterm(other); printf("\n");
#endif
  dest->mul *= other->mul;
  if(dest->term !=NULL){
      //check if other should actually come first
      if(other->term!=NULL){
          node* ot = other->term;
          if(symord(ot->id, dest->term->id)<0){
              other->term = dest->term;
              dest->term = ot;
          }
          append(dest->term, other->term);
      }
  }
  else
    dest->term = other->term;
#ifdef LOG
    printf("Result: "); printterm(dest);printf("\n");
#endif
}

void sumtimesprod(sumstruct* dst, prodstruct* other){
#ifdef LOG
    printf("Multiplying: ");printsum(dst);printf(" by ");printterm(other);printf("\n");
#endif
sumstruct* save = dst;
  while(dst!=NULL){
    multerms(dst->firstTerm, other);
    #ifdef LOG
        printf("now other is: "); printterm(other);printf("and firstterm: ");printterm(dst->firstTerm);
#endif
    dst = dst->nextTerm;
  }
#ifdef LOG
    printf("RES: ");printsum(save);printf("\n");
#endif
}

//this is louzy
int convorder(sumstruct* a, sumstruct* b){
    return prodcmp(a->firstTerm, b->firstTerm);
}

void compress(sumstruct* sum){
    if(sum->firstTerm->mul == 0){
        //you could release firstTerm here

        //skip the first term
        //are you sure it will be enough?
        sum->firstTerm = sum->nextTerm->firstTerm;
        sum->nextTerm = sum->nextTerm->nextTerm;
    }
    while(sum->nextTerm != NULL){
        int comp = convorder(sum, sum->nextTerm);
        if (comp == 0){
            sum->firstTerm->mul += sum->nextTerm->firstTerm->mul;
            sum->nextTerm = sum->nextTerm->nextTerm;
        }
        else{
            sum = sum->nextTerm;
        }
    }
}

void addsums2(sumstruct* dst, sumstruct* other){
    //you shure there are only elementary 0-termed sums?
    //  if(dst->nextTerm == NULL)
    //    dst->nextTerm = other->firstTerm->mul!=0?other:NULL;
    //  else addsums(dst->nextTerm, other);
    if(other != NULL){
        if(dst->nextTerm == NULL)
            dst->nextTerm = other->firstTerm->mul!=0?other:NULL;
        else {
            sumstruct* nexta, *nextb;
            int comp = convorder(dst->nextTerm, other);
            if(comp<=0){
                nexta = dst->nextTerm;
                nextb = other;
            }
            else{
                nexta = other;
                nextb = dst->nextTerm;
                dst->nextTerm = other;
            }
            addsums2(nexta, nextb);
        }
    }        
}

//!! this may modify other
void addsums(sumstruct* dst, sumstruct* other){
    if(prodcmp(other->firstTerm, dst->firstTerm)<0){
        prodstruct* aux = other->firstTerm;
        sumstruct *auxsum = other->nextTerm;
        other->firstTerm = dst->firstTerm;
        other->nextTerm = dst->nextTerm;
        dst->firstTerm = aux;
        dst->nextTerm = auxsum;//understand what happens if you do not swap lists
    }
    addsums2(dst, other);
    compress(dst);
}

void mulsums(sumstruct* dst, sumstruct* other){
  #ifdef LOG
    printf("Make Backup\n");
#endif
  sumstruct* backupdst = copySum(dst);
  #ifdef LOG
    printf("Twas the copy\n");
#endif
  sumtimesprod(dst, other->firstTerm);
  other = other->nextTerm;
  while(other != NULL){
    #ifdef LOG
        printf("Backup is: ");printsum(backupdst);printf("\n");
#endif
    sumstruct* dstcopy = copySum(backupdst);
    sumtimesprod(dstcopy, other->firstTerm);
    addsums(dst, dstcopy);
    other = other->nextTerm;
  }
}

void addTerm(sumstruct* sum, prodstruct* p){
  if(p->mul !=0){
    sumstruct* termholder = termedsum(p);
    termholder->nextTerm = sum->nextTerm;
    sum->nextTerm = termholder;
  }
}

node* maketerm(const char* sym){
    node* nod= (node*) malloc(sizeof(node));
    nod->next = NULL;
    nod->id = getsymid(sym);
    return nod;
}
void printterm(prodstruct* term){
    node* rterm = term->term;
    //dirty trick to show 0 vals ok
    if(rterm != NULL && term->mul!=0){
      if(term->mul!=1)
        printf("%d*",term->mul);
      while(rterm->next!=NULL){
        printf("%s*", getsymtext(rterm->id));
        rterm = rterm->next;
      }
        printf("%s", getsymtext(rterm->id));
    }
    else{
      printf("%d", term->mul);
    }
}

void fprintterm(FILE* f, prodstruct* term){
    node* rterm = term->term;
    if(rterm != NULL){
      if(term->mul!=1)
        fprintf(f, "%d*",term->mul);
      while(rterm->next!=NULL){
        fprintf(f, "%s*", getsymtext(rterm->id));
        rterm = rterm->next;
      }
        fprintf(f,"%s", getsymtext(rterm->id));
    }
    else{
      fprintf(f,"%d", term->mul);
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
    if(sum->firstTerm != NULL)
    printterm(sum->firstTerm);
    else printf("empty sum, weird\n");
}

void sprintsum(FILE* f, sumstruct* sum){
    prodstruct* term = sum->firstTerm;
    while(sum->nextTerm != NULL){
        fprintterm(f,term);
        fprintf(f, " + ");
        sum = sum->nextTerm;
        term = sum->firstTerm;
    }
    if(sum->firstTerm != NULL)
    fprintterm(f, sum->firstTerm);
    else printf("empty sum, weird\n");
}
