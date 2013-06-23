#include "typecheck.h"
#include "symtable.h"
#include <stdio.h>
#include <string.h>

extern node* root;

void error(char* msg, ast* n)
{
	printf("at line %d : %s\n", n->loc.first_line, msg);
}

int isInt(ast* n)
{
	return (strcmp(n->type, "INTEGER") == 0);
}

int isReal(ast* n)
{
	return (strcmp(n->type, "REAL") == 0);
}

int isBool(ast* n)
{
	return (strcmp(n->type, "BOOL") == 0);
}

int isStr(ast* n)
{
	return (strcmp(n->type, "STRING") == 0);
}

int isVoid(ast* n)
{
	return (strcmp(n->type, "VOID") == 0);
}

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
	if (isVoid(lv))
		return;
	if ((isReal(lv) && !isReal(expr) && !isInt(expr)) || (!isReal(lv) && strcmp(lv->type, expr->type) != 0))
	{
		char msg[60];
		strcpy(msg, "cannot assign ");
		strcat(msg, expr->type);
		strcat(msg, " to ");
		strcat(msg, lv->type);
		error(msg, lv);
	}
}

void handle_cond(ast* c)
{
	if (strcmp(c->type, "BOOL") != 0)
		error("condition must be BOOL expression", c);
}

char* handle_expr_single(char* op, ast* a)
{
	if (strcmp(op, "NOT") == 0)
	{
		if (!isBool(a))
		{
			char msg[100];
			strcpy(msg, "expected BOOL but got ");
			strcat(msg, a->type);
			error(msg, a);
			return "TYPE_ERROR";
		}
		return "BOOL";
	}
	else
	{
		if (!isInt(a) && !isReal(a))
		{
			char msg[100];
			strcpy(msg, "expected INTEGER or REAL but got ");
			strcat(msg, a->type);
			error(msg, a);
			return "TYPE_ERROR";
		}
		return a->type;
	}
}

char* handle_expr_double(char* op, ast* l, ast* r)
{
	int lIsReal = isReal(l), lIsInt = isInt(l), 
		rIsReal = isReal(r), rIsInt = isInt(r);
	if ((strlen(op) == 1) && (op[0] == '+' || op[0] == '-' || op[0] == '*' || op[0] == '/'))
	{
		if ((lIsReal || lIsInt) && (rIsReal || rIsInt))
		{
			if (lIsReal || rIsReal)
				return "REAL";
			else 
				return "INTEGER";
		}
		else 
		{
			error("operator applies only to numeric type", l);
			return "TYPE_ERROR";
		}
	}
	if (strcmp(op, "MOD") == 0 || strcmp(op, "DIV") == 0)
	{
		if (lIsInt && rIsInt)
			return "INTEGER";
		else 
		{
			error("operator applies only to INTEGER", l);
			return "TYPE_ERROR";
		}
	}
	if (strcmp(op, "<") == 0 || strcmp(op, ">") == 0 || strcmp(op, "=") == 0 || 
		strcmp(op, "<=") == 0 || strcmp(op, ">=") == 0 || strcmp(op, "<>") == 0)
	{
		if ((lIsReal || lIsInt) && (rIsReal || rIsInt))
			return "BOOL";
		else
		{
			error("operator applies only to numeric type", l);
			return "TYPE_ERROR";
		}
	}
}

char* lookup(ast* n)
{
	char* ret = gettype(n->info.variable);
	if (strcmp(ret, "UNDEFINED") == 0)
		error("Undefined identifier", n);
	return ret;
}
