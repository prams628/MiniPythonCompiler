%{
   #include<stdio.h>
   #include<stdlib.h>
   #include<string.h>
   #include<ctype.h>

   #define INT 1
   #define STR 2
 
   struct sym_table_entry
	{
		// type stores if the variable is a function or an identifier. since we aren't handling functions, it's always 
		// "identifier"
		char name[100], type[15], sValue[100];
		int iValue, lineno;
		int scope, index, dt;
	};
	struct sym_table_entry symbol_table[100];

	int count = 0, temp_int, i, random_variable, variable_found = 0, int_or_str;
	char temp_string[100];
	extern int yylineno;

	// Some function definitions required
	void add_int(struct sym_table_entry[], char[], int, int);
	void add_str(struct sym_table_entry[], char[], char[], int);
	void display(struct sym_table_entry[]);
	void search_update_int(struct sym_table_entry[], char[], int, int);
	void search_update_str(struct sym_table_entry[], char[], char[], int);
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

%type <txt> ID STRING
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
                           if(int_or_str == 1)
							   	search_update_int(symbol_table, $1, temp_int, INT);
                           else
                            	search_update_str(symbol_table, $1, temp_string, STR);
							}
	| error {yyerrok; yyclearin;}
    ;
 
E:  T 
   {
         temp_int = $1;
         int_or_str = INT;
   }
   | STRING 
   {
      strcpy(temp_string, $1);
      int_or_str = STR;
   }
	;
  
T :   T '+' T { $$ = $1 + $3; } 
	| T '-' T { $$ = $1 - $3; } 
	| T '*' T { $$ = $1 * $3; } 
	| T '/' T { $$ = $1 / $3; } 
	| '-' NUM { $$ = -$2; } 
	| OCB T CCB { $$ = $2; } 
	| NUM { $$ = $1; }
    | ID {
		strcpy(temp_string, $1);
		variable_found = 0;
		for(i = 0; i < count; i++)
		{
			if(strcmp(symbol_table[i].name, temp_string) == 0)
			{
				random_variable = symbol_table[i].iValue;
				variable_found = 1;
				break;
			}
		}
		if(!variable_found)
		{
			printf("Variable %s not defined. Stopping the execution\n", temp_string);
			exit(1);
		}
		else
			$$ = random_variable;
    }
	; 
 
CompoundStatement: IfStatement
   | ForStatement
   | WhileStatement
   ;

IfStatement: IF condition COLON NEWLINE INDENT
   ;

ForStatement: FOR ID IN RANGE OCB RangeElements CCB COLON NEWLINE INDENT
   ;

WhileStatement: WHILE condition COLON NEWLINE INDENT
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



void search_update_int(struct sym_table_entry table[],char name[], int value, int type)
{
	int i;
	for(i = 0; i < count; i++)
	{
		if(strcmp(table[i].name, name) == 0)
		{
			if(table[i].dt == INT)
			{
				return;
			}
			else
			{
				printf("Variable of string type\n");
				exit(1);
			}
		}
	}
	add_int(table, name, value, type);
}

// This function will check if the string is already present in the symbol table
void search_update_str(struct sym_table_entry table[],char name[], char value[], int type)
{
	int i;
	for(i = 0; i < count; i++)
	{
		if(strcmp(table[i].name, name) == 0)
		{
			if(table[i].dt == STR)
			{
				return;
			}
			else
			{
				printf("Variable of integer type\n");
				exit(1);
			}
		}
	}
	add_str(table, name, value, type);
}

void add_int(struct sym_table_entry table[], char name[], int value, int type)
{
	struct sym_table_entry temp;
	strcpy(temp.name,name);
	temp.iValue = value;
	temp.dt = type;
	strcpy(temp.type, "identifier");
	temp.scope = 1;
	temp.index = count;
	temp.lineno = yylineno - 1;
	table[count] = temp;
	count++;
}

void add_str(struct sym_table_entry table[], char name[], char value[], int type)
{
	struct sym_table_entry temp;
	strcpy(temp.name,name);
	strcpy(temp.sValue, value);
	temp.dt = type;
	temp.scope = 1;
	temp.lineno = yylineno - 1;
	strcpy(temp.type, "identifier");
	temp.index = count;
	table[count] = temp;
	count++;
}

void display(struct sym_table_entry table[])
{
	int i;
	for(i = 0; i < count; i++)
	{
		if(table[i].dt == INT)
			printf("%s INT %d %s %d\n", table[i].name, table[i].iValue, table[i].type, table[i].lineno);
		else
			printf("%s STR %s %s %d\n", table[i].name, table[i].sValue, table[i].type, table[i].lineno);
	}
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
