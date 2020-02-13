%{
   #include<stdio.h>
   #include<stdlib.h>
   #include<string.h>
   #include<ctype.h>

   #define TYPE "integer" 
 
   struct sym_table_entry
	{
		char name[100];
		int value;
		int scope, index;
      		char type[100];
	};
	struct sym_table_entry symbol_table[100];

	int count = 0, temp;
	char identifier[100], buffer[10];
	void add(struct sym_table_entry[], char[],int, char[]);
	void display(struct sym_table_entry[]);
	void search_update(struct sym_table_entry[], char[], int, char[]);
%}
 
%token FOR WHILE
%token IF IN RANGE ELSE PRINT COLON 
%token NUM ID 
%token TAB OCB CCB NEWLINE INDENT
%token TRUE COMMA FALSE STRING

%union 	{
	int iVal;
	char *txt;
}

%type <txt> ID
%type <iVal> NUM T
 
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

Assignment1: ID '=' E NEWLINE {
							   	search_update(symbol_table, $1, temp, TYPE);
							}
    ;
 
E:  T
      {
         temp = $1;
         printf("temp: %d\n", temp);
      }
	;
  
T :   T '+' T { $$ = $1 + $3; } 
	| T '-' T { $$ = $1 - $3; } 
	| T '*' T { $$ = $1 * $3; } 
	| T '/' T { $$ = $1 / $3; } 
	| '-' NUM { $$ = -$2; } 
	| '(' T ')' { $$ = $2; } 
	| NUM { $$ = $1; }
	; 
 
CompoundStatement: IfStatement
   | ForStatement
   | WhileStatement
   | IfElseStatement
   ;

IfStatement: IF condition COLON NEWLINE INDENT
   ;

ForStatement: FOR ID IN RANGE OCB RangeElements CCB COLON NEWLINE INDENT
   ;

IfElseStatement: IfStatement start ELSE COLON NEWLINE INDENT
   {
      printf("Expecting an ifelse\n");
   }
   ;

WhileStatement: WHILE OCB condition CCB COLON NEWLINE INDENT
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



void search_update(struct sym_table_entry table[],char name[], int value, char type[])
{
	int i;
	for(i = 0; i < count; i++)
	{
		if(strcmp(table[i].name, name) == 0)
		{
			table[i].value = value;
			return;
		}
	}
	add(table, name, value, type);
}

void add(struct sym_table_entry table[], char name[], int value, char type[])
{
	struct sym_table_entry temp;
	strcpy(temp.name,name);
	temp.value=value;
   strcpy(temp.type, TYPE);
	temp.scope = 1;
	temp.index = count;
	table[count] = temp;
	count++;
}

void display(struct sym_table_entry table[])
{
	int i;
	for(i = 0; i < count; i++)
		printf("%s %s %d\n", table[i].name, table[i].type, table[i].value);
}

int main(int argc, char *argv[])
{
   if(yyparse()==1)
       printf("Parsing failed\n");
      else
       printf("Parsing completed successfully\n");
	display(symbol_table);
   return 0;
}
 
int yyerror(char *s)
{
   printf("%s\n", s);
   return 1;
}
