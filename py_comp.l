%{
	#include "y.tab.h"
	void recover();
	int depth = 0, curr_depth;
%}

%%

[\t]*	{
			curr_depth = strlen(yytext);
			if(curr_depth > depth)
			{
				printf("T_INDENT ");
				depth = curr_depth;
				return INDENT;
			}
			else if(curr_depth < depth)
			{
				printf("T_DEDENT ");
				depth = curr_depth;
				return DD;
			}
			else if(curr_depth == depth)
			{
				printf("T_ND ");
				return ND;
			}
		}
[ ]  				 {}
[\n]				 { curr_depth = 0; printf("\n"); yylineno++; return (NEWLINE);}
if    				 { if(depth >= 1 && curr_depth == 0){ depth--; yyless(0); return DD; } printf("T_IF "); return(IF);}
else  				 { if(depth >= 1 && curr_depth == 0){ depth--; yyless(0); return DD; } printf("T_ELSE "); return(ELSE);}
for   			 	 { if(depth >= 1 && curr_depth == 0){ depth--; yyless(0); return DD; } printf("T_FOR "); return (FOR);}
while 				 { if(depth >= 1 && curr_depth == 0){ depth--; yyless(0); return DD; } printf("T_WHILE "); return(WHILE);}
in    				 {printf("T_IN "); return(IN);}
print				 { if(depth >= 1 && curr_depth == 0){ depth--; yyless(0); return DD; } printf("T_PRINT "); return(PRINT);}
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
								if(depth >= 1 && curr_depth == 0){ depth--; yyless(0); return DD; }
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