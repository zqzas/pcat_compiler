#--------------------------------------------------------------------------------
#
# Makefile for the PCAT AST generation
#
#--------------------------------------------------------------------------------


GCC = gcc
CFLAGS = -g
YACC = bison
YFLAGS = -d
LEX = flex

all: parser

parser: main.c ast.h pcat.o ast.o
	$(GCC) $(CFLAGS) main.c pcat.o ast.o -o parser

ast.o:  ast.c ast.h
	$(GCC) $(CFLAGS) -c ast.c

pcat.c: pcat.y
	$(YACC) $(YFLAGS) pcat.y
	mv pcat.tab.c pcat.c

pcat.o: pcat.c pcat.yy.c ast.h
	$(GCC) $(CFLAGS)  -c pcat.c

pcat.yy.c: pcat.lex
	   $(LEX) pcat.lex
	   mv lex.yy.c pcat.yy.c

clean:
	/bin/rm -f *.o *~ pcat.yy.c pcat.tab.h pcat.c pcat.output parser core
