# Project Title
A very basic compiler for python developed using lex and yacc. All the phases of compiler design have been covered and this compiler can parse basic statements, selection and looping constructs. 


## Prerequisites

Install flex and bison using the following command which can help interpret .l and .y files.

```
sudo apt-get update
sudo apt-get install flex
sudo apt-get install bison
```

## Running the code

To parse a program using the mini-compiler, run the following commands in order in the folder of the project.

```
./compile.sh
```
This command will build an executable from the lex and yacc files. To run the executable, enter

```
./exec.sh filepath
```
This command will print all the outputs right from lexer parsing to assembly code generated for the file passed through filepath. 