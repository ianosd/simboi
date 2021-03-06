all: vocab gram compile

vocab: diflex.l
	flex  diflex.l

gram: difgram.y
	yacc -d  difgram.y

compile: vocab gram safecat.h kdifFun.c symarith.c inputstack.c multiterm.c
	gcc -o syms lex.yy.c y.tab.c kdifFun.c symarith.c inputstack.c multiterm.c

