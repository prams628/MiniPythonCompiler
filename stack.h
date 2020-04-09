#include <stdio.h>
#include <stdlib.h>

int sp = 0, *stack, top;

int *init(int max)
{
	int *stack = (int*)malloc(sizeof(int) * max);
	return stack;
}

void push_to_stack(int *stack, int ele)
{
	stack[sp++] = ele;
}

int pop_from_stack(int *stack)
{
	top = stack[--sp];
	return top;
}

int peek(int *stack)
{
	return stack[sp];
}