%{
	#include "y.tab.h"
	extern int yylineno;
	extern char *yytext;
	extern FILE *yyin;
%}

%%

[ \t]   			 {printf("Returning space or tab\n");}
[\n]				 { yylineno = yylineno + 1;}
if    				 {printf("Returning IF\n"); return(IF);}
else  				 {return(ELSE);}
for   			 	 {printf("returning for\n"); return (FOR);}
while 				 {return(WHILE);}
in    				 {printf("Returning IN\n"); return(IN);}
print				 {return(PRINT);}
range				 {return (RANGE);}
","					 {return (COMMA);}
":"					 {return(COLON);}
"("					 {return (OCB);}
")"					 {return (CCB);}
"=="    			 {return(EQ);}
"<="    			 {return(LE);}
"!="    			 {return(NE);}
">"				 	 {return(GT);}
">="    			 {return(GE);}
"<"     			 {return(LT);}
True				 {return TRUE;}
[0-9]+			 	 {printf("returning %s\n", yytext); return(NUM);}
[a-zA-Z_]([a-zA-Z_]|[0-9])*	 {printf("returning %s\n", yytext); return ID;}
#.*       			 ;
.       			 {return yytext[0];}

%%

int yywrap()
{
	return 1;
}