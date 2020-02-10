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
%token TAB OCB CCB NEWLINE INDENT
%token TRUE COMMA FALSE STRING
 
%right '='
%left AND OR
%left LE GE EQ NE LT GT
%left '+' '-'
%left '*' '/'
 
%%
 
start: Assignment1 start
   | CompoundStatement start
   | INDENT Assignment1 start
   | INDENT CompoundStatement start
   | PrintFunc start
   | INDENT PrintFunc start
   |
   ;

Assignment1: ID '=' E NEWLINE {printf("An assignment expression\n");}
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
   | IfElseStatement
   ;

IfStatement: IF condition COLON NEWLINE INDENT
   ;

ForStatement: FOR ID IN RANGE OCB RangeElements CCB COLON NEWLINE INDENT
   ;

IfElseStatement: IF condition COLON NEWLINE INDENT start ELSE COLON NEWLINE INDENT
   ;

RangeElements:	Expr1
   | Expr1 COMMA Expr1
   | Expr1 COMMA Expr1 COMMA Expr1
   ;

condition: TRUE
   | FALSE
   | relationalExpression
   ;

relationalExpression: relationalExpression RelOp Expr1
   | Expr1
   ;

Expr1: ID
   | NUM
   ;

PrintFunc: PRINT OCB STRING CCB NEWLINE
   | PRINT OCB Expr1 CCB NEWLINE
   ;

RelOp: LE 
   | GE 
   | EQ 
   | NE 
   | LT 
   | GT
   | AND
   | OR
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