#include <string.h>
#include <stdlib.h>
#define STACK_SIZE 100

typedef union values{
        int ival;
        double dval;
        char cval;
        float fval;
        char sval[100];
        short int sival;
        long int lival;
}VALUES;
typedef struct node
{
    char token[50];
    char token_name[32];
    int line_number;
    int first_column;
    int last_column;
    char datatype[10];
    char scope_number[100];
    struct node *next;
    VALUES value;
    char c_dtype[32]; 
    int useful_flag;
} node;

typedef struct AST_NODE{
    char name[100];
    struct AST_NODE *child[100];
    int max_children;
    int num_children;
}AST_NODE;

typedef struct symbol_table
{
    node *first;
    node *last;
} symbol_table;

struct quad{
    char operator_val[10];
    char op1[32];
    char op2[32];
    char res[50];
}QUAD[100];


typedef struct LABEL_ARR{
    char L1[50];
    char L2[50];
}LABEL_ARR;



/*typedef struct stack_node
{
    char token_name[52];
    long int scope_number;
} stack_node;

typedef struct stack
{
    stack_node n[100];
    int top;
} stack;*/

void initialize_table(symbol_table *t);

//Called whenever a variable is declared. Return 0 on failure and 1 on success
node* insert_table(symbol_table *t,char *token,int flag_dtype,char *token_name,char *d_type,VALUES);
void free_table(symbol_table *t);
void display_table(symbol_table *t);
//Called whenever one enters into a new scope
void enter_scope();
//Called whenever one exits a new scope
void exit_scope();
//Called whenever a variable is accessed
node* variable_access(symbol_table *t,char *);

//returns an integer value which represents the closest scope to the given scope
int diff_scope(char *entry_scope, char *given_scope);
void add_quadruple(char *operator,char *op1,char *op2,char *res);
void display_quadruple();
//generates temporary variables in increasing order
char* gen_temp();
//generates new label in increasing order
char* new_label();
int set_dtype(char *type1,char *type2,char *d_type,char *op_val);
AST_NODE* create_ast_node(char *op);
void insert_child_ast_node(AST_NODE *parent,AST_NODE *child);
void display_AST(AST_NODE *root);

//Computes the value of a variable stored in symbol table given a pointer to its entry
//Stores result in second argument
void get_value(node *temp,VALUES *);

int hash_scope(char *current_level);
void dead_code_elimination();
struct quad OPTIMIZED_QUAD[100];


/*
void initialize_stack(stack *stk);
void insert_stack(stack *stk, char *varable_name);
void remove_stack(stack *stk);
void search_stack(stack *stk, char *token_name);*/

