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

	typedef struct ASTNode
	{
		struct ASTNode *left;
		struct ASTNode *right;
		char *token;
	} node;

	node *mknode(node *left, node *right, char *token)
	{
		node *newnode = (node *)malloc(sizeof(node));
		char *newstr = (char *)malloc(strlen(token)+1);
		strcpy(newstr, token);
		newnode->left = left;
		newnode->right = right;
		newnode->token = newstr;
		return(newnode); 
	}

	void printtree(node *tree)
	{
		if (tree->left || tree->right)
			printf("(");
		printf(" %s ", tree->token);
		if (tree->left)
			printtree(tree->left);
		if (tree->right)
			printtree(tree->right);
		if (tree->left || tree->right)
			printf(")");
	}

	int count = 0, i, temp_integer, variable_found = 0, int_or_str;
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
%token NUM ID ASS
%token TAB OCB CCB NEWLINE INDENT
%token TRUE COMMA FALSE STRING
%token ADDITION SUBTRACT MULTIPLY DIVIDE NOT

%union 	{
	int iVal;
	char *txt;
	struct ASTNode *NODE;
}

%type <txt> ID STRING
%type <iVal> NUM
%type <NODE> id Assignment1 T E if_stmt while_stmt for_stmt RangeElements condition bool_exp bool_factor bool_term start PrintFunc
 
%right '='
%left AND OR
%left LE GE EQ NE LT GT
%left ADDITION SUBTRACT
%left MULTIPLY DIVIDE
 
%%
 
start: Assignment1 start
   | INDENT Assignment1 start
   | if_stmt {$$ = $1;}
   | while_stmt {$$ = $1;}
   | for_stmt {$$ = $1;}
   | PrintFunc {$$ = $1;}
   |
   ;

if_stmt : IF bool_exp COLON NEWLINE INDENT start { $$ = mknode($2, $6, "If"); printtree($$); printf("\n"); }

while_stmt : WHILE bool_exp COLON NEWLINE INDENT start {$$ = mknode($2, $6, "While"); printtree($$); printf("\n");}

for_stmt : FOR condition COLON NEWLINE INDENT start {$$ = mknode($2, $6, "For"); printtree($$); printf("\n");}

RangeElements :	T {$$ = $1;}
   | T COMMA T {$$ = mknode($1, $3, ",");}
   ;

condition : id IN RANGE OCB RangeElements CCB {$$ = mknode($1, $5, "Condition");}

bool_exp : bool_term OR bool_term {$$ = mknode($1, $3, "Or");}
         | E LT E {$$ = mknode($1, $3, "<");}
         | bool_term AND bool_term {$$ = mknode($1, $3, "And");}
         | E GT E {$$ = mknode($1, $3, ">");}
	 	 | E EQ E {$$ = mknode($1, $3, "==");}
         | E LE E {$$ = mknode($1, $3, "<=");}
         | E GE E {$$ = mknode($1, $3, ">=");}
         | E IN id { $$ = mknode(2, $1, "In");}
         | bool_term {$$=$1;}; 

bool_term : bool_factor {$$ = $1;}
          | TRUE {$$ = mknode(0, 0, "True");}
          | FALSE {$$ = mknode(0, 0, "False");}; 
          
bool_factor : NOT bool_factor {$$ = mknode($2, 0, "!");}
            | OCB bool_exp CCB {$$ = $2;}; 

Assignment1: id ASS E NEWLINE 
							{
                            	if(int_or_str == 1)
								{
									$$ = mknode($1, $3, "=");
									search_update_int(symbol_table, $1 -> token, atoi($3 -> token), INT);
									printtree($$);
									printf("\n");
								}
								else if(int_or_str == STR)
								{
									$$ = mknode($1, $3, "=");
									search_update_str(symbol_table, $1 -> token, $3 -> token, STR);
									printtree($$);
									printf("\n");
								}
							}
	| error {yyerrok; yyclearin;}
    ;

id: ID { $$ = mknode(0, 0, (char*)yylval.txt); }
	;
 
E:  E ADDITION T 
	{
		$$ = mknode($1, $3, "+");
		int_or_str = INT;
	}

	| E SUBTRACT T 
	{
		$$ = mknode($1, $3, "-");
		int_or_str = INT;
	}

	| E MULTIPLY T 
	{
		$$ = mknode($1, $3, "*");
		int_or_str = INT;
	}

	| E DIVIDE T 
	{
		$$ = mknode($1, $3, "/");
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
		$$ = mknode(0, 0, temp);
		int_or_str = INT;
	}

	| OCB E CCB {$$ = $2;}

	| STRING
	{
		char *temp = (char*)malloc(sizeof(char) * 50);
		sprintf(temp, "%s", yylval.txt); 
		$$ = mknode(0, 0, temp);	
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
					$$ = mknode(0, 0, temp);
				}
				else
					$$ = mknode(0, 0, symbol_table[i].sValue);
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

PrintFunc: PRINT OCB E CCB NEWLINE start { $$ = mknode($3, 0, "Print"); printtree($$); printf("\n"); }
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
   if(yyparse()==1)
       printf("Parsing failed\n");
      else
       printf("Parsing completed successfully\n");
	printf("-----------------Symbol table-----------------\n");
	display(symbol_table);
   return 0;
}
 
int yyerror(char *s)
{
   printf("%s at line %d\n", s, yylineno);
   return 1;
}
