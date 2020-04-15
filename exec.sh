lex py_comp.l
yacc -d py_comp.y
gcc y.tab.c lex.yy.c