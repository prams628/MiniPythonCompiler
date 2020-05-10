%{
   #include<string.h>
   #include <ctype.h>
   #include <stdarg.h>
   #include "headers/stack.h"
   #include "headers/codeop.h"
   #include "headers/symboltable.h"

   #define DEBUG 0
   #define INT 1
   #define STR 2
   #define for_loop 3
   #define while_loop 4
   #define if_statement 5
   #define BINARY 10
   #define NUMBER 11
   #define RELOP 12
   #define IDENTIFIER 13
   #define STIRNG 14
   #define TRUTH 15
   #define NONE 20
   #define MAXQUADS 500
 
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
		printf("( %s", tree -> token);
		for(int i = 0; i < tree -> noOfChildren; i++)
		{
			printtree(tree -> children[i]);
		}
		printf(" )");
	}

	int i, temp_variable_count = 0, temp_integer, variable_found = 0, int_or_str;
	char temp_string[100];
	extern int yylineno;
	int label_count_proposed = 0, label_count_actual = 0;
	int for_loop_counter = 0, c = 1;
	int while_loop_counter = 0;
	int next_counter = 0;
	stack *loop_stack = NULL;
	struct sym_table_entry *symbol_table = NULL;

	void pInit()
	{
		quadArray = quadInit(500);
		loop_stack = init(10);
		symbol_table = initSym(100);
	}

	char snum[10];
	char T[] = "T";

	void freeRes()
	{
		free(quadArray);
	}

	void printICG(node *tree)
	{
		if(tree)
		{	
			
			if(strcmp("node", tree -> token) == 0)
			{
				node *current_tree = (node*)malloc(sizeof(node));
				current_tree = tree -> children[0];
				printICG(current_tree -> children[1]);
				char *tempVarString = (char*)malloc(sizeof(char) * 4);
				sprintf(tempVarString, "T%d", temp_variable_count++);
				printf("%s = %s\n", current_tree -> children[0] -> token, tempVarString);
				makeQuad(current_tree -> children[0] -> token, tempVarString, NULL, "=");
				free(current_tree);
				free(tempVarString);
				printICG(tree -> children[1]);
			}

			if(tree -> type == NUMBER || tree -> type == IDENTIFIER || tree -> type == STIRNG)
			{
				char *tempVarString = (char*)malloc(sizeof(char) * 4);
				sprintf(tempVarString, "T%d", temp_variable_count);
				add_var(symbol_table, tempVarString, "0", INT);
				printf("%s = %s\n", tempVarString, tree -> token);
				makeQuad(tempVarString, tree -> token, NULL, "=");
				free(tempVarString);
			}

			if(tree -> type == BINARY)
			{
				printICG(tree -> children[0]);
				sprintf(snum, "T%d", temp_variable_count);
				temp_variable_count++;
				char *tempVarString = (char*)malloc(sizeof(char) * 4);
				sprintf(tempVarString, "T%d", temp_variable_count);
				add_var(symbol_table, tempVarString, "0", INT);
				printf("%s = %s %s %s\n", tempVarString, snum, tree -> token, tree -> children[1] -> token);
				makeQuad(tempVarString, snum, tree -> children[1] -> token, tree -> token);
				free(tempVarString);
			}

			if(strcmp("If", tree -> token) == 0)
			{
				push_to_stack(loop_stack, if_statement, 0);
				if(DEBUG)
					peek(loop_stack);

				// The left child gives the condition for the if statement to be triggered while the right child contains the block
				printICG(tree -> children[0]);

				// Creating a dynamic variable to store the count of temp variables in a string
				char *tempVarString = (char*)malloc(sizeof(char) * 4);
				sprintf(tempVarString, "T%d", temp_variable_count++);
				add_var(symbol_table, tempVarString, "0", INT);

				// Creating a dynamic variable to store the count of labels in a string
				char *tempLabString = (char*)malloc(sizeof(char) * 4);
				sprintf(tempLabString, "L%d", label_count_proposed++);
				printf("IfFalse %s goto %s:\n", tempVarString, tempLabString);
				
				// Add the above statement to the quad array
				makeQuad(tempLabString, tempVarString, NULL, "IfFalse");
				
				// Free the above created variables
				free(tempVarString);
				free(tempLabString);
				label_count_actual = label_count_proposed;
				
				// Move further down the AST by moving to the right child
				printICG(tree -> children[1]);
			}

			if(strcmp("While", tree -> token) == 0)
			{
				push_to_stack(loop_stack, while_loop, next_counter);
				if(DEBUG)
					peek(loop_stack);

				// Creating a dynamic variable to store the count of labels in a string
				char *tempLabString = (char*)malloc(sizeof(char) * 4);
				sprintf(tempLabString, "while%d", while_loop_counter++);
				printf("%s:\n", tempLabString);
				makeQuad(tempLabString, NULL, NULL, "Label");
				printICG(tree -> children[0]);
				// label_count_proposed++; (Commented the two lines because felt they are not needed here. If needed, uncomment it)
				
				// Creating a dynamic variable to store the count of temp variables in a string
				char *tempVarString = (char*)malloc(sizeof(char) * 4);
				sprintf(tempVarString, "T%d", temp_variable_count++);
				add_var(symbol_table, tempVarString, "0", INT);
				sprintf(tempLabString, "next%d", next_counter++);
				printf("IfFalse %s goto %s:\n", tempVarString, tempLabString);
				makeQuad(tempLabString, tempVarString, NULL, "IfFalse");

				// Free the above variables
				free(tempLabString);
				free(tempVarString);

				// label_count_actual = label_count_proposed;
				printICG(tree -> children[1]);
			}
			if(strcmp("For", tree -> token) == 0)
			{
				if(DEBUG)
					printf("The value of next_counter = %d\n", next_counter);
				push_to_stack(loop_stack, for_loop, next_counter);
				if(DEBUG)
					peek(loop_stack);

				node *condition = tree -> children[0];
				int start_index = -1, end_index, step_index = 1;

				if(condition -> children[1] -> noOfChildren == 1)
					{end_index = atoi(condition -> children[1] -> children[0] -> token);}
				
				else if(condition -> children[1] -> noOfChildren == 2)
				{
					start_index = atoi(condition -> children[1] -> children[0] -> token) - 1;
					end_index = atoi(condition -> children[1] -> children[1] -> token);
				}
				else
				{
					start_index = atoi(condition -> children[1] -> children[0] -> token) - 1;
					end_index = atoi(condition -> children[1] -> children[1] -> token);
					step_index = atoi(condition -> children[1] -> children[2] -> token);
				}

				// Creating a dynamic string
				char *tempLabString = (char*)malloc(sizeof(char) * 4);
				char *tempVarString = (char*)malloc(sizeof(char) * 4);

				printf("%s = %d\n", condition -> children[0] -> token, start_index);	
				sprintf(tempLabString, "%d", start_index);
				makeQuad(condition -> children[0] -> token, tempLabString, NULL, "=");

				// Create a label quad here
				sprintf(tempLabString, "for%d", for_loop_counter);
				makeQuad(tempLabString, NULL, NULL, "Label");
				printf("for%d:\n", for_loop_counter++);

				sprintf(tempVarString, "T%d", temp_variable_count++);
				add_var(symbol_table, tempVarString, "0", INT);
				printf("%s = %s + %d\n", tempVarString, condition -> children[0] -> token, step_index);
				printf("%s = %s\n",condition -> children[0] -> token, tempVarString);
				// Add the above statements to the quad
				sprintf(tempLabString, "%d", step_index);
				makeQuad(tempVarString, condition -> children[0] -> token, tempLabString, "+");
				makeQuad(condition -> children[0] -> token, tempVarString, NULL, "=");
				
				printf("IfFalse %s < %d goto next%d:\n", condition -> children[0] -> token, end_index, next_counter);
				sprintf(tempVarString, "T%d", temp_variable_count++);
				add_var(symbol_table, tempVarString, "0", INT);
				sprintf(tempLabString, "%d", end_index);	// using tempLabString to store arg2 here (to avoid creating another variable)
				makeQuad(tempVarString, condition -> children[0] -> token, tempLabString, "<");
				sprintf(tempLabString, "next%d", next_counter++);
				makeQuad(tempLabString, tempVarString, NULL, "IfFalse");

				label_count_actual++;
				free(tempLabString);
				free(tempVarString);

				printICG(tree -> children[1]);
			}
			if(tree -> type == TRUTH)
			{
				char *tempVarString = (char*)malloc(sizeof(char) * 4);

				sprintf(tempVarString, "T%d", temp_variable_count);
				printf("%s = %s\n", tempVarString, tree -> token);
				makeQuad(tempVarString, tree -> token, NULL, "=");

				free(tempVarString);
			}
			if(tree -> type == RELOP)
			{
				char *tempVarString = (char*)malloc(sizeof(char) * 4);

				sprintf(tempVarString, "T%d", temp_variable_count);
				printf("%s = %s %s %s\n", tempVarString, tree -> children[0] -> token, tree -> token, tree -> children[1] -> token);
				makeQuad(tempVarString, tree -> children[0] -> token, tree -> children[1] -> token,  tree -> token);
			
				free(tempVarString);
			}
			if(strcmp(tree -> token, "BeginBlock") == 0 || strcmp(tree -> token, "Next") == 0)
			{
				printICG(tree -> children[0]);
				printICG(tree -> children[1]);
			}
			if(strcmp(tree -> token, "EndBlock") == 0)
			{
				char *tempLabString = (char*)malloc(sizeof(char) * 4);
				int temp = pop_from_stack(loop_stack);
				if(DEBUG)
					printf("value of temp in EndBlock: %d\n", loop_stack[temp].next_counter);
				int top = loop_stack[temp].looping_construct;
				if(top == for_loop)
				{
					sprintf(tempLabString, "for%d", --for_loop_counter);
					printf("goto %s\n", tempLabString);
					makeQuad(tempLabString, NULL, NULL, "goto");

					sprintf(tempLabString, "next%d", loop_stack[temp].next_counter);
					printf("%s:\n", tempLabString);
					makeQuad(tempLabString, NULL, NULL, "Label");
				}
				else if(top == while_loop)
				{
					sprintf(tempLabString, "while%d", --while_loop_counter);
					printf("goto %s\n", tempLabString);
					makeQuad(tempLabString, NULL, NULL, "goto");

					sprintf(tempLabString, "next%d", loop_stack[temp].next_counter);
					printf("%s:\n", tempLabString);
					makeQuad(tempLabString, NULL, NULL, "Label");
				}
				else if(top == if_statement)
				{
					sprintf(tempLabString, "L%d", --label_count_actual);
					printf("%s:\n", tempLabString);
					makeQuad(tempLabString, NULL, NULL, "Label");
				}
				free(tempLabString);

				printICG(tree -> children[0]);
			}
			if(strcmp(tree -> token, "Print") == 0)
			{
				printf("print %s\n", tree -> children[0] -> token);
				makeQuad(NULL, tree -> children[0] -> token, NULL, "print");

				printICG(tree -> children[1]);
			}
		}
	}
%}
 
%token FOR WHILE
%token IF IN RANGE ELSE PRINT COLON 
%token NUM ID ASS AND
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

main_start: {pInit();} start  {
			printf("\n------------------AST---------------------\n");
			printtree($2); 
			printf("\n\n------------------ICG---------------------\n");
			printICG($2);
			printf("\n");
			printQuad();
			printf("\n");
			while(c)
			{
				code_folding();
				c = deadCodeElimination();
			}
			printf("\n");
			printQuad();
			printf("\n");
			writeToFile();
			writeST(symbol_table);
			freeRes();
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

RangeElements :	T {$$ = mknode(",", NONE, 1, $1);;}
   | T COMMA T {$$ = mknode(",", NONE, 2, $1, $3);}
   | T COMMA T COMMA T { $$ = mknode(",", NONE, 3, $1, $3, $5); }
   ;

condition : id IN RANGE OCB RangeElements CCB {
		add_var(symbol_table, $1 -> token, "0", INT);
		$$ = mknode("Condition", NONE, 2, $1, $5);}

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
          | TRUE {$$ = mknode("True", TRUTH, 0);}
          | FALSE {$$ = mknode("False", TRUTH, 0);}; 
          
bool_factor : NOT bool_factor {$$ = mknode("!", NONE, 1, $2);}
            | OCB bool_exp CCB {$$ = $2;}; 

Assignment1: id ASS E NEWLINE	{
                            	if(int_or_str == 1)
								{
									$$ = mknode("=", NONE, 2, $1, $3);
									add_var(symbol_table, $1 -> token, "0", INT);
								}
								else if(int_or_str == STR)
								{
									$$ = mknode("=", NONE, 2, $1, $3);
									add_var(symbol_table, $1 -> token, $3 -> token, STR);
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
				$$ = mknode(symbol_table[i].name, IDENTIFIER, 0);
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

PrintFunc: PRINT OCB E CCB NEWLINE { $$ = mknode("Print", NONE, 1, $3); }
		|  PRINT OCB E CCB NEWLINE while_stmt { $$ = mknode("Print", NONE, 2, $3, $6); }
		|  PRINT OCB E CCB NEWLINE for_stmt { $$ = mknode("Print", NONE, 2, $3, $6); }
		|  PRINT OCB E CCB NEWLINE if_stmt{ $$ = mknode("Print", NONE, 2, $3, $6); }
		|  PRINT OCB E CCB NEWLINE Assignment1 { $$ = mknode("Print", NONE, 2, $3, $6); }
		|  PRINT OCB E CCB NEWLINE PrintFunc { $$ = mknode("Print", NONE, 2, $3, $6); }
		; 

%%

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
