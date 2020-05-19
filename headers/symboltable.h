#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define d 0

extern int yylineno, int_or_str;
int count = 0;

typedef struct sym_table_entry
{
    // type stores if the variable is a function or an identifier. since we aren't handling functions, it's always 
    // "identifier"
    char name[100], type[15], value[100];
    int lineno;
    int scope, index, dt;
	struct sym_table_entry *next;

}symTab;

symTab *initSym(int max)
{
    return NULL;
}

void display(symTab *table)
{
	int i;
	symTab *temp = table;
	for(i = 0; i < count; i++)
	{
		printf("%s\t%s\t%s\t%d\n", temp -> name, temp -> value, temp -> type, temp -> dt);
		temp = temp -> next;
	}
}

int search_update_var(symTab *table,char name[])
{
	symTab *temp = table;
	int i;
	for(i = 0; i < count; i++)
	{
		if(d)
			printf("DEBUG: The current variable is %s\n", temp -> name);
		if(temp -> name && strcmp(temp -> name, name) == 0)
		{
			if(d)
				printf("DEBUG: Returning %d\n", i);
			return i;
		}
		temp = temp -> next;
	}
	if(d)
		printf("DEBUG: Variable not found. Returning -1\n");
	return -1;
}

symTab *add_var(symTab *table, char name[], char value[], int type)
{
	int retVal = search_update_var(table, name);
	if(d)
		printf("DEBUG: The head of the linked list before allocation: %s\n", table -> name);
	if(retVal == -1)
	{
		if(d)
			printf("DEBUG: Allocating values to the new block in the symtable\n");
		symTab *temp = (symTab*)malloc(sizeof(symTab));
		strcpy(temp -> name,name);
		strcpy(temp -> value, value);
		temp -> dt = type;
		temp -> scope = 1;
		temp -> lineno = yylineno - 1;
		strcpy(temp -> type, "identifier");
		temp -> index = count;
		temp -> next = table;
		if(d)
			printf("DEBUG: table -> name: %s\n", table -> name);
		table = temp;
		count++;
		if(d)
		{
			printf("DEBUG: Printing the intermediate symbol table\n");
			display(table);
		}
	}
	else
	{
		strcpy(table[retVal].value, value);
		table[retVal].dt = int_or_str;
	}
	return table;
}

void writeST(symTab *table)
{
	// Open the file to which the three address code should be written
	FILE *oFile = fopen("st", "w");

	// A temp string which stores the current data that should be written to the file.
	char *temp_str = (char*)malloc(sizeof(char) * 100);

	symTab *temp = table;

	// Write the code into a file titled 'icg'
	for(int i = 0; i < count; i++)
	{
		sprintf(temp_str, "%s\t%d\n", temp -> name, temp -> dt);
		fwrite(temp_str, strlen(temp_str), 1, oFile);
		temp = temp -> next;
	}

	// Close the file
	fclose(oFile);
}