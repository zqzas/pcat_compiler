/********************************************************************************
*
* File: ast.c
* The abstract syntax trees for the calculator
* Programmer: Leonidas Fegaras, UTA
* Date: 12/17/97
*
********************************************************************************/

#include "ast.h"
#include <string.h>
#include <stdarg.h>

void setup_loc( ast* res, YYLTYPE *yylloc)
{
  if (yylloc == NULL) return;
  res->loc.first_line = yylloc->first_line;
  res->loc.last_line = yylloc->last_line;
  res->loc.first_column = yylloc->first_column;
  res->loc.last_column = yylloc->last_column;
}

ast* mk_int ( const int x, YYLTYPE *yylloc) {
  ast* res = (ast*) malloc(sizeof(ast));
  res->tag = int_ast;
  res->info.integer = x;
  setup_loc(res, yylloc);
  res->type = "INTEGER";
  return res;
};


ast* mk_real ( const double x, YYLTYPE *yylloc) {
  ast* res = (ast*) malloc(sizeof(ast));
  res->tag = real_ast;
  res->info.real = x;
  setup_loc(res, yylloc);
  res->type = "REAL";
  return res;
};


ast* mk_var ( const char* x, YYLTYPE *yylloc) {
  ast* res = (ast*) malloc(sizeof(ast));
  res->tag = var_ast;
  res->info.variable = (char*) malloc(strlen(x)+1);
  strcpy(res->info.variable,x);
  setup_loc(res, yylloc);
  return res;
};


ast* mk_str ( const char* x, YYLTYPE *yylloc) {
  ast* res = (ast*) malloc(sizeof(ast));
  res->tag = str_ast;
  res->info.string = (char*) malloc(strlen(x)+1);
  strcpy(res->info.string,x);
  setup_loc(res, yylloc);
  res->type = "STRING";
  return res;
};

ast* mk_opr  ( const char* x, YYLTYPE *yylloc) {
  ast* res = (ast*) malloc(sizeof(ast));
  res->tag = opr_ast;
  res->info.oprt = (char*) malloc(strlen(x)+1);
  strcpy(res->info.oprt,x);
  setup_loc(res, yylloc);
  return res;
}

ast* mk_kwd ( const char* x, YYLTYPE *yylloc)
{
  ast* res = (ast*) malloc(sizeof(ast));
  res->tag = kwd_ast;
  res->info.oprt = (char*) malloc(strlen(x)+1);
  strcpy(res->info.keyword,x);
  setup_loc(res, yylloc);
  return res;
}

ast* mk_dlmt( const char* x, YYLTYPE *yylloc)
{
  ast* res = (ast*) malloc(sizeof(ast));
  res->tag = dlmt_ast;
  res->info.oprt = (char*) malloc(strlen(x)+1);
  strcpy(res->info.delimiter,x);
  setup_loc(res, yylloc);
  return res;
}

ast* mk_node ( const ast_kind tag, ast_list* args, YYLTYPE *yylloc) {
  ast* res = (ast*) malloc(sizeof(ast));
  res->tag = node_ast;
  res->info.node.tag = tag;
  res->info.node.arguments = args;
  setup_loc(res, yylloc);
  return res;
};

ast_list* multicons(int nops, ...) {
    va_list ap;
    int i;
    va_start(ap, nops);
    ast_list* p = NULL;
    ast* n;
    for (i = 0; i < nops; i++)
    {
        n = va_arg(ap, ast*);
        p = cons(n, p);
    }
    va_end(ap);
    return reverse(p);
}

ast_list* cons ( ast* e, ast_list* r ) {
  ast_list* res = (ast_list*) malloc(sizeof(ast_list));
  res->elem = e;
  res->next = r;
  return res;
};

ast_list* conlst ( ast_list* l, ast_list* r)
{
    ast_list* head = l;
    if (head == NULL) return r;
    while (head->next != NULL)
      head = head->next;
    head->next = r;
    return l;
}


short length ( ast_list* r ) {
  short i = 0;
  for(; r != null; r=r->next) i++;
  return i;
};


ast_list* rev ( ast_list* r, ast_list* s ) {
  if (r == null)
     return s;
  return rev(r->next,cons(r->elem,s));
};


ast_list* reverse ( ast_list* r ) {
  return rev(r,null);
};


void print_ast_list ( ast_list* r ) {
  if (r == null)
     return;
  printf(" ");
  print_ast(r->elem);
  print_ast_list(r->next);
};


void print_ast ( ast* x ) {
  switch (x->tag) {
  case int_ast: printf("%d",x->info.integer); break;
  case real_ast: printf("%f",x->info.real); break;
  case var_ast: printf("%s",x->info.variable); break;
  case str_ast: printf("\"%s\"",x->info.string); break;
  case opr_ast:  printf("\"%s\"\n", x->info.oprt); break;
  case kwd_ast:  printf("%s\n", x->info.keyword); break;
  case dlmt_ast: printf("\"%s\"\n", x->info.delimiter); break;
  case node_ast: {
      printf("(%s",ast_names[x->info.node.tag]);
      print_ast_list(x->info.node.arguments);
      printf(")");
      break;
    };
  };
};

int buf[10000];

void print_ast_list_tree( ast_list* r, int depth)
{
    if (r == NULL) 
      return;
    if (r->next != NULL)
        print_ast_tree(r->elem, depth + 1, 0);
    else print_ast_tree(r->elem, depth + 1, 1);
    print_ast_list_tree(r->next, depth);
}
   
void print_loc( ast* x )
{ 
    if (format == 0)
      printf("\n");
    else if (format == 1)
      printf("*** Range: (%d, %d) - (%d, %d)\n", x->loc.first_line, x->loc.first_column, x->loc.last_line, x->loc.last_column);
    else printf("*** Range: (Line %d, Col %d) - (Line %d, Col %d)\n", x->loc.first_line, x->loc.first_column, x->loc.last_line, x->loc.last_column);
}

void print_ast_tree( ast* x, int depth, int isLast)
{
    if (x->tag == node_ast && x->info.node.tag == EMPTY_EXP) return;
    int i, j;
    for (i = 1; i < depth; ++i)
    {
        if (buf[i] == 0)
            printf("│");
        else printf(" ");
        for (j = 0; j < 3; ++j)
            printf(" ");
    }
    if (depth > 0)
    {
        if (isLast == 0)
            printf("├"); 
        else printf("└"); 
        for (i = 0; i < 3; ++i)
            printf("─");
    }
    switch (x->tag)
    {
        case int_ast:  printf("int %d ", x->info.integer); print_loc(x); break;
        case real_ast: printf("real %f ", x->info.real); print_loc(x); break;
        case var_ast:  printf("variable %s ", x->info.variable); print_loc(x); break;
        case str_ast:  printf("string %s ", x->info.string); print_loc(x); break;
        case opr_ast:  printf("operator \"%s\" ", x->info.oprt); print_loc(x); break;
        case kwd_ast:  printf("keyword %s ", x->info.keyword); print_loc(x); break;
        case dlmt_ast: printf("delimiter \"%s\" ", x->info.delimiter); print_loc(x); break;
        case node_ast: 
        {
            printf("%s ", ast_names[x->info.node.tag]);
            print_loc(x);
            buf[depth] = isLast;
            print_ast_list_tree(x->info.node.arguments, depth);
            break;
        }
    }
}

void print_tree( ast* x)
{
    print_ast_tree(x, 0, 0);
}
