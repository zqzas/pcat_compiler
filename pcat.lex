/********************************************************************************
*
* File: pcat.lex
* Title: The PCAT scanner
* Student names and IDs: 
*
********************************************************************************/
%{
	#include "pcat.tab.h"

	extern int lineno;
	int columnno = 1;

	#define YY_USER_ACTION yylloc.first_line = lineno; \
						   yylloc.last_line = lineno; \
  						   yylloc.first_column = columnno; \
  						   yylloc.last_column = columnno + yyleng - 1; \
  						   columnno += yyleng; 
%}

%option noyywrap
%x COMMENT

%%

\7 					{
						yyerror("Illegal char.");
					}

"(*"	 			{
  						BEGIN(COMMENT);
  						yymore(); 
 					}

<COMMENT>\*\) 		{ 
  						BEGIN(INITIAL); 
 					}

<COMMENT><<EOF>>	{ 
  						yyerror("Unclosed comment");
  						return EOFF; 
 					}

<COMMENT>. 			{
  						yymore();
 					}

<COMMENT>\n 		{ 
  						columnno = 1;
  						lineno++;
  						yymore(); 
 					}

AND 				return AND;
ARRAY				return ARRAY;
BEGIN				return BEGINT;
BY					return BY;
DIV					return DIV;
DO					return DO;
ELSE				return ELSE;
ELSIF				return ELSIF;
END					return END;
EXIT				return EXIT;
FOR					return FOR;
IF					return IF;
IN 					return IN;
IS 					return IS;
LOOP				return LOOP;
MOD					return MOD;
NOT					return NOT;
OF					return OF;
OR					return OR;
OUT					return OUT;
PROCEDURE			return PROCEDURE;
PROGRAM				return PROGRAM;
READ				return READ;
RECORD				return RECORD;
RETURN 				return RETURN;
THEN				return THEN;
TO					return TO;
TYPE				return TYPE;
VAR					return VAR;
WHILE				return WHILE;
WRITE 				return WRITE;

\(					return LPAREN;
\)					return RPAREN;
\[ 					return LBRACKET;
\] 					return RBRACKET;
\{					return LBRACE;
\}					return RBRACE;
\: 					return COLON;
\. 					return DOT;
\;					return SEMICOLON;
\, 					return COMMA;
:=					return ASSIGN;
\+ 					return PLUS;
\-					return MINUS;
\*					return STAR;
\/					return SLASH;
\\					return BACKSLASH;
\=					return EQ;
\<\>       			return NEQ;
\<					return LT;
\<\=				return LE;
\>					return GT;
\>\=				return GE;
\[\<				return LABRACKET;
\>\]				return RABRACKET;

[a-zA-Z][a-zA-Z0-9]* {
  						if(yyleng>255)
    						yyerror("ILLEGAL IDENTIFIER: overly long, more than 255 in length");
  						return IDENTIFIER;
					}

\"[^\"\t\n]*\" 		{
						if (yyleng - 2 > 255)
							yyerror("ILLEGAL STRING: overly long, more than 255 in length");
						return STRINGT;
					}

\"([^\"])*\" 		{
						yyerror("ILLEGAL STRING: including illegal char");
						return STRINGT;
					}

\"([^\"\n])*		{
						yyerror("UNTERMINATED STRING: lacking of tag\"");
						return STRINGT;
					}

[0-9]+\.[0-9]* 		{
						if (yyleng > 255)
							yyerror("ILLEGAL REAL: overly long, more than 255 in length");
						return REALT;
					}

[0-9]+ 				{
						if (yyleng > 10 || (yyleng == 10 && (strcmp(yytext, "4294967295") > 0)))
							yyerror("INVALID INTEGER: larger than (2^31 - 1)");
						return INTEGERT;
					}

<<EOF>> 			{
						return 0;
					}

[\ \t] 				{
					
					}

\n 					{
					  	columnno = 1;
  						lineno++;
					}

.                	{ 
						yyerror("ILLEGAL CHAR");
						return ERROR; 
					}
%%
