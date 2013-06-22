#ifndef __SYMTABLE_H__
#define __SYMTABLE_H__

typedef struct info
{
	char* typeName; 
} info;

typedef struct node
{
	char chr;
	struct node* subs;
	struct node* next;
	info* info;
} node;

node* getsub(node* n, char chr);

void addsub(node* n, node* s);

node* find(char* entry);

node* insert(node* r, char* entry, int k);

char* gettype(char* entry);

void addtype(char* entry, char* typeName);

#endif
