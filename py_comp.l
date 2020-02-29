%{
	#include "y.tab.h"
	void recover();
%}

%%

[\t]+				 {printf("T_INDENT\n"); return (INDENT);}
[ ]  				 {}
[\n]				 {yylineno++; return (NEWLINE);}
if    				 {printf("T_IF\n"); return(IF);}
else  				 {printf("T_ELSE\n"); return(ELSE);}
for   			 	 {printf("T_FOR\n"); return (FOR);}
while 				 {printf("T_WHILE\n"); return(WHILE);}
in    				 {printf("T_IN\n"); return(IN);}
print				 {return(PRINT);}
range				 {printf("T_RANGE\n"); return (RANGE);}
","					 {printf("T_COMMA\n"); return (COMMA);}
":"					 {printf("T_COLON\n"); return(COLON);}
"("					 {printf("T_OCB\n"); return (OCB);}
")"					 {printf("T_CCB\n"); return (CCB);}
"=="    			 {printf("T_EQ\n"); return(EQ);}
"<="    			 {printf("T_LE\n"); return(LE);}
"!="    			 {printf("T_NE\n"); return(NE);}
">"				 	 {printf("T_GT\n"); return(GT);}
">="    			 {printf("T_GE\n"); return(GE);}
"<"     			 {printf("T_LT\n"); return(LT);}
True				 {printf("T_TRUE\n"); return TRUE;}
False				 {printf("T_FALSE\n"); return FALSE;}
[0-9]+			 	 {
						printf("T_DIGIT\n");
						yylval.iVal = atoi(yytext);
						return(NUM);
					 }
[a-zA-Z_]([a-zA-Z_]|[0-9])*	 {
								printf("T_ID\n");
								yylval.txt = strdup(yytext);
								return ID;
							}
\".*\"						{ 
				  				yylval.txt = strdup(yytext);
								printf("T_STRING\n");
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