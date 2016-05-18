#include "inputstack.h"
#include <stdio.h>
void addToInputStack(instack_t* stack, char* str)
{
    FILE* f = fmemopen(str, strlen(str), "r");
    stack->stackptr++;
    stack->files[stack->stackptr] = f;
}
void init_inStack(instack_t* stack){
    stack->stackptr = -1;
}

int popInputStack(instack_t*stack, FILE** target){
   if(stack->stackptr>=0){
        *target = stack->files[stack->stackptr--];
        return 1;
        }

    return 0;
}
