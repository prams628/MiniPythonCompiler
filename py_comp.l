%{
	#include "y.tab.h"
	void recover();
%}

%%

[\t]+				 {printf("T_INDENT "); return (INDENT);}
[ ]  				 {}
[\n]				 {printf("\n"); yylineno++; return (NEWLINE);}
if    				 {printf("T_IF "); return(IF);}
else  				 {printf("T_ELSE "); return(ELSE);}
for   			 	 {printf("T_FOR "); return (FOR);}
while 				 {printf("T_WHILE "); return(WHILE);}
in    				 {printf("T_IN "); return(IN);}
print				 {printf("T_PRINT "); return(PRINT);}
range				 {printf("T_RANGE "); return (RANGE);}
"+"					 { printf("T_PL "); return(ADDITION); }
"-"					 { printf("T_MI "); return(SUBTRACT); }
"*"					 { printf("T_MU "); return(MULTIPLY); }
"/"					 { printf("T_DI "); return(DIVIDE); }
","					 {printf("T_COMMA "); return (COMMA);}
":"					 {printf("T_COLON "); return(COLON);}
"("					 {printf("T_OCB "); return (OCB);}
")"					 {printf("T_CCB "); return (CCB);}
"=="    			 {printf("T_EQ "); return(EQ);}
"<="    			 {printf("T_LE "); return(LE);}
"!="    			 {printf("T_NE "); return(NE);}
">"				 	 {printf("T_GT "); return(GT);}
">="    			 {printf("T_GE "); return(GE);}
"<"     			 {printf("T_LT "); return(LT);}
"="					 { printf("T_ASS "); return(ASS);}
True				 {printf("T_TRUE "); return TRUE;}
False				 {printf("T_FALSE "); return FALSE;}
[0-9]+			 	 {
						printf("T_DIGIT ");
						yylval.iVal = atoi(yytext);
						return(NUM);
					 }
[a-zA-Z_]([a-zA-Z_]|[0-9])*	 {
								printf("T_ID ");
								yylval.txt = strdup(yytext);
								return ID;
							}
\".*\"						{ 
				  				yylval.txt = strdup(yytext);
								printf("T_STRING ");
								return (STRING);
							}
#.*\n       		 {yylineno++;}
.       			 {return yytext[0];}
[0-9]([a-zA-Z_]|[0-9])*	 {printf("Error occured at line %d.\nVariable name can't start with a digit. \n", yylineno);
						
						 }

%%

int yywrap()
{
	return 1;
}