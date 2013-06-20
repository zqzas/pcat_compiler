/********************************************************************************
*
* File: ast.h
* The abstract syntax trees for the calculator
* Programmer: Leonidas Fegaras, UTA
* Date: 12/17/97
*
********************************************************************************/


#include "malloc.h"
#include "pcat.tab.h"

extern int format;

/* Put the names of all the different kinds of ASTs here */

typedef enum { TYPE_NAME, FP_SEC, FM_PARAMS, COMP, TYPE_DEF, REC_DEF, 
               TYPE_NAME_DEC, TYPE_DECL, PROC_DECL, VAR_DECL, DECLAR_VAR, DECLAR_TYPE, DECLAR_PROC, 
               BODY, PROG, ARR_INIT_OF, 
               IF_ST, LVAL_EXP, PAREN_EXP, EQ_EXP, LT_EXP, GT_EXP, LE_EXP, NEQ_EXP, GE_EXP, PLUS_EXP, UPLUS_EXP, MINUS_EXP, UMINUS_EXP, 
               TIMES_EXP, SLASH_EXP, DIV_EXP, MOD_EXP, OR_EXP, AND_EXP, NOT_EXP, CALL_EXP, REC_EXP, ARRINIT_EXP, fnc_def, 
               VARIABLE, ARR_DEREF, REC_DEREF, PARAM_LST, RECORD_INIT, ARR_INIT, ARR_INIT_BATCH, WRT_PARAM, 
               ASSIGN_ST, CALL_ST, READ_ST, WRT_ST, ELSIF_ST, ELSE_ST, EMPTY_EXP, WHILE_ST, LOOP_ST, BY_EXP, FOR_ST, EXIT_ST, RETURN_ST
} ast_kind;

static char* ast_names[] = {
   "type_name", "formal_parameters_section", "formal_parameters", "component", "type_definition", "record_definition", 
   "type_name_declaration", "type_declaration", "procedure_declaration", "variable_declaration", "declare_variable", "declare_type", "declare_procedure", 
   "body", "program", "array_initialization_of", 
   "if_statement", "lvalue_expression", "paren_expression", "equation_expression", "less_than_expression", "greater_than_expression", 
   "less_than_expression", "not_equal_expression", "greater_equal_expression", "plus_expression", 
   "upluc_expression", "uminux_expression",
   "uminux_expression", "times_expression", "slash_expression", "divide_expression", "mod_expression", "or_expression", "and_expression", "not_expression", 
   "call_expression", "record_expression", "array_initialization_expression", "function_definition", 
   "variable", "array_definition", "record_definition", "parameters_list", "record_initialize", "array_initialize", "array_batch_initialize", "write_parameters",
   "assign_statement", "call_statement", "read_statement", "write_statement", "elsif_statement", "else_statement", "empty_exp", 
   "while_statement", "loop_statement", "by_expression", "for_statement", "exit_statement", "return_statement"
};


/* This is a universal data structure that can capture any AST:
 * The node is an internal node and has a list of children (other ASTs),
 * while the other nodes are leaves       */

typedef struct ast {
  enum { int_ast, real_ast, var_ast, str_ast, opr_ast, kwd_ast, dlmt_ast, node_ast } tag;
  union { int          integer;
          double        real;
          char*         variable;
          char*         string;
          char*         oprt;
          char*         keyword;
          char*         delimiter;
          struct { ast_kind          tag;
                   struct ast_list*  arguments;
	  } node;
      } info;
  struct {
    int first_line, last_line, first_column, last_column;
  } loc; 
} ast;

typedef struct ast_list { 
  ast*             elem;
  struct ast_list* next;
} ast_list;


/* create an integer AST leaf */
ast* mk_int ( const int x, YYLTYPE *yylloc );


/* create a floating point AST leaf */
ast* mk_real ( const double x, YYLTYPE *yylloc );


/* create an AST leaf for a name */
ast* mk_var ( const char* x, YYLTYPE *yylloc );

/* create a string AST leaf */
ast* mk_str ( const char* x, YYLTYPE *yylloc );

/* create an operator AST leaf */
ast* mk_opr ( const char* x, YYLTYPE *yylloc);

ast* mk_kwd ( const char* x, YYLTYPE *yylloc);

ast* mk_dlmt( const char* x, YYLTYPE *yylloc);


/* create an internal AST node */
ast* mk_node ( const ast_kind tag, ast_list* args, YYLTYPE *yylloc);

ast_list* multicons(int nops, ...);

/* put an AST e in the beginning of the list of ASTs r */
ast_list* cons ( ast* e, ast_list* r );

/* connect two AST list */ 
ast_list* conlst ( ast_list* l, ast_list* r);


/* the empty list of ASTs */
#define null NULL


/* size of an AST list */
short length ( ast_list* );

/* reverse the order of ASTs in an AST list */
ast_list* reverse ( ast_list* );

void print_loc( ast* x );

/* printing functions for ASTs */
void print_ast_list ( ast_list* r );

void print_ast ( ast* x );

void print_ast_list_tree( ast_list* r, int depth);

void print_ast_tree( ast* x, int depth, int isLast);

void print_tree( ast* x);