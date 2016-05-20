#include "derres.h"
#include <stdlib.h>
#include <string.h>
#define MAX_VARS 64
#define RMAX_VARS 256
typedef struct hns{
    char* text;
    int key;
    struct hns* next;
}hash_node;
hash_node* table[MAX_VARS];
char* texttable[RMAX_VARS];
int symcount;

int hashValue(const char* sym){
    int hash = 0;
    while(*sym!='\0')
        hash+=*(sym++);
    return hash%MAX_VARS;
}

int symord(int a, int b){
    return strcmp(texttable[a], texttable[b]);
}

int getsymid(const char* sym){
    int hash = hashValue(sym);
    hash_node* nod = table[hash];
    char found = 0;
    int id;
    if(nod!=NULL){
        while(nod->next!=NULL && !found){
            found = (strcmp(sym, nod->text)==0); 
            id = found?nod->key:-1;
            nod = nod->next;
        }
        //check last node
        found = (strcmp(sym, nod->text)==0);
        id = found?nod->key:-1;
        //if still not there, insert it
        if(!found){
            id = symcount++;
            hash_node* newnode = (hash_node*) malloc(sizeof(hash_node));
            newnode->key = id;
            newnode->text = strdup(sym);
            newnode->next = NULL;
            nod->next = newnode;
            texttable[id] = newnode->text;
        }
    }
    else{
            id = symcount++;
            hash_node* newnode = (hash_node*) malloc(sizeof(hash_node));
            newnode->key = id;
            newnode->text = strdup(sym);
            newnode->next = NULL;
            table[hash] = newnode;
            texttable[id] = newnode->text;
    }
    return id;
}
char* getsymtext(int id){
    return texttable[id];
}
void initVarHash(){
    for(int i = 0; i<RMAX_VARS; i++){
        texttable[i] = NULL;
    }
    for(int i = 0; i<MAX_VARS; i++)
        table[i] = NULL;
    symcount = 0;
}
