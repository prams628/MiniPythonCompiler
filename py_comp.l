%{
	#include "y.tab.h"
	extern int yylineno;
	extern char *yytext;
	extern FILE *yyin;
%}

%%

[\t]+				 {printf("Returning INDENT\n"); return (INDENT);}
[ ]  				 {printf("Returning space or tab\n");}
[\n]				 {printf("%d\n", yylineno++); return (NEWLINE);}
if    				 {printf("Returning IF\n"); return(IF);}
else  				 {printf("Returning ELSE\n"); return(ELSE);}
for   			 	 {printf("returning for\n"); return (FOR);}
while 				 {printf("returning While\n"); return(WHILE);}
in    				 {printf("Returning IN\n"); return(IN);}
print				 {return(PRINT);}
range				 {return (RANGE);}
","					 {return (COMMA);}
":"					 {printf("Returning COLON\n"); return(COLON);}
"("					 {printf("Returning OCB\n"); return (OCB);}
")"					 {printf("Returning CCB\n"); return (CCB);}
"=="    			 {return(EQ);}
"<="    			 {return(LE);}
"!="    			 {return(NE);}
">"				 	 {return(GT);}
">="    			 {return(GE);}
"<"     			 {return(LT);}
True				 {return TRUE;}
False				 {return FALSE;}
[0-9]+			 	 {printf("returning %s\n", yytext); return(NUM);}
[a-zA-Z_]([a-zA-Z_]|[0-9])*	 {printf("returning %s\n", yytext); return ID;}
(\".*\")			 {return (STRING);}
#.*       			 ;
.       			 {return yytext[0];}

%%

int yywrap()
{
	return 1;
}