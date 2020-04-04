%{
   #include<stdio.h>
   #include<stdlib.h>
   #include<string.h>
   #include<ctype.h>
   #include <stdarg.h>

   #define INT 1
   #define STR 2
   #define BINARY 10
   #define NUMBER 11
   #define RELOP 12
   #define IDENTIFIER 13
   #define STIRNG 14
   #define NONE 20
 
   struct sym_table_entry
	{
		// type stores if the variable is a function or an identifier. since we aren't handling functions, it's always 
		// "identifier"
		char name[100], type[15], sValue[100];
		int iValue, lineno;
		int scope, index, dt;
	};
	struct sym_table_entry symbol_table[100];

	typedef struct ASTNode
	{
		int noOfChildren, type;
		struct ASTNode **children;
		char *token;
	} node;

	node *mknode(char *token, int type, int noOfChildren, ...)
	{
		int i;
		node *newnode = (node *)malloc(sizeof(node));
		char *newstr = (char *)malloc(strlen(token)+1);
		newnode -> noOfChildren = noOfChildren;
		strcpy(newstr, token);
		va_list params;
		newnode -> children = (node**)malloc(sizeof(node*) * noOfChildren);
		va_start(params, noOfChildren);
		for(i = 0; i < noOfChildren; i++)
		{
			newnode -> children[i] = va_arg(params, node*);
		}
		newnode->token = newstr;
		va_end(params);
		newnode -> type = type;
		return(newnode); 
	}

	void printtree(node *tree)
	{
		
		printf("token: %s\n", tree -> token);
		for(int i = 0; i < tree -> noOfChildren; i++)
		{
			printtree(tree -> children[i]);
		}
	}

	int count = 0, i, temp_variable_count = 0, temp_integer, variable_found = 0, int_or_str;
	char temp_string[100];
	extern int yylineno;

	void printICG(node *tree)
	{
		if(tree)
		{	
			printf("Current tree token: %s\n", tree -> token);
			if(strcmp("node", tree -> token) == 0)
			{
				node *current_tree = tree -> children[0];
				printICG(current_tree -> children[1]);
				printf("%s = T%d\n", current_tree -> children[0] -> token, temp_variable_count++);
				printICG(tree -> children[1]);
			}
			if(tree -> type == NUMBER || tree -> type == IDENTIFIER)
			{
				printf("T%d = %s\n", temp_variable_count, tree -> token);
			}
			if(tree -> type == BINARY)
			{
				printf("T%d = %s %s %s\n", temp_variable_count, tree -> children[0] -> token, tree -> token, tree -> children[0] -> token);
			}
			if(strcmp("If", tree -> token) == 0)
			{
				printf("Detected if statement. Under production\n");
				exit(1);
			}
		}
	}

	// Some function definitions required
	void add_int(struct sym_table_entry[], char[], int, int);
	void add_str(struct sym_table_entry[], char[], char[], int);
	void display(struct sym_table_entry[]);
	void search_update_int(struct sym_table_entry[], char[], int, int);
	void search_update_str(struct sym_table_entry[], char[], char[], int);
%}
 
%token FOR WHILE
%token IF IN RANGE ELSE PRINT COLON 
%token NUM ID ASS
%token TAB OCB CCB NEWLINE INDENT DD ND
%token TRUE COMMA FALSE STRING
%token ADDITION SUBTRACT MULTIPLY DIVIDE NOT

%union 	{
	int iVal, depth;
	char *txt;
	struct ASTNode *NODE;
}

%type <txt> ID STRING
%type <iVal> NUM
%type <NODE> id Assignment1 T E if_stmt main_start suite start_suite end_suite while_stmt for_stmt RangeElements condition bool_exp bool_factor bool_term start PrintFunc
 
%right '='
%left AND OR
%left LE GE EQ NE LT GT
%left ADDITION SUBTRACT
%left MULTIPLY DIVIDE
 
%%

main_start: start  {
			printf("\n------------------AST---------------------\n");
			printtree($1); 
			printf("\n------------------ICG---------------------\n");
			printICG($1);
		} 

start: Assignment1 start { if($2 -> token == NULL) $$ = mknode("node", NONE, 1, $1); else $$ = mknode("node", NONE, 2, $1, $2); }
   | if_stmt {$$ = $1;}
   | while_stmt {$$ = $1;}
   | for_stmt {$$ = $1;}
   | PrintFunc {$$ = $1;}
   |
   ;

if_stmt: IF bool_exp COLON NEWLINE INDENT start_suite { $$ = mknode("If", NONE, 2, $2, $6); printf("\n"); }

start_suite: start suite { $$ = mknode("BeginBlock", NONE, 2, $1, $2); }

suite: ND start suite { $$ = mknode("Next", NONE, 2, $2, $3); }
	| end_suite { $$ = $1; };

end_suite: start { $$ = mknode("EndBlock", NONE, 0); }
	| DD start { $$ = mknode("EndBlock", NONE, 1, $2); }

while_stmt : WHILE bool_exp COLON NEWLINE INDENT start_suite {$$ = mknode("While", NONE, 2, $2, $6); printf("\n");}

for_stmt : FOR condition COLON NEWLINE INDENT start_suite {$$ = mknode("For", NONE, 2, $2, $6); printf("\n");}

RangeElements :	T {$$ = $1;}
   | T COMMA T {$$ = mknode(",", NONE, 2, $1, $3);}
   ;

condition : id IN RANGE OCB RangeElements CCB {$$ = mknode("Condition", NONE, 2, $1, $5);}

bool_exp : bool_term OR bool_term {$$ = mknode("Or", RELOP, 2, $1, $3);}
         | E LT E {$$ = mknode("<", RELOP, 2, $1, $3);}
         | bool_term AND bool_term {$$ = mknode("And", RELOP, 2, $1, $3);}
         | E GT E {$$ = mknode(">", RELOP, 2, $1, $3);}
	 	 | E EQ E {$$ = mknode("==", RELOP, 2, $1, $3);}
         | E LE E {$$ = mknode("<=", RELOP, 2, $1, $3);}
         | E GE E {$$ = mknode(">=", RELOP, 2, $1, $3);}
         | E IN id { $$ = mknode("In", RELOP, 2, $1);}
         | bool_term {$$=$1;}; 

bool_term : bool_factor {$$ = $1;}
          | TRUE {$$ = mknode("True", NONE, 0);}
          | FALSE {$$ = mknode("False", NONE, 0);}; 
          
bool_factor : NOT bool_factor {$$ = mknode("!", NONE, 1, $2);}
            | OCB bool_exp CCB {$$ = $2;}; 

Assignment1: id ASS E NEWLINE
							{
                            	if(int_or_str == 1)
								{
									$$ = mknode("=", NONE, 2, $1, $3);
									search_update_int(symbol_table, $1 -> token, atoi($3 -> token), INT);
								}
								else if(int_or_str == STR)
								{
									$$ = mknode("=", NONE, 2, $1, $3);
									search_update_str(symbol_table, $1 -> token, $3 -> token, STR);
								}
							}
	| error {yyerrok; yyclearin;}
    ;

id: ID { $$ = mknode((char*)yylval.txt, IDENTIFIER, 0); }
	;
 
E:  E ADDITION T 
	{
		$$ = mknode("+", BINARY, 2, $1, $3);
		int_or_str = INT;
	}

	| E SUBTRACT T 
	{
		$$ = mknode("-", BINARY, 2, $1, $3);
		int_or_str = INT;
	}

	| E MULTIPLY T 
	{
		$$ = mknode("*", BINARY, 2, $1, $3);
		int_or_str = INT;
	}

	| E DIVIDE T 
	{
		$$ = mknode("/", BINARY, 2, $1, $3);
		int_or_str = INT;
	}

	| T 
    {
		$$ = $1;
   	}
	;
  
T : NUM 
	{ 
		char *temp = (char*)malloc(sizeof(char) * 10);
		sprintf(temp, "%d", yylval.iVal); 
		$$ = mknode(temp, NUMBER, 0);
		int_or_str = INT;
	}

	| OCB E CCB {$$ = $2;}

	| STRING
	{
		char *temp = (char*)malloc(sizeof(char) * 50);
		sprintf(temp, "%s", yylval.txt); 
		$$ = mknode(temp, STIRNG, 0);	
		int_or_str = STR;
	}

	| ID {
		strcpy(temp_string, $1);
		variable_found = 0;
		for(i = 0; i < count; i++)
		{
			if(strcmp(symbol_table[i].name, temp_string) == 0)
			{
				node *temp_node;
				if(symbol_table[i].dt == INT)
				{
					char *temp = (char*)malloc(sizeof(char) * 10);
					sprintf(temp, "%d", symbol_table[i].iValue); 
					$$ = mknode(temp, IDENTIFIER, 0);
				}
				else
					$$ = mknode(symbol_table[i].sValue, IDENTIFIER, 0);
				variable_found = 1;
				break;
			}
		}
		if(!variable_found)
		{
			printf("Variable %s not defined. Stopping the execution\n", temp_string);
			exit(1);
		}
    }
	;

PrintFunc: PRINT OCB E CCB NEWLINE start { $$ = mknode("Print", NONE, 1, $3); }
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
				printf("Trying to assign string value to an integer. I give up\n");
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
				printf("Trying to assign integer value to a string. I give up\n");
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
	yyparse();
	printf("-----------------Symbol table-----------------\n");
	display(symbol_table);
   return 0;
}
 
int yyerror(char *s)
{
   printf("%s at line %d\n", s, yylineno);
   exit(1);
}
