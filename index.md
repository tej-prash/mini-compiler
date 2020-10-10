## Front-end Compiler Implementation

### Introduction
The mini-compiler is a C-based implementation of the front-end of a Java Compiler. 

### Description
When provided Java source code as input, Lexical analysis is performed using Lex, which produces tokens. The tokens are parsed using the specified Context Free Grammar(CFG) and it is semantically represented using an Abstract Syntax Tree(AST) using Yet Another Compiler Compiler(YACC). Parsing is performed in a bottom-up manner using Look-Ahead Left-Right(LALR) parsing. The semantic phase also generates Intermediate Code in the form of Three-Address Code. 

The compiler supports the following constructs:
- While Loop
- If-Else with single and multiple statements 
- Declaration and Definition statements
- Operations 
  - Arithmetic
  - Logical
  - Boolean

Primitive Java Data types that are supported include:
- Int
- Float
- Double
- String
- Boolean
- Short int
- Char
- Byte



#### Design
The symbol table is used by various phases of the compiler in order to store identifiers, data types along with their respective values. It is implemented using linked lists and new entries are added by creating nodes and attaching it to the previous nodes. Scope of the variables is handled using a string based hierarchical numbering methodology. For example, consider the statements:
```
int a=10;
while(a<50){
	if(a%2){
		System.out.println(“Done”)
	}
	a+=1;
}
```
The first statement is assigned a scope of 0_1. The statements inside the while loop are assigned a scope of 0_1_1 and the statements inside the if construct are assigned a scope of 0_1_1_1.  The algorithm for traversing the symbol table, described below, has an upper bound of O(mn) where m represents the length of the string containing the current scope number and n represents the length of the symbol table: 
1. The symbol table is traversed in O(n) time in order to locate the variables with the same name
2. For each such variable, its scope number stored in the symbol table is compared against the current scope. The difference in the scope numbering is determined, which yields the proximity of the variable’s scope with the current scope
3. The variable with the closest proximity to the variable accessed is determined using the longest prefix matching algorithm
4. The scope of the variable is written in the format a_b_c. Here a,b,c represent numbers and _ represents the nested scope.

During the semantic phase, Abstract Syntax Tree(AST) is used in obtain a graphical representation of the code. AST is implemented using n-ary trees as the underlying data structure. Each node of the tree falls into one of the following categories:
- Node with two children: An arithmetic operation, for example, would contain an operator as the root node and operands as the children. Moreover, condition specific operations consist of keywords as the root, condition as the left child and suite as the right child.
- Node with more than two children: In order to represent block statements, a node called “Block” is created every time a new scope is entered and its children consist of multiple statements within the particular block. 

The output of the compiler represents Intermediate Code as Quadruple-based Three-Address Code. Every instruction consists of an operator, along with at most two operands and a result. 
1. Arithmetic and boolean expressions are represented in the following format
    - operator	operand1 	operand2 	result
2. Assignment expression is represented as 
    - operator 	operand1			result
3. Labels are represented as
    - Label						Label name
4. Goto statements are
    - Goto						Label name
5. If-Else statements are represented as ifFalse statements to reduce the number of Go-to statements. 


### Results

#### Sample Input

```
public class Test{
    	public static void main(String []args){
            	int a=2;
            	int c=4;
            	int b=a+c;
            	while(a<=b){
                    	int a=3;
                    	int c=2*a+3-b;
                    	if(a<=b){
                            	int c=4+5;
                    	}
                    	else{
                            	int d=10;
                    	}

            	}
    	}
}
```

#### Sample Output

The Intermediate Quadruple Three-Address Code generated is as follows:

![ICG - mini compiler](https://user-images.githubusercontent.com/31772714/95655404-ad59be00-0b24-11eb-81ef-f3f6e65fbfcf.png)
