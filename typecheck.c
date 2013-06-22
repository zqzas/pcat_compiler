#include "typecheck.h"
#include "symtable.h"
#include <stdio.h>

extern node* root;

void handle_var_decl(ast_list* vars, char* type, char* expr)
{
	char* t;
	if (strcmp(type, "VOID") != 0)
		t = type;
	else 
		t = expr;

	ast_list* p = vars;
	while (p != NULL)
	{
		p->elem->type = t;
		addtype(p->elem->info.variable, t);
		p = p->next;
	}
}

char* getid(ast* id)
{
	return id->info.variable;
}

void handle_assign(ast* lv, ast* expr)
{

}

void handle_cond(ast* c)
{
	if (strcmp(c->type, BOOL) != 0)
		error("condition must be bool expression", c);
}

char* handle_expr_single(char* op, ast* a)
{
	return "VOID";
}

char* handle_expr_double(char* op, ast* l, ast* r)
{
	return "VOID";
}

char* lookup(ast* n)
{
	char* ret = gettype(n->info.variable);
	puts(ret);
	return ret;
}

void error(char* msg, ast* n)
{
	puts(msg);
	printf("at line %d\n", n->loc.first_line);
}
