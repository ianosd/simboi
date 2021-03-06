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
} prodstruct;

typedef struct exp_struct{
    prodstruct* firstTerm;
    struct exp_struct* nextTerm;
}sumstruct; 

int getsymid(const char* sym);
void initVarHash();
char* getsymtext(int id);
int symord(int a, int b);
sumstruct* emptysum();
sumstruct* termedsum(prodstruct*);
prodstruct* emptyprod();
node* maketerm(const char* sym);
void multerm_num(prodstruct* prod, int n);
void multerm_sym(prodstruct* prod, const char* sym);
void multerms(prodstruct* dst, const prodstruct* other);
void mulsums( sumstruct* dst, sumstruct* other); 
void addsums(sumstruct* dst, sumstruct* other); 
void addTerm(sumstruct* sum, prodstruct* p);
void printsum(sumstruct*);
sumstruct* copySum(const sumstruct* sum);
#endif
