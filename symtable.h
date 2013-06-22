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

node* root;

char* gettype(char* entry);

void addtype(char* entry, char* typeName);

node* make_node(char chr);

#endif
