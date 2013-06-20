%{

extern int lineno;

#include "pcat.yy.c"

#include "ast.h"

/* parse error */
yyerror ( char* s ) {
  printf("*** %s (line : %d, token: %s)\n",
         s, lineno, yytext);
};

%}
%union {
        char*           Tstring;
        struct ast*            Tast;
        struct ast_list*       Tast_list;
}

%token IDENTIFIER INTEGERT REALT STRINGT
       PROGRAM IS BEGINT END VAR TYPE PROCEDURE ARRAY RECORD
       IN OUT READ WRITE IF THEN ELSE ELSIF WHILE DO LOOP
       FOR EXIT RETURN TO BY AND OR NOT OF DIV MOD
       LPAREN  RPAREN LBRACKET RBRACKET LBRACE RBRACE COLON DOT
       SEMICOLON COMMA ASSIGN PLUS MINUS STAR SLASH BACKSLASH EQ
       NEQ LT LE GT GE LABRACKET RABRACKET EOFF ERROR

%type <Tast> program
%type <Tast> body
%type <Tast> declaration
%type <Tast_list> declaration_lst
%type <Tast> var_decl
%type <Tast_list> var_decl_lst
%type <Tast> type_decl
%type <Tast_list> type_decl_lst
%type <Tast> procedure_decl
%type <Tast_list> procedure_decl_lst
%type <Tast> typename
%type <Tast> typename_01
%type <Tast> type
%type <Tast> component
%type <Tast_list> component_lst
%type <Tast> formal_params
%type <Tast> fp_section
%type <Tast_list> fp_section_lst
%type <Tast> statement
%type <Tast_list> identifier_lst
%type <Tast> by_expression
%type <Tast_list> statement_lst
%type <Tast> statement_elsif
%type <Tast_list> statement_elsif_lst
%type <Tast> statement_else
%type <Tast> statement_else_01
%type <Tast_list> read_lval_lst
%type <Tast> write_params
%type <Tast_list> write_expr_lst
%type <Tast> write_expr
%type <Tast> expression_01
%type <Tast> expression
%type <Tast> lvalue
%type <Tast> actual_params
%type <Tast_list> actual_params_lst
%type <Tast> record_inits
%type <Tast_list> record_inits_lst
%type <Tast> array_inits
%type <Tast_list> array_init_lst
%type <Tast> array_init
%type <Tast> number
%type <Tast> identifier 
%type <Tast> string

%nonassoc    ASSIGN
%left        OR
%left        AND
%nonassoc    EQ NEQ
%nonassoc    LT LE GT GE
%left        PLUS MINUS
%left        STAR DIV MOD
%nonassoc    UMINUS UPLUS
%nonassoc    LBRACKET NOT

%%

start:                 
        program     { print_tree($1); }
      ;

program:
        PROGRAM IS body SEMICOLON               { $$ = mk_node(PROG, multicons(4, mk_kwd("PROGRAM", &@1), mk_kwd("IS", &@2), $3, mk_dlmt(";", &@4) ), &@$); }
      ;

body:
        declaration_lst BEGINT statement_lst END{ $$ = mk_node(BODY, conlst(reverse($1), cons(mk_kwd("BEGIN", &@2), reverse(cons(mk_kwd("END", &@4), $3) ) ) ), &@$); }
      ;

declaration_lst:
        declaration_lst declaration             { $$ = cons($2, $1); }
      |                                         { $$ = NULL; }
      ;

declaration:
        VAR var_decl_lst                        { $$ = mk_node(DECLAR_VAR, cons(mk_kwd("VAR", &@1), reverse($2) ), &@$); }
      | TYPE type_decl_lst                      { $$ = mk_node(DECLAR_TYPE, cons(mk_kwd("TYPE", &@1), reverse($2) ), &@$); }
      | PROCEDURE procedure_decl_lst            { $$ = mk_node(DECLAR_PROC, cons(mk_kwd("PROCEDURE", &@1), reverse($2) ), &@$); }

var_decl_lst:
        var_decl_lst var_decl                   { $$ = cons($2, $1); }
      |                                         { $$ = NULL; }
      ;

var_decl:
        identifier identifier_lst typename_01 ASSIGN expression SEMICOLON
                                                { $$ = mk_node(VAR_DECL, conlst(cons($1, reverse($2) ), multicons(4, $3, mk_opr(":=", &@4), $5, mk_dlmt(";", &@6) ) ), &@$); }
      ;

type_decl_lst:
        type_decl_lst type_decl                 { $$ = cons($2, $1); }
      |                                         { $$ = NULL; }
      ;

type_decl:
        identifier IS type SEMICOLON            { $$ = mk_node(TYPE_DECL, multicons(4, $1, mk_kwd("IS", &@2), $3, mk_dlmt(";", &@4) ), &@$); }
      ;

procedure_decl_lst:
        procedure_decl_lst procedure_decl       { $$ = cons($2, $1); }
      |                                         { $$ = NULL; }
      ;

procedure_decl:
        identifier formal_params typename_01 IS body SEMICOLON  
                                                { $$ = mk_node(PROC_DECL, multicons(6, $1, $2, $3, mk_kwd("IS", &@4), $5, mk_dlmt(";", &@6) ), &@$); }
      ;

typename:
        identifier     { $$ = mk_node(TYPE_NAME, cons($1, NULL), &@$); }
      ;

typename_01:
        COLON typename                          { $$ = mk_node(TYPE_NAME_DEC, multicons(2, mk_opr(":", &@1), $2), &@$); }
      |                                         { $$ = mk_node(EMPTY_EXP, NULL, &@$); }
      ;

type:
        ARRAY OF typename                       { $$ = mk_node(TYPE_DEF, multicons(3, mk_kwd("ARRAY", &@1), mk_kwd("OF", &@2), $3), &@$); }
      | RECORD component component_lst END      { $$ = mk_node(REC_DEF, conlst(cons(mk_kwd("RECORD", &@1), cons($2, NULL) ), reverse(cons(mk_kwd("END", &@4), $3) ) ), &@$);}
      ;

component_lst:
        component_lst component                 { $$ = cons($2, $1); }
      |                                         { $$ = NULL; }
      ;

component:
        identifier COLON typename SEMICOLON     { $$ = mk_node(COMP, multicons(4, $1, mk_dlmt(":", &@2), $3, mk_dlmt(";", &@4) ), &@$);}
      ;

formal_params:
        LPAREN fp_section fp_section_lst RPAREN { $$ = mk_node(FM_PARAMS, cons(mk_opr("(", &@1), cons($2, reverse(cons(mk_opr(")", &@4), $3) ) ) ), &@$); }
      | LPAREN RPAREN                           { $$ = mk_node(FM_PARAMS, multicons(2, mk_opr("(", &@1), mk_opr(")", &@2) ), &@$);}
      ;

fp_section_lst:
        fp_section_lst SEMICOLON fp_section     { $$ = cons($3, cons(mk_dlmt(";", &@2), $1) ); }
      |                                         { $$ = NULL; }
      ;

fp_section:
        identifier identifier_lst COLON typename{ $$ = mk_node(FP_SEC, cons($1, reverse(cons($4, cons(mk_dlmt(":", &@3), $2) ) ) ), &@$);}

identifier_lst:
        identifier_lst COMMA identifier         { $$ = cons($3, cons(mk_dlmt(",", &@2), $1) ); }
      |                                         { $$ = NULL; }
      ;

statement:
        lvalue ASSIGN expression SEMICOLON      { $$ = mk_node(ASSIGN_ST, cons($1, cons(mk_opr(":=", &@2), cons($3, cons(mk_dlmt(";", &@4), NULL) ) ) ), &@$); }
      | identifier actual_params SEMICOLON      { $$ = mk_node(CALL_ST, cons($1, cons($2, cons(mk_dlmt(";", &@3), NULL) ) ), &@$); }
      | READ LPAREN lvalue read_lval_lst RPAREN SEMICOLON { $$ = mk_node(READ_ST, cons(mk_kwd("READ", &@1), cons(mk_opr("(", &@2), cons($3, reverse(cons(mk_dlmt(";", &@6), cons(mk_opr(")", &@5), $4) ) ) ) ) ), &@$); }
      | WRITE write_params SEMICOLON            { $$ = mk_node(WRT_ST, cons(mk_kwd("WRITE", &@1), cons($2, cons(mk_dlmt(";", &@3), NULL) ) ), &@$); } 
      | IF expression THEN statement_lst 
        statement_elsif_lst
        statement_else_01 END SEMICOLON         { $$ = mk_node(IF_ST, conlst(cons(mk_kwd("IF", &@1), cons($2, cons(mk_kwd("THEN", &@3), NULL) ) ), conlst(reverse($4), conlst(reverse($5), cons($6, cons(mk_kwd("END", &@7), cons(mk_dlmt(";", &@8), NULL) ) ) ) ) ), &@$); }
      | WHILE expression DO statement_lst END SEMICOLON
                                                { $$ = mk_node(WHILE_ST, cons(mk_kwd("WHILE", &@1), cons($2, cons(mk_kwd("DO", &@3), conlst(reverse($4), cons(mk_kwd("END", &@5), cons(mk_dlmt(";", &@6), NULL) ) ) ) ) ), &@$); }
      | LOOP statement_lst END SEMICOLON        { $$ = mk_node(LOOP_ST, cons(mk_kwd("LOOP", &@1), reverse(cons(mk_dlmt(";", &@4), cons(mk_kwd("END", &@3), $2) ) ) ), &@$); }
      | FOR identifier ASSIGN expression TO expression by_expression
            DO statement_lst END SEMICOLON      { $$ = mk_node(FOR_ST, conlst( conlst(multicons(8, mk_kwd("FOR", &@1), $2, mk_opr(":=", &@3), $4, mk_kwd("TO", &@5), $6, $7, mk_kwd("DO", &@8) ), reverse($9) ), cons(mk_kwd("END", &@10), cons(mk_dlmt(";", &@10), NULL) ) ), &@$); }
      | EXIT SEMICOLON                          { $$ = mk_node(EXIT_ST, multicons(2, mk_kwd("EXIT", &@1), mk_dlmt(";", &@2) ), &@$); }
      | RETURN expression_01 SEMICOLON          { $$ = mk_node(RETURN_ST, multicons(3, mk_kwd("RETURN", &@1), $2, mk_dlmt(";", &@3) ), &@$); }
      ;

by_expression:
        BY expression                   { $$ = mk_node(BY_EXP, cons(mk_kwd("BY", &@1), cons($2, NULL) ), &@$); }
      |                                 { $$ = mk_node(EMPTY_EXP, NULL, NULL); }
      ;

expression_01:
        expression                      { $$ = $1; }
      |                                 { $$ = mk_node(EMPTY_EXP, NULL, NULL); }
      ;

statement_lst: 
        statement_lst statement         { $$ = cons($2, $1); }
      |                                 { $$ = NULL; }
      ;

statement_elsif:
        ELSIF expression THEN statement_lst     { $$ = mk_node(ELSIF_ST, cons(mk_kwd("ELSIF", &@1), cons($2, cons(mk_kwd("THEN", &@3), reverse($4) ) ) ), &@$); }
      ;

statement_elsif_lst:
        statement_elsif_lst statement_elsif     { $$ = cons($2, $1); }
      |                                         { $$ = NULL; }
      ;

statement_else:
        ELSE statement_lst              { $$ = mk_node(ELSE_ST, cons(mk_kwd("ELSE", &@1), reverse($2) ), &@$); }
      ;

statement_else_01:
        statement_else                  { $$ = $1; }
      |                                 { $$ = mk_node(EMPTY_EXP, NULL, NULL); }
      ;

read_lval_lst:
        read_lval_lst COMMA lvalue      { $$ = cons($3, cons(mk_dlmt(",", &@2), $1) ); }
      |                                 { $$ = NULL; }
      ;

write_params:
        LPAREN write_expr write_expr_lst RPAREN { $$ = mk_node(WRT_PARAM, cons(mk_opr("(", &@1), cons($2, reverse(cons(mk_opr(")", &@4), $3) ) ) ), &@$); }
      | LPAREN RPAREN                           { $$ = mk_node(WRT_PARAM, cons(mk_opr("(", &@1), cons(mk_opr(")", &@2), NULL) ), &@$); }
      ;

write_expr_lst:
        write_expr_lst COMMA write_expr { $$ = cons($3, cons(mk_dlmt(",", &@2), $1) ); }
      |                                 { $$ = NULL; }
      ;

write_expr:
        string      { $$ = $1; }
      | expression  { $$ = $1; }
      ;

expression:
        number      { $$ = $1; }
      | lvalue      { $$ = mk_node(LVAL_EXP, cons($1, NULL), &@$); }
      | LPAREN expression RPAREN  { $$ = mk_node(PAREN_EXP, cons(mk_opr("(", &@1), cons($2, cons(mk_opr(")", &@3), NULL) ) ), &@$); }
      | PLUS  expression %prec UPLUS  { $$ = mk_node(UPLUS_EXP, cons(mk_opr("+", &@1), cons($2, NULL) ), &@$);}
      | MINUS expression %prec UMINUS { $$ = mk_node(UMINUS_EXP, cons(mk_opr("-", &@1), cons($2, NULL) ), &@$); }
      | NOT   expression              { $$ = mk_node(NOT_EXP, cons(mk_opr("NOT", &@1), cons($2, NULL) ), &@$); }
      | expression PLUS  expression { $$ = mk_node(PLUS_EXP, cons($1, cons(mk_opr("+", &@2), cons($3, NULL) ) ), &@$); }
      | expression MINUS expression { $$ = mk_node(MINUS_EXP, cons($1, cons(mk_opr("-", &@2), cons($3, NULL) ) ), &@$); }
      | expression STAR  expression { $$ = mk_node(TIMES_EXP, cons($1, cons(mk_opr("*", &@2), cons($3, NULL) ) ), &@$); }
      | expression SLASH expression { $$ = mk_node(SLASH_EXP, cons($1, cons(mk_opr("/", &@2), cons($3, NULL) ) ), &@$); }
      | expression DIV   expression { $$ = mk_node(DIV_EXP, cons($1, cons(mk_opr("DIV", &@2), cons($3, NULL) ) ), &@$); }
      | expression MOD   expression { $$ = mk_node(MOD_EXP, cons($1, cons(mk_opr("MOD", &@2), cons($3, NULL) ) ), &@$); }
      | expression OR    expression { $$ = mk_node(OR_EXP, cons($1, cons(mk_opr("OR", &@2), cons($3, NULL) ) ), &@$); }
      | expression AND   expression { $$ = mk_node(AND_EXP, cons($1, cons(mk_opr("AND", &@2), cons($3, NULL) ) ), &@$); }
      | expression GT    expression { $$ = mk_node(GT_EXP, cons($1, cons(mk_opr(">", &@2), cons($3, NULL) ) ), &@$); }
      | expression LT    expression { $$ = mk_node(LT_EXP, cons($1, cons(mk_opr("<", &@2), cons($3, NULL) ) ), &@$); }
      | expression EQ    expression { $$ = mk_node(EQ_EXP, cons($1, cons(mk_opr("=", &@2), cons($3, NULL) ) ), &@$); }
      | expression GE    expression { $$ = mk_node(GE_EXP, cons($1, cons(mk_opr(">=", &@2), cons($3, NULL) ) ), &@$); }
      | expression LE    expression { $$ = mk_node(LE_EXP, cons($1, cons(mk_opr("<=", &@2), cons($3, NULL) ) ), &@$); }
      | expression NEQ   expression { $$ = mk_node(NEQ_EXP, cons($1, cons(mk_opr("<>", &@2), cons($3, NULL) ) ), &@$); }
      | identifier actual_params { $$ = mk_node(CALL_EXP, cons($1, cons($2, NULL) ), &@$); }
      | identifier record_inits  { $$ = mk_node(REC_EXP, cons($1, cons($2, NULL) ), &@$); }
      | identifier array_inits   { $$ = mk_node(ARRINIT_EXP, cons($1, cons($2, NULL) ), &@$); }
      ;

lvalue:
        identifier  { $$ = mk_node(VARIABLE, cons($1, NULL), &@$); }
      | lvalue LBRACKET expression RBRACKET { $$ = mk_node(ARR_DEREF, cons($1, cons(mk_opr("[", &@2), cons($3, cons(mk_opr("]", &@4), NULL) ) ) ), &@$); }
      | lvalue DOT identifier { $$ = mk_node(REC_DEREF, cons($1, cons(mk_opr(".", &@2), cons($3, NULL) ) ), &@$); }
      ;

actual_params:
        LPAREN expression actual_params_lst RPAREN { $$ = mk_node(PARAM_LST, cons(mk_opr("(", &@1), cons($2, reverse(cons(mk_opr(")", &@4), $3) ) ) ), &@$); }
      | LPAREN RPAREN { $$ = mk_node(PARAM_LST, cons(mk_opr("(", &@1), cons(mk_opr(")", &@2), NULL) ), &@$); }
      ;

actual_params_lst:
        actual_params_lst COMMA expression { $$ = cons($3, cons(mk_dlmt(",", &@2), $1) ); }
      |                                   { $$ = NULL; }
      ;

record_inits:
        LBRACE identifier ASSIGN expression record_inits_lst RBRACE { $$ = mk_node(RECORD_INIT, cons(mk_opr("{", &@1), cons($2, cons(mk_opr(":=", &@3), cons($4, reverse(cons(mk_opr("}", &@6), $5) ) ) ) ) ), &@$); }
      ;

record_inits_lst:
        record_inits_lst SEMICOLON identifier ASSIGN expression { $$ = cons($5, cons(mk_opr(":=", &@4), cons($3, cons(mk_dlmt(";", &@2), $1) ) ) ); }
      |                                                         { $$ = NULL; }
      ;

array_inits:
        LABRACKET array_init array_init_lst RABRACKET { $$ = mk_node(ARR_INIT_BATCH, cons(mk_opr("[<", &@1), cons($2, reverse(cons(mk_opr(">]", &@4), $3) ) ) ), &@$); }
      ;

array_init_lst:
        array_init_lst COMMA array_init { $$ = cons($3, cons(mk_dlmt(",", &@2), $1) ); }
      |                                 { $$ = NULL; }
      ;

array_init:
        expression OF expression { $$ = mk_node(ARR_INIT, multicons(3, $1, mk_kwd("OF", &@2), $3), &@$); } 
      | expression               { $$ = mk_node(ARR_INIT, cons($1, NULL), &@$); }
      ;

number:
        INTEGERT    { $$ = mk_int(atoi(yytext), &@1); }
      | REALT       { $$ = mk_real(atoi(yytext), &@1); }
      ;

string:
        STRINGT     { $$ = mk_str(yytext, &@1); }
      ;

identifier:
        IDENTIFIER  { $$ = mk_var(yytext, &@1); }
      ;

%%