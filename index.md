## Front-end Compiler Implementation

### Overview
The mini-compiler is a C-based implementation of the front-end of a Java Compiler. The compiler performs lexical analysis, syntactical and semantic parsing of Java source code and generates a Three Address Code representation. 

### Description
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
