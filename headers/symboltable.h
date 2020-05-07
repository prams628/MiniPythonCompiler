#include <stdio.h>
#include <string.h>
#include <stdlib.h>

extern int yylineno, int_or_str;
int count = 0;

struct sym_table_entry
{
    // type stores if the variable is a function or an identifier. since we aren't handling functions, it's always 
    // "identifier"
    char name[100], type[15], value[100];
    int lineno;
    int scope, index, dt;
};

struct sym_table_entry *initSym(int max)
{
    struct sym_table_entry *table = (struct sym_table_entry *)malloc(sizeof(struct sym_table_entry) * max);
    return table;
}

int search_update_var(struct sym_table_entry table[],char name[])
{
	int i;
	for(i = 0; i < count; i++)
	{
		if(strcmp(table[i].name, name) == 0)
			return i;
	}
	return -1;
}

void add_var(struct sym_table_entry table[], char name[], char value[], int type)
{
	int retVal = search_update_var(table, name);
	if(retVal == -1)
	{
		struct sym_table_entry temp;
		strcpy(temp.name,name);
		strcpy(temp.value, value);
		temp.dt = type;
		temp.scope = 1;
		temp.lineno = yylineno - 1;
		strcpy(temp.type, "identifier");
		temp.index = count;
		table[count] = temp;
		count++;
	}
	else
	{
		strcpy(table[retVal].value, value);
		table[retVal].dt = int_or_str;
	}
}

void display(struct sym_table_entry table[])
{
	int i;
	for(i = 0; i < count; i++)
	{
		printf("%s\t%s\t%s\t%d\n", table[i].name, table[i].value, table[i].type, table[i].dt);
	}
}

void writeST(struct sym_table_entry table[])
{
	// Open the file to which the three address code should be written
	FILE *oFile = fopen("st", "w");

	// A temp string which stores the current data that should be written to the file.
	char *temp = (char*)malloc(sizeof(char) * 100);

	// Write the code into a file titled 'icg'
	for(int i = 0; i < count; i++)
	{
		sprintf(temp, "%s\t%s\n", table[i].name, table[i].value);
		fwrite(temp, strlen(temp), 1, oFile);
	}

	// Close the file
	fclose(oFile);
}