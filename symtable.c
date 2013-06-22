#include "symtable.h"
#include <string.h>
#include <malloc.h>

node* root;

node* make_node (char chr) 
{
	node* n = (node*)malloc(sizeof(node));
	n->chr = chr;
	n->subs = n->next = NULL;
	n->info = NULL;
	return n;
};

node* getsub(node* n, char chr)
{
	node* pt = n->subs;
	while (pt != NULL)
	{
		if (pt->chr == chr)
			return pt;
		pt = pt->next;
	}
	return NULL;
}

void addsub(node* n, node* s)
{
	s->next = n->subs;
	n->subs = s;
}

node* find(char* entry)
{
	node* pt = root;
	int i = 0;
	for ( ; i < strlen(entry); ++i)
	{
		pt = getsub(pt, entry[i]);
		if (pt == NULL) 
			return NULL;
	}
	if (pt->info == NULL)
		return NULL;
	return pt;
}

node* insert(node* r, char* entry, int k)
{
	if (strlen(entry) == k + 1)
		return make_node(entry[k]);
	node* n = getsub(r, entry[k]);
	if (n == NULL)
	{
		n = make_node(entry[k]);
		addsub(r, n);
	}
	return insert(n, entry, k + 1);
}

char* gettype(char* entry)
{
	node* n = find(entry);
	if (n == NULL)
		return NULL;
	return n->info->typeName;
}

void addtype(char* entry, char* typeName)
{
	node* n = insert(root,entry, 0);
	n->info->typeName = typeName;
}

int main()
{
	root = make_node('#');
	addtype("a1", "int");
	puts(gettype("a1"));	
}
