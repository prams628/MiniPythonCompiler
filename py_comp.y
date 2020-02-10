%{
   #include<stdio.h>
   #include<stdlib.h>
   #include<string.h>
   #include<ctype.h>
 
   extern FILE *fp;
 
%}
 
%token FOR WHILE
%token IF IN RANGE ELSE PRINT COLON 
%token NUM ID 
%token TAB OCB CCB
%token TRUE COMMA
 
%right '='
%left AND OR
%left '<' '>' LE GE EQ NE LT GT
%left '+' '-'
%left '*' '/'
 
%%
 
start: Assignment1 start
   | CompoundStatement start
   |
   ;

Assignment1: ID '=' E {printf("An assignment expression\n");}
  ;
 
E: T	
	;
  
T:   T '+' T 
	| T '-' T 
	| T '*' T 
	| T '/' T 
	| '-' NUM 
	| '-' ID 
	| '(' T ')' 
	| NUM 
	| ID 
   |
   ;
 
CompoundStatement: IfStatement
   | ForStatement
   ;

IfStatement: IF condition COLON
   ;

ForStatement: FOR ID IN RANGE OCB RangeElements CCB COLON
   ;

RangeElements: T
   | T COMMA T
   | T COMMA T COMMA T
   ;

condition: TRUE
   ;
%%

int main(int argc, char *argv[])
{
   if(yyparse()==1)
       printf("Parsing failed\n");
      else
       printf("Parsing completed successfully\n");
   return 0;
}
 
int yyerror(char *s)
{
   printf("%s\n", s);
   return 1;
}