#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include<ctype.h>
#define debug 1

typedef struct Quadruple
{
	char *op, *result, *arg1, *arg2;
	int active;
}quad;

int quadCount = 0;
quad *quadArray = NULL;

quad *quadInit(int max)
{
	quadArray = (quad*)malloc(sizeof(quad) * max);
	return quadArray;
}

void makeQuad(char *res, char *arg1, char *arg2, char *op)
{
	if(res)
	{
		quadArray[quadCount].result = (char*)malloc(sizeof(char) * (strlen(res) + 1));
		strcpy(quadArray[quadCount].result, res);
	}
	if(arg1)
	{
		quadArray[quadCount].arg1 = (char*)malloc(sizeof(char) * (strlen(arg1) + 1));
		strcpy(quadArray[quadCount].arg1, arg1);
	}
	if(arg2)
	{
		quadArray[quadCount].arg2 = (char*)malloc(sizeof(char) * (strlen(arg2) + 1));
		strcpy(quadArray[quadCount].arg2, arg2);
	}
	quadArray[quadCount].op = (char*)malloc(sizeof(char) * (strlen(op) + 1));
	strcpy(quadArray[quadCount].op, op);
	quadArray[quadCount].active = 1;
	quadCount++;
}

void printQuad()
{
	printf("--------------------------------QUADS-----------------------------------\n");
	printf("RESULT\t\tARG1\t\tOP\t\tARG2\n");
	int i;
	for(i = 0; i < quadCount; i++)
	{
		if(quadArray[i].active)
			printf("%s\t\t%s\t\t%s\t\t%s\n", quadArray[i].result, quadArray[i].arg1, quadArray[i].op, quadArray[i].arg2);
	}
}

void writeToFile()
{
	// Open the file to which the three address code should be written
	FILE *oFile = fopen("icg", "w");

	// A temp string which stores the current data that should be written to the file.
	char *temp = (char*)malloc(sizeof(char) * 100);

	// Write the code into a file titled 'icg'
	for(int i = 0; i < quadCount; i++)
	{
		if(quadArray[i].active)
		{
			sprintf(temp, "%s\t\t%s\t\t%s\t\t%s\n", quadArray[i].result, quadArray[i].arg1, quadArray[i].op, quadArray[i].arg2);
			fwrite(temp, strlen(temp), 1, oFile);
		}
	}

	// Close the file
	fclose(oFile);
}

int deadCodeElimination()
{
	int i, j, aliveCode, elim = 0;
	char *currVar = (char*)malloc(sizeof(char) * 30);		// currVar indicates the variable being checked for dead code
	for(i = 0; i < quadCount - 1; i++)
	{	
		aliveCode = 0;										// Assuming that the current line of code is not of use
		if(strcmp(quadArray[i].op, "print") == 0)
			aliveCode = 1;
		else
		{
			strcpy(currVar, quadArray[i].result);
			if(strcmp(quadArray[i].op, "Label") == 0 || strcmp(quadArray[i].op, "IfFalse") == 0 || strcmp(quadArray[i].op, "goto") == 0)
				aliveCode = 1;
			else
			{
				for(j = i + 1; j < quadCount; j++)
				{
					if(quadArray[j].active)
					{
						if(quadArray[j].arg1 && (strcmp(currVar, quadArray[j].arg1) == 0))
						{
							aliveCode = 1;							// As the current argument is used, the current code line should be alive
							break;
						}
						else if(quadArray[j].arg2 && strcmp(quadArray[j].arg2, currVar) == 0)
						{
							aliveCode = 1;
							break;
						}
					}
				}
			}
			if(!aliveCode && quadArray[i].active) elim++;
			quadArray[i].active = aliveCode;	
		}
	}
	if((strcmp(quadArray[quadCount - 1].op, "=") == 0) && (quadArray[quadCount - 1].active))
	{
		elim++;
		quadArray[quadCount - 1].active = 0;
	}
	if(debug)
	{
		printQuad();
		printf("\n\n");
	}
	free(currVar);
	return elim;
}
int check_temp(char*var) //check if given string is a valid temporary vaariable name
{
	if(!var)
		return 0;
    if(var[0]!='T')
    {
        return 0;
    }
    for(int i=1;i<strlen(var);i++)
    {
        if(isdigit(var[i])==0)
            return 0;
    }
    return 1;
}

int check_number(char*string)
{
    if(string==NULL)
    {
        return 0;
    }
    for(int i=0;i<strlen(string);i++)
    {
        if(isdigit(string[i])==0)
            return 0;
    }
    return 1;
}

int compute_result(quad q)
{
    //if it is simple assignment with no arithmetic operators
    if(strcmp(q.op,"=")==0)
    {
        int i1;
        sscanf(q.arg1, "%d", &i1);
        return i1; 
    }
   
    int i1,i2;
    
    sscanf(q.arg1, "%d", &i1);
    sscanf(q.arg2, "%d", &i2);

    if(q.op[0]=='+')
        return i1+i2;
    
    if(q.op[0]=='-')
        return i1-i2;
    
    if(q.op[0]=='*')
        return i1*i2;
    
    if(q.op[0]=='/')
    {
        if(i2==0)
        {
            printf("\nERROR DIV BY ZERO\n");
            return 213413534;
        }
        return i1/i2;
    }
}

void replace_value(int value,int i,char*name)
{
	for(int j=i+1;j<quadCount;j++)
    {
		//if temp value is recalced
		if(quadArray[j].result != NULL && strcmp(quadArray[j].result,name)==0)
            return;
        
	    //put in calc value in place of temp_var name if it is assigned to some variable
        if(quadArray[j].arg1!=NULL&&strcmp(quadArray[j].arg1,name)==0)
        {
            sprintf(quadArray[j].arg1, "%d", value); 
        }
	    //replace temp_var if it is being used as an arguement also
        if(quadArray[j].arg2!=NULL&&strcmp(quadArray[j].arg2,name)==0)
        {
            sprintf(quadArray[j].arg2, "%d", value); 
        }
    }
}

void code_folding()
{
    for(int i=0;i<quadCount;i++)
    {
		//if its temp variable getting assigned arithmetic expression or if it is directly assigned a number
        if(check_temp(quadArray[i].result)&&check_number(quadArray[i].arg1)&&(check_number(quadArray[i].arg2)||strcmp(quadArray[i].op,"=")==0))
        {
            //evaluate the arithmetic exp
            int val=compute_result(quadArray[i]);
            //replace any assigment of var=temp_var with var=val
            replace_value(val,i,quadArray[i].result);

            //remove this quad statement from quad array now that its done
            for(int j=i;j<quadCount-1;j++)
            {
                quadArray[j]=quadArray[j+1];
            }
            quadCount--;
            //since everything moved back, to be on the right statement
            i--;
            
        }
    }

}
