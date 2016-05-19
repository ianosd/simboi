#ifndef INPUTSTACK_H_INC
#define INPUTSTACK_H_INC
#define MAX_FILES 10
#include <stdio.h>

typedef struct inputStack_str{
int stackptr;
FILE* files[MAX_FILES];
} instack_t;

void init_inStack(instack_t* stack);

void addToInputStack(instack_t* stack, char* str);

int popInputStack(instack_t*stack, FILE** target);

#endif
