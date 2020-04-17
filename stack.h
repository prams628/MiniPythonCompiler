#include <stdio.h>
#include <stdlib.h>

typedef struct Stack
{
	int looping_construct, next_counter;
}stack;
int sp = 0, top;

stack *init(int max)
{
	stack *STACK = (stack*)malloc(sizeof(stack) * max);
	return STACK;
}

void push_to_stack(stack *STACK, int ele, int next_counter)
{
	STACK[sp].looping_construct = ele;
	STACK[sp++].next_counter = next_counter;
}

int pop_from_stack(stack *STACK)
{
	top = --sp;
	return top;
}

int peek(stack *STACK)
{
	printf("Peek function of the stack called. top = %d; loop = %d; next = %d\n", sp - 1, STACK[sp - 1].looping_construct, STACK[sp - 1].next_counter);
}