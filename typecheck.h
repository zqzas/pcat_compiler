#ifndef __TYPECHECK_H__
#define __TYPECHECK_H__

#include "ast.h"

ast* tmp_node;
ast_list* tmp_list;
char* tmp_str;

void handle_var_decl(ast_list* vars, char* type, char* expr);

void handle_assign(ast* lv, ast* expr);

void handle_cond(ast* c);

char* getid(ast* p);

char* handle_expr_single(char* op, ast* a);

char* handle_expr_double(char* op, ast* l, ast* r);

char* lookup(ast* n);
#endif
