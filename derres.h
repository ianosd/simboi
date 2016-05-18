#ifndef DERRES_H_I
#define DERRES_H_I


typedef struct stringpair{ 
   char* dertext;
   char* inittext;
} derres;

typedef struct node_struct{
    int id;
    struct node_struct* next;
}node ;

typedef struct term_struct{
    int mul;
    node* term;
    struct term_struct* nextterm;
} prodstruct;

typedef struct exp_struct{
    prodstruct* firstTerm;
}sumstruct; 

int getsymid(char* sym);
sumstruct* emptysum();
prodstruct* emptyprod();
node* maketerm(char* sym);
void multerm_num(prodstruct* prod, int n);
void multerm_sym(prodstruct* prod, char* sym);
void addTerm(sumstruct* sum, prodstruct* p);
void printsum(sumstruct*);
#endif
