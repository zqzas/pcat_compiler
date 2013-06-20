/********************************************************************************
*
* File: main.c
* Testing the PCAT parser
* Programmer: Leonidas Fegaras, UTA
* Date: 2/3/00
* 
********************************************************************************/

#include "ast.h"
#include <stdio.h>

int lineno = 1;
int format = 0;

extern FILE* yyin;

void yyparse();


int main ( int argc, char* arg[] ) {

  if (argc>1)
     yyin = fopen(arg[1],"r");

  if (argc>2)
  {
  		if (arg[2][1] == 's') format = 1;
  		if (arg[2][1] == 'f') format = 2;
  }
  yyparse();

};
