all: vocab gram compile

vocab: diflex.l
	lex diflex.l

gram: difgram.y
	yacc -d difgram.y

compile: vocab gram safecat.h kdifFun.c
	gcc -o diff lex.yy.c y.tab.c kdifFun.c

