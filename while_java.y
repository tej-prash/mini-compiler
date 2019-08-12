    %{
    #include <stdio.h>
    #include<math.h>



    //extern FILE *fptr;
    extern struct symbol_table;
    extern struct symbol_table *t;
    extern int flag_dtype;
    extern char d_type[10];
    extern char id_name[32];
    char d_type[10];
    int flag_dtype=0;
    char id_name[32];
    extern char current_level[100];
    extern int current_level_length;
    extern int previous_level;
    extern FILE *fptr;
    FILE *fptr;
    char current_level[100]={'0'};
    int current_level_length=1;
    int previous_level=0;

    //Used for label and temporary variable generation
    int temp_counter=0;
    char temp_buffer[50];
    char label_buffer[50];
    int label_counter=0;

    //represents the labels used in if and while loops
    //char L1[50];
    //char L2[50];

    //char L_ARR[100][10];


    int QUAD_INDEX=0;

    //symbol_table *t=NULL;
    #ifndef _HEADER_H
    #define _HEADER_H

    #include "while_java.h"

    #endif
    AST_NODE *scope_numbering[100];
    int ast_scope=0;
    LABEL_ARR label_arr[100];


    %}
    %token T_IMPORT T_DOT T_SEMICOLON T_ID T_ACCESS_SPECIFIER T_CLASS T_LEFT_FLOW_PARAN  T_RIGHT_FLOW_PARAN T_STATIC T_DTYPE T_MAIN T_LEFT_PARAN T_RIGHT_PARAN T_LEFT_BRACKET T_RIGHT_BRACKET T_NEWLINE T_WHILE T_LOR T_LAND T_XOR T_GREATER_EQUALTO T_LESS_EQUALTO T_GREATERTHAN T_LESSTHAN T_EQUALTO T_ADD_SHORT T_SUB_SHORT T_MUL_SHORT T_DIV_SHORT T_MOD_SHORT T_DOUBLE_EQUALTO T_NOT_EQUALTO T_BITAND T_BITOR T_BIT_LEFT_SHIFT T_BIT_RIGHT_SHIFT T_PLUS T_MINUS T_MUL T_DIV T_MOD T_INCREMENT T_DECREMENT T_CHARACTER T_COMMA T_DIGIT T_IF T_ELSE T_SQUOTE T_LNOT T_QUOTE T_TRUE T_FALSE T_VOID T_DECIMAL

    //%type <strval> T_ID stmt 
    %type<s1> H O C T_ID stmt T_DIGIT T_DECIMAL T_TRUE T_FALSE T_CHARACTER bool_exp
    %type<strval> string
    %type<strval> T_DTYPE

    //TO DO: Handle byte, String, long, short
    //TO DO: Handle type checking
    //TODO: Use inherited attributes for if and while 
    %union{
        struct{
        	int id_flag; /* Checks if identifier is found*/
        	char strval[100]; /*Stores the identifier */
        	/* Store values of identifiers*/
        	char ch;
          	double doubval;
          	int intval;
          	int boolval;
          	int byteval;

            char d_type[32];
            char next[50];    

            /*For AST*/
            AST_NODE *temp;

        }s1;
        //for boolean expressions
        int intval;
        double dbval;
        char chval;
        char strval[100];
        int boolval;
    };
    %locations

    %right T_EQUALTO T_ADD_SHORT T_SUB_SHORT T_MUL_SHORT T_DIV_SHORT T_MOD_SHORT
    %left T_LOR
    %left T_LAND
    %left T_BITOR
    %left T_XOR
    %left T_BITAND
    %left T_DOUBLE_EQUALTO T_NOT_EQUALTO
    %left T_LESSTHAN T_LESS_EQUALTO T_GREATERTHAN T_GREATER_EQUALTO
    %left T_BIT_LEFT_SHIFT T_BIT_RIGHT_SHIFT
    %left T_PLUS T_MINUS
    %left T_MUL T_DIV T_MOD
    %right T_INCREMENT T_DECREMENT T_LNOT
    %left T_LEFT_PARAN T_RIGHT_PARAN

    %%
    start:          preprocessor class_declaration {printf("Success\n");display_table(t);display_quadruple();dead_code_elimination();exit(0);}
                    ;
    preprocessor:      /*lambda */
                    | T_IMPORT header T_SEMICOLON
                    ;
    header:         T_ID T_DOT header
                    | T_ID
                    ;
    class_declaration:      T_ACCESS_SPECIFIER T_CLASS T_ID T_LEFT_FLOW_PARAN program T_RIGHT_FLOW_PARAN 
                    ;
    program:        T_ACCESS_SPECIFIER T_STATIC T_VOID T_MAIN T_LEFT_PARAN T_DTYPE T_LEFT_BRACKET T_RIGHT_BRACKET T_ID T_RIGHT_PARAN T_LEFT_FLOW_PARAN 
                    {
                        if(flag_dtype==1){
                                    printf("Flag dtype %d\n",flag_dtype);
                                    strcpy(id_name,$<s1.strval>9);
                                    printf("yylval.strval %s\n",id_name);
                                    VALUES new_val;
                                    strcpy(new_val.sval,"\0");
                                    node* f=insert_table(t,"T_ID",flag_dtype,id_name,d_type,new_val);       
                                    flag_dtype=0;
                        }
                        enter_scope();
                        
                    } 
                    stmt T_RIGHT_FLOW_PARAN {
                            display_AST(scope_numbering[0]);

                    exit_scope();}
                    /*| T_ACCESS_SPECIFIER T_STATIC T_DTYPE T_MAIN T_LEFT_PARAN T_DTYPE T_LEFT_BRACKET T_RIGHT_BRACKET T_ID T_RIGHT_PARAN T_LEFT_FLOW_PARAN  stmt  T_RIGHT_FLOW_PARAN */
                    /*| T_ACCESS_SPECIFIER T_STATIC T_DTYPE T_MAIN T_LEFT_PARAN T_DTYPE T_LEFT_BRACKET T_RIGHT_BRACKET T_ID T_RIGHT_PARAN T_LEFT_FLOW_PARAN  stmt  T_RIGHT_FLOW_PARAN*/
                    ;

    S:              T_WHILE 
                    {
                        int hash_index=hash_scope(current_level);
                        strcpy((label_arr[hash_index]).L1,new_label());
                        add_quadruple("Label",NULL,NULL,label_arr[hash_index].L1);
                        strcpy(label_arr[hash_index].L2,new_label());
                    }
                    T_LEFT_PARAN bool_exp 
                    {
                        int hash_index=hash_scope(current_level);
                        add_quadruple("ifFalse",$<s1.strval>4,NULL,label_arr[hash_index].L2);

                    }
                    T_RIGHT_PARAN T_LEFT_FLOW_PARAN 
                    {
                        enter_scope();
                    } 
                    stmt 
                    T_RIGHT_FLOW_PARAN 
                    {


                        AST_NODE *temp=create_ast_node("while");
                        AST_NODE *child1=$<s1.temp>4;
                        AST_NODE *child2=scope_numbering[ast_scope-1];
                        insert_child_ast_node(temp,child1);
                        insert_child_ast_node(temp,child2);
                        exit_scope();

                        int hash_index=hash_scope(current_level);
                        add_quadruple("goto",NULL,NULL,label_arr[hash_index].L1);

                        add_quadruple("Label",NULL,NULL,label_arr[hash_index].L2);

                        insert_child_ast_node(scope_numbering[ast_scope-1],temp);

                    }
                    
                    /*| T_WHILE T_LEFT_PARAN bool_exp T_RIGHT_PARAN T_LEFT_FLOW_PARAN {enter_scope();} 
                    stmt ST_RIGHT_FLOW_PARAN {exit_scope();}*/
                    ;
    bool_exp:       bool_exp T_LOR bool_exp
                    {
                                        AST_NODE *temp=create_ast_node("||");
                                        insert_child_ast_node(temp,$<s1.temp>1);
                                        insert_child_ast_node(temp,$<s1.temp>3);
                                        $<s1.temp>$=temp;
                                        if($<s1.id_flag>3==1 && $<s1.id_flag>1==1){
                                            //if C is variable->s1.id_flag
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy(id_name,$<s1.strval>1);
                                            node *t2=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;
                            
                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
                                            /* add temporary variable to symbol table*/
                                            strcpy(d_type,"boolean");
                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp(t1->datatype,t2->datatype)){
                                                yyerror("Semantic Error in |: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t1->datatype,"boolean"))){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->sival | new_val2->sival;
                                                }
                                                else{
                                                    yyerror("Semantic Error in |: Incompatible types");
                                                }
                                            }
                                            
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("||",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2); 
                            }
                            else if($<s1.id_flag>1==1 && $<s1.id_flag>3==0){
                                            strcpy(id_name,$<s1.strval>1);
                                            node *t2=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
                                            /* add temporary variable to symbol table*/
                                            strcpy(d_type,"boolean");
                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>3,t2->datatype)){
                                                yyerror("Semantic Error in |: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t2->datatype,"boolean"))){
                                                    new_val2->sival=$<s1.boolval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->sival | new_val2->sival;
                                                }
                                                else{
                                                    yyerror("Semantic Error in |: Incompatible types");
                                                }
                                            }
                                            
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("||",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else if($<s1.id_flag>1==0 && $<s1.id_flag>3==1){
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
                                            /* add temporary variable to symbol table*/
                                             strcpy(d_type,"boolean");

                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>1,t1->datatype)){
                                                yyerror("Semantic Error in |: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t1->datatype,"boolean"))){
                                                    new_val1->sival=$<s1.boolval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->sival | new_val2->sival;
                                                }
                                                else{
                                                    yyerror("Semantic Error in |: Incompatible types");
                                                }
                                            }
                                            
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("||",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else {
                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
                                            /* add temporary variable to symbol table*/
                                             strcpy(d_type,"boolean");

                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>1,$<s1.d_type>3)){
                                                yyerror("Semantic Error in |: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp($<s1.d_type>1,"boolean"))){
                                                    new_val1->sival=$<s1.boolval>1;
                                                    new_val2->sival=$<s1.boolval>3;
                                                    new_val.sival=new_val1->sival | new_val2->sival;
                                                }
                                                else{
                                                    yyerror("Semantic Error in |: Incompatible types");
                                                }
                                            }
                                            
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("||",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                            $<s1.id_flag>$=1;
                                        }  
                    }
                    | bool_exp T_LAND bool_exp
                    {
                                        AST_NODE *temp=create_ast_node("&&");
                                        insert_child_ast_node(temp,$<s1.temp>1);
                                        insert_child_ast_node(temp,$<s1.temp>3);
                                        $<s1.temp>$=temp;

                                                                if($<s1.id_flag>3==1 && $<s1.id_flag>1==1){
                                            //if C is variable->s1.id_flag
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy(id_name,$<s1.strval>1);
                                            node *t2=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;
                            
                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
                                            /* add temporary variable to symbol table*/
                                              strcpy(d_type,"boolean");

                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp(t1->datatype,t2->datatype)){
                                                yyerror("Semantic Error in &: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t1->datatype,"boolean"))){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->sival & new_val2->sival;
                                                }
                                                else{
                                                    yyerror("Semantic Error in &: Incompatible types");
                                                }
                                            }
                                            
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("&&",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2); 
                            }
                            else if($<s1.id_flag>1==1 && $<s1.id_flag>3==0){
                                            strcpy(id_name,$<s1.strval>1);
                                            node *t2=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
                                            /* add temporary variable to symbol table*/
                                             strcpy(d_type,"boolean");

                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>3,t2->datatype)){
                                                yyerror("Semantic Error in &: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t2->datatype,"boolean"))){
                                                    new_val2->sival=$<s1.boolval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->sival & new_val2->sival;
                                                }
                                                else{
                                                    yyerror("Semantic Error in &: Incompatible types");
                                                }
                                            }
                                            
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("&&",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else if($<s1.id_flag>1==0 && $<s1.id_flag>3==1){
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
                                            /* add temporary variable to symbol table*/
                                             strcpy(d_type,"boolean");

                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>1,t1->datatype)){
                                                yyerror("Semantic Error in &: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t1->datatype,"boolean"))){
                                                    new_val1->sival=$<s1.boolval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->sival & new_val2->sival;
                                                }
                                                else{
                                                    yyerror("Semantic Error in &: Incompatible types");
                                                }
                                            }
                                         
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("&&",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else {
                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
                                            /* add temporary variable to symbol table*/
                                              strcpy(d_type,"boolean");

                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>1,$<s1.d_type>3)){
                                                yyerror("Semantic Error in &: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp($<s1.d_type>1,"boolean"))){
                                                    new_val1->sival=$<s1.boolval>1;
                                                    new_val2->sival=$<s1.boolval>3;
                                                    new_val.sival=new_val1->sival & new_val2->sival;
                                                }
                                                else{
                                                    yyerror("Semantic Error in &: Incompatible types");
                                                }
                                            }
                                            
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("&&",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                            $<s1.id_flag>$=1;
                                        }  
                    }
                    | bool_exp T_DOUBLE_EQUALTO bool_exp
                    {
                                        AST_NODE *temp=create_ast_node("==");
                                        insert_child_ast_node(temp,$<s1.temp>1);
                                        insert_child_ast_node(temp,$<s1.temp>3);
                                        $<s1.temp>$=temp;

                                        if($<s1.id_flag>3==1 && $<s1.id_flag>1==1){
                                            //if C is variable->s1.id_flag
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy(id_name,$<s1.strval>1);
                                            node *t2=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
                                            /* add temporary variable to symbol table*/
                                            strcpy(d_type,"boolean");
                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp(t1->datatype,t2->datatype)){
                                                yyerror("Semantic Error in ==: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t1->datatype,"int"))){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->ival == new_val2->ival;
                                                }
                                                else if(!strcmp(t1->datatype,"short")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->sival == new_val2->sival;
                                                }
                                                else if(!strcmp(t1->datatype,"long")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->lival == new_val2->lival;

                                                }
                                                else if(!strcmp(t1->datatype,"byte")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->sival == new_val2->sival;
                                                }
                                                else if(!strcmp(t1->datatype,"float")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->fval == new_val2->fval;
                                                }
                                                else if(!strcmp(t1->datatype,"double")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->dval == new_val2->dval;
                                                }
                                                else if(!strcmp(t1->datatype,"char")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->cval == new_val2->cval;
                                                }
                                                else if(!strcmp(t1->datatype,"String")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    if(!strcmp(new_val1->sval,new_val2->sval))
                                                        new_val.sival=1;
                                                    else
                                                        new_val.sival=0;
                                                }
                                                else{
                                                    yyerror("Semantic Error in %: Incompatible types");
                                                }
                                            }
                                            
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("==",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else if($<s1.id_flag>1==1 && $<s1.id_flag>3==0){
                                            strcpy(id_name,$<s1.strval>1);
                                            node *t2=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
                                            /* add temporary variable to symbol table*/
                                            strcpy(d_type,"boolean");
                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>3,t2->datatype)){
                                                yyerror("Semantic Error in ==: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t2->datatype,"int"))){
                                                    new_val2->ival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->ival == new_val2->ival;
                                                }
                                                else if(!strcmp(t2->datatype,"short")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->sival == new_val2->sival;
                                                }
                                                else if(!strcmp(t2->datatype,"long")){
                                                    new_val2->lival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->lival == new_val2->lival;

                                                }
                                                else if(!strcmp(t2->datatype,"byte")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->sival == new_val2->sival;
                                                }
                                                else if(!strcmp(t2->datatype,"float")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->fval == new_val2->fval;
                                                }
                                                else if(!strcmp(t2->datatype,"double")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->dval == new_val2->dval;
                                                }
                                                else if(!strcmp(t2->datatype,"char")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->cval == new_val2->cval;
                                                }
                                                else if(!strcmp(t2->datatype,"String")){
                                                    strcpy(new_val2->sval,$<s1.strval>3);
                                                    get_value(t2,new_val1);
                                                    if(!strcmp(new_val1->sval,new_val2->sval))
                                                        new_val.sival=1;
                                                    else
                                                        new_val.sival=0;
                                                }
                                                else{
                                                    yyerror("Semantic Error in ==: Incompatible types");
                                                }
                                            }
                                           
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("==",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else if($<s1.id_flag>1==0 && $<s1.id_flag>3==1){
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
                                            /* add temporary variable to symbol table*/
                                            strcpy(d_type,"boolean");
                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>1,t1->datatype)){
                                                yyerror("Semantic Error in ==: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t1->datatype,"int"))){
                                                    new_val1->ival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->ival == new_val2->ival;
                                                }
                                                else if(!strcmp(t1->datatype,"short")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->sival == new_val2->sival;
                                                }
                                                else if(!strcmp(t1->datatype,"long")){
                                                    new_val1->lival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->lival == new_val2->lival;

                                                }
                                                else if(!strcmp(t1->datatype,"byte")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->sival == new_val2->sival;
                                                }
                                                else if(!strcmp(t1->datatype,"float")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->fval == new_val2->fval;
                                                }
                                                else if(!strcmp(t1->datatype,"double")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->dval == new_val2->dval;
                                                }
                                                else if(!strcmp(t1->datatype,"char")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->cval == new_val2->cval;
                                                }
                                                else if(!strcmp(t1->datatype,"String")){
                                                    strcpy(new_val1->sval,$<s1.strval>1);
                                                    get_value(t1,new_val2);
                                                    if(!strcmp(new_val1->sval,new_val2->sval))
                                                        new_val.sival=1;
                                                    else
                                                        new_val.sival=0;
                                                }
                                                else{
                                                    yyerror("Semantic Error in ==: Incompatible types");
                                                }
                                            }
                                           
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("==",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else {
                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
                                            /* add temporary variable to symbol table*/
                                            strcpy(d_type,"boolean");
                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>1,$<s1.d_type>3)){
                                                yyerror("Semantic Error in ==: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp($<s1.d_type>1,"int"))){
                                                    new_val1->ival=$<s1.intval>1;
                                                    new_val2->ival=$<s1.intval>3;
                                                    new_val.sival=new_val1->ival == new_val2->ival;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"short")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.sival=new_val1->sival == new_val2->sival;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"long")){
                                                    new_val1->lival=$<s1.intval>1;
                                                    new_val2->lival=$<s1.intval>3;
                                                    new_val.sival=new_val1->lival == new_val2->lival;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"byte")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.sival=new_val1->sival == new_val2->sival;

                                                }
                                                else if(!strcmp($<s1.d_type>1,"float")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.sival=new_val1->fval == new_val2->fval;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"double")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.sival=new_val1->dval == new_val2->dval;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"char")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.sival=new_val1->cval == new_val2->cval;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"String")){
                                                    strcpy(new_val1->sval,$<s1.strval>1);
                                                    strcpy(new_val2->sval,$<s1.strval>3);
                                                    if(!strcmp(new_val1->sval,new_val2->sval))
                                                        new_val.sival=1;
                                                    else
                                                        new_val.sival=0;
                                                }
                                                else{
                                                    yyerror("Semantic Error in ==: Incompatible types");
                                                }
                                            }
                                            
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("==",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                            $<s1.id_flag>$=1;
                                        }
                    }
                    | bool_exp T_NOT_EQUALTO bool_exp
                    {
                                        AST_NODE *temp=create_ast_node("!=");
                                        insert_child_ast_node(temp,$<s1.temp>1);
                                        insert_child_ast_node(temp,$<s1.temp>3);
                                        $<s1.temp>$=temp;

                        if($<s1.id_flag>3==1 && $<s1.id_flag>1==1){
                                            //if C is variable->s1.id_flag
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy(id_name,$<s1.strval>1);
                                            node *t2=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
                                            /* add temporary variable to symbol table*/
                                            strcpy(d_type,"boolean");
                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp(t1->datatype,t2->datatype)){
                                                yyerror("Semantic Error in !=: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t1->datatype,"int"))){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->ival!= new_val2->ival;
                                                }
                                                else if(!strcmp(t1->datatype,"short")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->sival!= new_val2->sival;
                                                }
                                                else if(!strcmp(t1->datatype,"long")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->lival!= new_val2->lival;

                                                }
                                                else if(!strcmp(t1->datatype,"byte")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->sival!= new_val2->sival;
                                                }
                                                else if(!strcmp(t1->datatype,"float")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->fval!= new_val2->fval;
                                                }
                                                else if(!strcmp(t1->datatype,"double")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->dval!= new_val2->dval;
                                                }
                                                else if(!strcmp(t1->datatype,"char")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->cval!= new_val2->cval;
                                                }
                                                else if(!strcmp(t1->datatype,"String")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    if(strcmp(new_val1->sval,new_val2->sval))
                                                        new_val.sival=1;
                                                    else
                                                        new_val.sival=0;
                                                }
                                                else{
                                                    yyerror("Semantic Error in!=: Incompatible types");
                                                }
                                            }
                                            
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("!=",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else if($<s1.id_flag>1==1 && $<s1.id_flag>3==0){
                                            strcpy(id_name,$<s1.strval>1);
                                            node *t2=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
                                            /* add temporary variable to symbol table*/
                                            strcpy(d_type,"boolean");
                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>3,t2->datatype)){
                                                yyerror("Semantic Error in !=: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t2->datatype,"int"))){
                                                    new_val2->ival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->ival != new_val2->ival;
                                                }
                                                else if(!strcmp(t2->datatype,"short")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->sival != new_val2->sival;
                                                }
                                                else if(!strcmp(t2->datatype,"long")){
                                                    new_val2->lival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->lival != new_val2->lival;

                                                }
                                                else if(!strcmp(t2->datatype,"byte")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->sival != new_val2->sival;
                                                }
                                                else if(!strcmp(t2->datatype,"float")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->fval != new_val2->fval;
                                                }
                                                else if(!strcmp(t2->datatype,"double")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->dval != new_val2->dval;
                                                }
                                                else if(!strcmp(t2->datatype,"char")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->cval != new_val2->cval;
                                                }
                                                else if(strcmp(t2->datatype,"String")){
                                                    strcpy(new_val2->sval,$<s1.strval>3);
                                                    get_value(t2,new_val1);
                                                    if(strcmp(new_val1->sval,new_val2->sval))
                                                        new_val.sival=1;
                                                    else
                                                        new_val.sival=0;
                                                }
                                                else{
                                                    yyerror("Semantic Error in !=: Incompatible types");
                                                }
                                            }
                                            
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("!=",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else if($<s1.id_flag>1==0 && $<s1.id_flag>3==1){
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
                                            /* add temporary variable to symbol table*/
                                            strcpy(d_type,"boolean");
                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>1,t1->datatype)){
                                                yyerror("Semantic Error in !=: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t1->datatype,"int"))){
                                                    new_val1->ival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->ival != new_val2->ival;
                                                }
                                                else if(!strcmp(t1->datatype,"short")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->sival != new_val2->sival;
                                                }
                                                else if(!strcmp(t1->datatype,"long")){
                                                    new_val1->lival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->lival != new_val2->lival;

                                                }
                                                else if(!strcmp(t1->datatype,"byte")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->sival != new_val2->sival;
                                                }
                                                else if(!strcmp(t1->datatype,"float")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->fval != new_val2->fval;
                                                }
                                                else if(!strcmp(t1->datatype,"double")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->dval != new_val2->dval;
                                                }
                                                else if(!strcmp(t1->datatype,"char")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->cval != new_val2->cval;
                                                }
                                                else if(!strcmp(t1->datatype,"String")){
                                                    strcpy(new_val1->sval,$<s1.strval>1);
                                                    get_value(t1,new_val2);
                                                    if(strcmp(new_val1->sval,new_val2->sval))
                                                        new_val.sival=1;
                                                    else
                                                        new_val.sival=0;
                                                }
                                                else{
                                                    yyerror("Semantic Error in !=: Incompatible types");
                                                }
                                            }
                                            
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("!=",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else {
                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
                                            /* add temporary variable to symbol table*/
                                            strcpy(d_type,"boolean");
                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>1,$<s1.d_type>3)){
                                                yyerror("Semantic Error in !=: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp($<s1.d_type>1,"int"))){
                                                    new_val1->ival=$<s1.intval>1;
                                                    new_val2->ival=$<s1.intval>3;
                                                    new_val.sival=new_val1->ival != new_val2->ival;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"short")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.sival=new_val1->sival != new_val2->sival;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"long")){
                                                    new_val1->lival=$<s1.intval>1;
                                                    new_val2->lival=$<s1.intval>3;
                                                    new_val.sival=new_val1->lival != new_val2->lival;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"byte")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.sival=new_val1->sival != new_val2->sival;

                                                }
                                                else if(!strcmp($<s1.d_type>1,"float")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.sival=new_val1->fval != new_val2->fval;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"double")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.sival=new_val1->dval != new_val2->dval;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"char")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.sival=new_val1->cval != new_val2->cval;
                                                }
                                                else if(strcmp($<s1.d_type>1,"String")){
                                                    strcpy(new_val1->sval,$<s1.strval>1);
                                                    strcpy(new_val2->sval,$<s1.strval>3);
                                                    if(strcmp(new_val1->sval,new_val2->sval))
                                                        new_val.sival=1;
                                                    else
                                                        new_val.sival=0;
                                                }
                                                else{
                                                    yyerror("Semantic Error in !=: Incompatible types");
                                                }
                                            }
                                            
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("!=",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                            $<s1.id_flag>$=1;
                                        }
                    }
                    | bool_exp T_GREATER_EQUALTO bool_exp
                    {
                                        AST_NODE *temp=create_ast_node(">=");
                                        insert_child_ast_node(temp,$<s1.temp>1);
                                        insert_child_ast_node(temp,$<s1.temp>3);
                                        $<s1.temp>$=temp;

                            if($<s1.id_flag>3==1 && $<s1.id_flag>1==1){
                                            //if C is variable->s1.id_flag
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy(id_name,$<s1.strval>1);
                                            node *t2=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
                                            /* add temporary variable to symbol table*/
                                            strcpy(d_type,"boolean");
                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp(t1->datatype,t2->datatype)){
                                                yyerror("Semantic Error in >=: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t1->datatype,"int"))){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->ival>= new_val2->ival;
                                                }
                                                else if(!strcmp(t1->datatype,"short")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->sival>= new_val2->sival;
                                                }
                                                else if(!strcmp(t1->datatype,"long")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->lival>= new_val2->lival;

                                                }
                                                else if(!strcmp(t1->datatype,"byte")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->sival>= new_val2->sival;
                                                }
                                                else if(!strcmp(t1->datatype,"float")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->fval>= new_val2->fval;
                                                }
                                                else if(!strcmp(t1->datatype,"double")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->dval>= new_val2->dval;
                                                }
                                                else if(!strcmp(t1->datatype,"char")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->cval>= new_val2->cval;
                                                }
                                                
                                                else{
                                                    yyerror("Semantic Error in>=: Incompatible types");
                                                }
                                            }
                                            
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple(">=",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else if($<s1.id_flag>1==1 && $<s1.id_flag>3==0){
                                            strcpy(id_name,$<s1.strval>1);
                                            node *t2=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
                                            /* add temporary variable to symbol table*/
                                            strcpy(d_type,"boolean");
                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>3,t2->datatype)){
                                                yyerror("Semantic Error in >=: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t2->datatype,"int"))){
                                                    new_val2->ival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->ival >= new_val2->ival;
                                                }
                                                else if(!strcmp(t2->datatype,"short")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->sival >= new_val2->sival;
                                                }
                                                else if(!strcmp(t2->datatype,"long")){
                                                    new_val2->lival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->lival >= new_val2->lival;

                                                }
                                                else if(!strcmp(t2->datatype,"byte")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->sival >= new_val2->sival;
                                                }
                                                else if(!strcmp(t2->datatype,"float")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->fval >= new_val2->fval;
                                                }
                                                else if(!strcmp(t2->datatype,"double")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->dval >= new_val2->dval;
                                                }
                                                else if(!strcmp(t2->datatype,"char")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->cval >= new_val2->cval;
                                                }
                                               
                                                else{
                                                    yyerror("Semantic Error in >=: Incompatible types");
                                                }
                                            }
                                            
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple(">=",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else if($<s1.id_flag>1==0 && $<s1.id_flag>3==1){
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
                                            /* add temporary variable to symbol table*/
                                            strcpy(d_type,"boolean");
                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>1,t1->datatype)){
                                                yyerror("Semantic Error in >=: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t1->datatype,"int"))){
                                                    new_val1->ival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->ival >= new_val2->ival;
                                                }
                                                else if(!strcmp(t1->datatype,"short")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->sival >= new_val2->sival;
                                                }
                                                else if(!strcmp(t1->datatype,"long")){
                                                    new_val1->lival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->lival >= new_val2->lival;

                                                }
                                                else if(!strcmp(t1->datatype,"byte")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->sival >= new_val2->sival;
                                                }
                                                else if(!strcmp(t1->datatype,"float")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->fval >= new_val2->fval;
                                                }
                                                else if(!strcmp(t1->datatype,"double")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->dval >= new_val2->dval;
                                                }
                                                else if(!strcmp(t1->datatype,"char")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->cval >= new_val2->cval;
                                                }
                                                
                                                else{
                                                    yyerror("Semantic Error in >=: Incompatible types");
                                                }
                                            }
                                            
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple(">=",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else {
                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
                                            /* add temporary variable to symbol table*/
                                            strcpy(d_type,"boolean");
                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>1,$<s1.d_type>3)){
                                                yyerror("Semantic Error in >=: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp($<s1.d_type>1,"int"))){
                                                    new_val1->ival=$<s1.intval>1;
                                                    new_val2->ival=$<s1.intval>3;
                                                    new_val.sival=new_val1->ival >= new_val2->ival;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"short")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.sival=new_val1->sival >= new_val2->sival;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"long")){
                                                    new_val1->lival=$<s1.intval>1;
                                                    new_val2->lival=$<s1.intval>3;
                                                    new_val.sival=new_val1->lival >= new_val2->lival;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"byte")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.sival=new_val1->sival >= new_val2->sival;

                                                }
                                                else if(!strcmp($<s1.d_type>1,"float")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.sival=new_val1->fval >= new_val2->fval;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"double")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.sival=new_val1->dval >= new_val2->dval;
                                                }
                                                
                                                else{
                                                    yyerror("Semantic Error in >=: Incompatible types");
                                                }
                                            }
                                            
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple(">=",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                            $<s1.id_flag>$=1;
                                        }
                    }
                    | bool_exp T_LESS_EQUALTO bool_exp 
                    {
                                        AST_NODE *temp=create_ast_node("<=");
                                        insert_child_ast_node(temp,$<s1.temp>1);
                                        insert_child_ast_node(temp,$<s1.temp>3);
                                        $<s1.temp>$=temp;

                            if($<s1.id_flag>3==1 && $<s1.id_flag>1==1){
                                            //if C is variable->s1.id_flag
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy(id_name,$<s1.strval>1);
                                            node *t2=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
                                            /* add temporary variable to symbol table*/
                                            strcpy(d_type,"boolean");
                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp(t1->datatype,t2->datatype)){
                                                yyerror("Semantic Error in <=: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t1->datatype,"int"))){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->ival<= new_val2->ival;
                                                }
                                                else if(!strcmp(t1->datatype,"short")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->sival<= new_val2->sival;
                                                }
                                                else if(!strcmp(t1->datatype,"long")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->lival<= new_val2->lival;

                                                }
                                                else if(!strcmp(t1->datatype,"byte")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->sival<= new_val2->sival;
                                                }
                                                else if(!strcmp(t1->datatype,"float")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->fval<= new_val2->fval;
                                                }
                                                else if(!strcmp(t1->datatype,"double")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->dval<= new_val2->dval;
                                                }
                                                else if(!strcmp(t1->datatype,"char")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->cval<= new_val2->cval;
                                                }
                                                
                                                else{
                                                    yyerror("Semantic Error in<=: Incompatible types");
                                                }
                                            }
                                            
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("<=",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else if($<s1.id_flag>1==1 && $<s1.id_flag>3==0){
                                            strcpy(id_name,$<s1.strval>1);
                                            node *t2=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
                                            /* add temporary variable to symbol table*/
                                            strcpy(d_type,"boolean");
                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>3,t2->datatype)){
                                                yyerror("Semantic Error in <=: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t2->datatype,"int"))){
                                                    new_val2->ival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->ival <= new_val2->ival;
                                                }
                                                else if(!strcmp(t2->datatype,"short")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->sival <= new_val2->sival;
                                                }
                                                else if(!strcmp(t2->datatype,"long")){
                                                    new_val2->lival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->lival <= new_val2->lival;

                                                }
                                                else if(!strcmp(t2->datatype,"byte")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->sival <= new_val2->sival;
                                                }
                                                else if(!strcmp(t2->datatype,"float")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->fval <= new_val2->fval;
                                                }
                                                else if(!strcmp(t2->datatype,"double")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->dval <= new_val2->dval;
                                                }
                                                else if(!strcmp(t2->datatype,"char")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->cval <= new_val2->cval;
                                                }
                                               
                                                else{
                                                    yyerror("Semantic Error in <=: Incompatible types");
                                                }
                                            }
                                            
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("<=",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else if($<s1.id_flag>1==0 && $<s1.id_flag>3==1){
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
                                            /* add temporary variable to symbol table*/
                                            strcpy(d_type,"boolean");
                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>1,t1->datatype)){
                                                yyerror("Semantic Error in <=: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t1->datatype,"int"))){
                                                    new_val1->ival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->ival <= new_val2->ival;
                                                }
                                                else if(!strcmp(t1->datatype,"short")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->sival <= new_val2->sival;
                                                }
                                                else if(!strcmp(t1->datatype,"long")){
                                                    new_val1->lival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->lival <= new_val2->lival;

                                                }
                                                else if(!strcmp(t1->datatype,"byte")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->sival <= new_val2->sival;
                                                }
                                                else if(!strcmp(t1->datatype,"float")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->fval <= new_val2->fval;
                                                }
                                                else if(!strcmp(t1->datatype,"double")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->dval <= new_val2->dval;
                                                }
                                                else if(!strcmp(t1->datatype,"char")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->cval <= new_val2->cval;
                                                }
                                                
                                                else{
                                                    yyerror("Semantic Error in <=: Incompatible types");
                                                }
                                            }
                                            
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("<=",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else {
                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
                                            /* add temporary variable to symbol table*/
                                            strcpy(d_type,"boolean");
                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>1,$<s1.d_type>3)){
                                                yyerror("Semantic Error in <=: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp($<s1.d_type>1,"int"))){
                                                    new_val1->ival=$<s1.intval>1;
                                                    new_val2->ival=$<s1.intval>3;
                                                    new_val.sival=new_val1->ival <= new_val2->ival;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"short")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.sival=new_val1->sival <= new_val2->sival;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"long")){
                                                    new_val1->lival=$<s1.intval>1;
                                                    new_val2->lival=$<s1.intval>3;
                                                    new_val.sival=new_val1->lival <= new_val2->lival;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"byte")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.sival=new_val1->sival <= new_val2->sival;

                                                }
                                                else if(!strcmp($<s1.d_type>1,"float")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.sival=new_val1->fval <= new_val2->fval;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"double")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.sival=new_val1->dval <= new_val2->dval;
                                                }
                                                
                                                else{
                                                    yyerror("Semantic Error in <=: Incompatible types");
                                                }
                                            }
                                            
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("<=",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                            $<s1.id_flag>$=1;
                                        }
                    }
                    | bool_exp T_GREATERTHAN bool_exp
                    {
                                        AST_NODE *temp=create_ast_node(">");
                                        insert_child_ast_node(temp,$<s1.temp>1);
                                        insert_child_ast_node(temp,$<s1.temp>3);
                                        $<s1.temp>$=temp;

                        if($<s1.id_flag>3==1 && $<s1.id_flag>1==1){
                                            //if C is variable->s1.id_flag
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy(id_name,$<s1.strval>1);
                                            node *t2=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
                                            /* add temporary variable to symbol table*/
                                            strcpy(d_type,"boolean");
                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp(t1->datatype,t2->datatype)){
                                                yyerror("Semantic Error in >: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t1->datatype,"int"))){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->ival> new_val2->ival;
                                                }
                                                else if(!strcmp(t1->datatype,"short")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->sival> new_val2->sival;
                                                }
                                                else if(!strcmp(t1->datatype,"long")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->lival> new_val2->lival;

                                                }
                                                else if(!strcmp(t1->datatype,"byte")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->sival> new_val2->sival;
                                                }
                                                else if(!strcmp(t1->datatype,"float")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->fval> new_val2->fval;
                                                }
                                                else if(!strcmp(t1->datatype,"double")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->dval> new_val2->dval;
                                                }
                                                else if(!strcmp(t1->datatype,"char")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->cval> new_val2->cval;
                                                }
                                                
                                                else{
                                                    yyerror("Semantic Error in>: Incompatible types");
                                                }
                                            }
                                            
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple(">",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else if($<s1.id_flag>1==1 && $<s1.id_flag>3==0){
                                            strcpy(id_name,$<s1.strval>1);
                                            node *t2=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
                                            /* add temporary variable to symbol table*/
                                            strcpy(d_type,"boolean");
                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>3,t2->datatype)){
                                                yyerror("Semantic Error in >: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t2->datatype,"int"))){
                                                    new_val2->ival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->ival > new_val2->ival;
                                                }
                                                else if(!strcmp(t2->datatype,"short")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->sival > new_val2->sival;
                                                }
                                                else if(!strcmp(t2->datatype,"long")){
                                                    new_val2->lival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->lival > new_val2->lival;

                                                }
                                                else if(!strcmp(t2->datatype,"byte")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->sival > new_val2->sival;
                                                }
                                                else if(!strcmp(t2->datatype,"float")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->fval > new_val2->fval;
                                                }
                                                else if(!strcmp(t2->datatype,"double")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->dval > new_val2->dval;
                                                }
                                                else if(!strcmp(t2->datatype,"char")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->cval > new_val2->cval;
                                                }
                                               
                                                else{
                                                    yyerror("Semantic Error in >: Incompatible types");
                                                }
                                            }
                                            
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple(">",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else if($<s1.id_flag>1==0 && $<s1.id_flag>3==1){
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
                                            /* add temporary variable to symbol table*/
                                            strcpy(d_type,"boolean");
                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>1,t1->datatype)){
                                                yyerror("Semantic Error in >: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t1->datatype,"int"))){
                                                    new_val1->ival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->ival > new_val2->ival;
                                                }
                                                else if(!strcmp(t1->datatype,"short")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->sival > new_val2->sival;
                                                }
                                                else if(!strcmp(t1->datatype,"long")){
                                                    new_val1->lival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->lival > new_val2->lival;

                                                }
                                                else if(!strcmp(t1->datatype,"byte")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->sival > new_val2->sival;
                                                }
                                                else if(!strcmp(t1->datatype,"float")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->fval > new_val2->fval;
                                                }
                                                else if(!strcmp(t1->datatype,"double")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->dval > new_val2->dval;
                                                }
                                                else if(!strcmp(t1->datatype,"char")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->cval > new_val2->cval;
                                                }
                                                
                                                else{
                                                    yyerror("Semantic Error in >: Incompatible types");
                                                }
                                            }
                                            
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple(">",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else {
                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
                                            /* add temporary variable to symbol table*/
                                            strcpy(d_type,"boolean");
                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>1,$<s1.d_type>3)){
                                                yyerror("Semantic Error in >: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp($<s1.d_type>1,"int"))){
                                                    new_val1->ival=$<s1.intval>1;
                                                    new_val2->ival=$<s1.intval>3;
                                                    new_val.sival=new_val1->ival > new_val2->ival;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"short")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.sival=new_val1->sival > new_val2->sival;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"long")){
                                                    new_val1->lival=$<s1.intval>1;
                                                    new_val2->lival=$<s1.intval>3;
                                                    new_val.sival=new_val1->lival > new_val2->lival;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"byte")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.sival=new_val1->sival > new_val2->sival;

                                                }
                                                else if(!strcmp($<s1.d_type>1,"float")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.sival=new_val1->fval > new_val2->fval;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"double")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.sival=new_val1->dval > new_val2->dval;
                                                }
                                                
                                                else{
                                                    yyerror("Semantic Error in >: Incompatible types");
                                                }
                                            }
                                            
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple(">",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                            $<s1.id_flag>$=1;
                                        }
                    }
                    | bool_exp T_LESSTHAN bool_exp
                    {
                                        AST_NODE *temp=create_ast_node("<");
                                        insert_child_ast_node(temp,$<s1.temp>1);
                                        insert_child_ast_node(temp,$<s1.temp>3);
                                        $<s1.temp>$=temp;

                            if($<s1.id_flag>3==1 && $<s1.id_flag>1==1){
                                            //if C is variable->s1.id_flag
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy(id_name,$<s1.strval>1);
                                            node *t2=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
                                            /* add temporary variable to symbol table*/
                                            strcpy(d_type,"boolean");
                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp(t1->datatype,t2->datatype)){
                                                yyerror("Semantic Error in <: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t1->datatype,"int"))){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->ival< new_val2->ival;
                                                }
                                                else if(!strcmp(t1->datatype,"short")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->sival< new_val2->sival;
                                                }
                                                else if(!strcmp(t1->datatype,"long")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->lival< new_val2->lival;

                                                }
                                                else if(!strcmp(t1->datatype,"byte")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->sival< new_val2->sival;
                                                }
                                                else if(!strcmp(t1->datatype,"float")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->fval< new_val2->fval;
                                                }
                                                else if(!strcmp(t1->datatype,"double")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->dval< new_val2->dval;
                                                }
                                                else if(!strcmp(t1->datatype,"char")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->cval< new_val2->cval;
                                                }
                                                
                                                else{
                                                    yyerror("Semantic Error in<: Incompatible types");
                                                }
                                            }
                                            
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("<",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else if($<s1.id_flag>1==1 && $<s1.id_flag>3==0){
                                            strcpy(id_name,$<s1.strval>1);
                                            node *t2=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
                                            /* add temporary variable to symbol table*/
                                            strcpy(d_type,"boolean");
                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>3,t2->datatype)){
                                                yyerror("Semantic Error in <: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t2->datatype,"int"))){
                                                    new_val2->ival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->ival < new_val2->ival;
                                                }
                                                else if(!strcmp(t2->datatype,"short")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->sival < new_val2->sival;
                                                }
                                                else if(!strcmp(t2->datatype,"long")){
                                                    new_val2->lival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->lival < new_val2->lival;

                                                }
                                                else if(!strcmp(t2->datatype,"byte")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->sival < new_val2->sival;
                                                }
                                                else if(!strcmp(t2->datatype,"float")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->fval < new_val2->fval;
                                                }
                                                else if(!strcmp(t2->datatype,"double")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->dval < new_val2->dval;
                                                }
                                                else if(!strcmp(t2->datatype,"char")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->cval < new_val2->cval;
                                                }
                                               
                                                else{
                                                    yyerror("Semantic Error in <: Incompatible types");
                                                }
                                            }
                                            
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("<",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else if($<s1.id_flag>1==0 && $<s1.id_flag>3==1){
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
                                            /* add temporary variable to symbol table*/
                                            strcpy(d_type,"boolean");
                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>1,t1->datatype)){
                                                yyerror("Semantic Error in <: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t1->datatype,"int"))){
                                                    new_val1->ival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->ival < new_val2->ival;
                                                }
                                                else if(!strcmp(t1->datatype,"short")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->sival < new_val2->sival;
                                                }
                                                else if(!strcmp(t1->datatype,"long")){
                                                    new_val1->lival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->lival < new_val2->lival;

                                                }
                                                else if(!strcmp(t1->datatype,"byte")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->sival < new_val2->sival;
                                                }
                                                else if(!strcmp(t1->datatype,"float")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->fval < new_val2->fval;
                                                }
                                                else if(!strcmp(t1->datatype,"double")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->dval < new_val2->dval;
                                                }
                                                else if(!strcmp(t1->datatype,"char")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->cval < new_val2->cval;
                                                }
                                                
                                                else{
                                                    yyerror("Semantic Error in <: Incompatible types");
                                                }
                                            }
                                            
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("<",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else {
                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
                                            /* add temporary variable to symbol table*/
                                            strcpy(d_type,"boolean");
                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>1,$<s1.d_type>3)){
                                                yyerror("Semantic Error in <: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp($<s1.d_type>1,"int"))){
                                                    new_val1->ival=$<s1.intval>1;
                                                    new_val2->ival=$<s1.intval>3;
                                                    new_val.sival=new_val1->ival < new_val2->ival;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"short")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.sival=new_val1->sival < new_val2->sival;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"long")){
                                                    new_val1->lival=$<s1.intval>1;
                                                    new_val2->lival=$<s1.intval>3;
                                                    new_val.sival=new_val1->lival < new_val2->lival;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"byte")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.sival=new_val1->sival < new_val2->sival;

                                                }
                                                else if(!strcmp($<s1.d_type>1,"float")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.sival=new_val1->fval < new_val2->fval;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"double")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.sival=new_val1->dval < new_val2->dval;
                                                }
                                                
                                                else{
                                                    yyerror("Semantic Error in <: Incompatible types");
                                                }
                                            }
                                            
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("<",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                            $<s1.id_flag>$=1;
                                        }
                    }
                    | T_LEFT_PARAN bool_exp T_RIGHT_PARAN
                    | T_ID 
                    {
                        strcpy($<s1.strval>$,$<s1.strval>1);$<s1.id_flag>$=1;
                        $<s1.temp>$=create_ast_node($<s1.strval>1);

                    }
                    | T_DIGIT {
                    $<s1.intval>$=$<s1.intval>1;$<s1.id_flag>$=0;strcpy($<s1.d_type>$,"int");strcpy($<s1.strval>$,$<s1.strval>1);
                    $<s1.temp>$=create_ast_node($<s1.strval>1);
                    }
                    | T_CHARACTER {$<s1.id_flag>$=0;$<s1.ch>$=$<s1.ch>1;strcpy($<s1.d_type>$,"char");strcpy($<s1.strval>$,$<s1.strval>1);
                        $<s1.temp>$=create_ast_node($<s1.strval>1);

                    }
                    | string
                    | T_DECIMAL {$<s1.id_flag>$=0;$<s1.doubval>$=$<s1.doubval>1;strcpy($<s1.d_type>$,"float");strcpy($<s1.strval>$,$<s1.strval>1);
                        $<s1.temp>$=create_ast_node($<s1.strval>1);

                    }
                    | T_TRUE {$<s1.boolval>$=1;$<s1.id_flag>$=0;strcpy($<s1.d_type>$,"boolean");strcpy($<s1.strval>$,$<s1.strval>1);
                        $<s1.temp>$=create_ast_node($<s1.strval>1);
                    }
                    | T_FALSE {$<s1.boolval>$=0;$<s1.id_flag>$=0;strcpy($<s1.d_type>$,"boolean");strcpy($<s1.strval>$,$<s1.strval>1);
                        $<s1.temp>$=create_ast_node($<s1.strval>1);

                    }
                    ;

    /*bool_exp:       W
                                    ;
    W:              P
                    | W T_LOR P
                    ;
    P:              V
                    |P T_LAND V
                    ;*/
    /*O:              T_LEFT_PARAN W T_RIGHT_PARAN
                    | V
                    ;*/


    /*V:              V T_DOUBLE_EQUALTO U
                    | V T_NOT_EQUALTO U
                    | U
                    ;
    U:              H T_GREATER_EQUALTO H
                    | H T_LESS_EQUALTO H
                    | H T_GREATERTHAN H
                    | H T_LESSTHAN H
                    | T_LEFT_PARAN W T_RIGHT_PARAN
                    | T_ID
                    ; */
    /*Z:                            T_ID
                                    ;*/
    /*A:              T_ID
                    ;
    B:              T_ID
                    ;*/
    stmt:           /*lambda*/ 
                    | stmt C T_SEMICOLON {
                                            insert_child_ast_node(scope_numbering[ast_scope-1],$<s1.temp>2);
                    }
                    | stmt T_DTYPE T_ID T_EQUALTO C T_SEMICOLON  
                                            {
                                            AST_NODE *temp=create_ast_node("=");
                                            AST_NODE *left=create_ast_node($<s1.strval>3);
                                            insert_child_ast_node(temp,left);
                                            insert_child_ast_node(temp,$<s1.temp>5);
                                            insert_child_ast_node(scope_numbering[ast_scope-1],temp);


                                                //TODO:  Perform type checking before adding to symbol table
                                            	//add to symbol table
                                            	strcpy(d_type,$2);

                                                //if C is a constant/literal
                                                VALUES new_val;
                                                printf("$<s1.id_flag>5 %d\n",$<s1.id_flag>5);
                                                printf("$<s1.intval>5 %d\n",$<s1.intval>5);
                                                if($<s1.id_flag>5==0){
                                                    if(!strcmp($<s1.d_type>5,"int")){
                                                        if((!strcmp(d_type,"long"))){
                                                            new_val.lival=$<s1.intval>5;
                                                        }
                                                        else if(!strcmp(d_type,"short")){
                                                            new_val.sival=$<s1.intval>5;
                                                        }
                                                        else if(!strcmp(d_type,"int")){
                                                            new_val.ival=$<s1.intval>5;
                                                            printf("new_val.ival %d\n",new_val.ival);
                                                        }
                                                        else if(!strcmp(d_type,"byte")){
                                                            new_val.sival=$<s1.intval>5;
                                                        }
                                                        else{
                                                            yyerror("Incompatible assignment type\n");
                                                        }
                                                    }
                                                    if(!strcmp($<s1.d_type>5,"float")){
                                                        if((!strcmp(d_type,"float"))){
                                                            new_val.fval=$<s1.doubval>5;
                                                        }
                                                        else if(!strcmp(d_type,"double")){
                                                            new_val.dval=$<s1.doubval>5;
                                                        }
                                                        else{
                                                            yyerror("Incompatible assignment type\n");
                                                        }
                                                    }
                                                    if(!strcmp($<s1.d_type>5,"boolean")){
                                                        if((!strcmp(d_type,"boolean"))){
                                                            new_val.sival=$<s1.boolval>5;
                                                        }
                                                        else{
                                                            yyerror("Incompatible assignment type\n");
                                                        }
                                                    }
                                                    if(!strcmp($<s1.d_type>5,"char")){
                                                        if((!strcmp(d_type,"char"))){
                                                            new_val.cval=$<s1.ch>5;
                                                        }
                                                        else{
                                                            yyerror("Incompatible assignment type\n");
                                                        }
                                                    }
                                                }
    											node *f=insert_table(t,"T_ID",1,$<s1.strval>3,d_type,new_val);
                                                add_quadruple("=",$<s1.strval>5,NULL,$<s1.strval>3);

    											//add value to symbol table		
                                            }
                    | stmt T_DTYPE  T_LEFT_BRACKET T_RIGHT_BRACKET Q T_SEMICOLON /*array initialisation */ {if(flag_dtype==1){
                                    /*strcpy(id_name,$<s1.strval>3);
                                    printf("yylval.strval %s\n",id_name);
                                    int f=insert_table(t,"T_ID",flag_dtype,id_name);  */     
                                    flag_dtype=0;
                                    }
                            }
                    | stmt T_ID T_LEFT_PARAN parameter_list T_RIGHT_PARAN T_SEMICOLON
                    | stmt T_DTYPE T_ID T_SEMICOLON {

                                            AST_NODE *temp=create_ast_node($<s1.strval>3);
                                            insert_child_ast_node(scope_numbering[ast_scope-1],temp);

                                    printf("rule applied\n");
                                    if(flag_dtype==1){
                                        strcpy(id_name,$<s1.strval>3);
                                        printf("yylval.strval %s\n",id_name);
                                        VALUES new_val;
                                        if(!strcmp($<s1.strval>2,"String")){
                                            strcpy(new_val.sval,"hi\0");  
                                        }
                                        if((!strcmp($<s1.strval>2,"int"))){
                                            new_val.ival=0;
                                        }
                                        if(!strcmp($<s1.strval>2,"short")){
                                            new_val.sival=0;
                                        }
                                        if(!strcmp($<s1.strval>2,"long")){
                                            new_val.lival=0;
                                        }
                                        if(!strcmp($<s1.strval>2,"char")){
                                            new_val.cval='0';
                                        }
                                        if(!strcmp($<s1.strval>2,"float")){
                                            new_val.fval=0.0;
                                        }
                                        if(!strcmp($<s1.strval>2,"double")){
                                            new_val.dval=0.0;
                                        }
                                        if(!strcmp($<s1.strval>2,"boolean")){
                                            new_val.sival=0;
                                        }
                                        if(!strcmp($<s1.strval>2,"byte")){
                                            new_val.sival=0;
                                        }
                                        node *f=insert_table(t,"T_ID",flag_dtype,id_name,d_type,new_val);       
                                        flag_dtype=0;
                                    }
                            }
                    | stmt S {
                            insert_child_ast_node(scope_numbering[ast_scope-1],$<s1.temp>2);

                    }
                    | stmt S2 {
                        printf("rule applied\n");
                            insert_child_ast_node(scope_numbering[ast_scope-1],$<s1.temp>2);

                        }
                    | stmt T_DTYPE  T_LEFT_BRACKET T_RIGHT_BRACKET T_ID T_SEMICOLON
                    ;
    parameter_list: H
                    | parameter_list T_COMMA T_ID
                    ;
    /*S_Prime:        T_SEMICOLON stmt
                    ;*/
    /*B:              T_ID T_EQUALTO Z
                    ;*/
    /*TO DO: Handle type casting */
    C:              C T_EQUALTO C {
                                        AST_NODE *temp=create_ast_node("=");
                                        insert_child_ast_node(temp,$<s1.temp>1);
                                        insert_child_ast_node(temp,$<s1.temp>3);
                                        $<s1.temp>$=temp;

                                    printf("assignment found\n");  
                                    if($<s1.id_flag>3==1){
                                        strcpy(id_name,$<s1.strval>3);
                                        node *t1=variable_access(t,id_name);
                                        $<s1.id_flag>$=0;
                                    }
                                    if($<s1.id_flag>1==1){
                                        strcpy(id_name,$<s1.strval>1);
                                        node *t1=variable_access(t,id_name);
                                        $<s1.id_flag>$=0;
                                        //int label=check_type(t1->datatype);
                                        fprintf(fptr,"%s = %s",$<s1.strval>1,$<s1.strval>3);
                                        
                                    } 

                      }              
                    | C  T_ADD_SHORT C /*call variable access */ 
                                    {   
                                        AST_NODE *temp=create_ast_node("+=");
                                        insert_child_ast_node(temp,$<s1.temp>1);
                                        insert_child_ast_node(temp,$<s1.temp>3);
                                        $<s1.temp>$=temp;

                                        if($<s1.id_flag>3==1){
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=0;
                                            //int label=check_type(t1->datatype);

                                        }
                                        if($<s1.id_flag>1==1){
                                            strcpy(id_name,$<s1.strval>1);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=0;
                                        }     
                                    }
                    | C T_SUB_SHORT C /*call variable access */
                                    {   
                                        AST_NODE *temp=create_ast_node("-=");
                                        insert_child_ast_node(temp,$<s1.temp>1);
                                        insert_child_ast_node(temp,$<s1.temp>3);
                                        $<s1.temp>$=temp;

                                        if($<s1.id_flag>3==1){
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=0;
                                        }
                                        if($<s1.id_flag>1==1){
                                            strcpy(id_name,$<s1.strval>1);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=0;
                                        }
                                    }
                    | C T_MUL_SHORT C /*call variable access*/
                                    {   
                                        AST_NODE *temp=create_ast_node("*=");
                                        insert_child_ast_node(temp,$<s1.temp>1);
                                        insert_child_ast_node(temp,$<s1.temp>3);
                                        $<s1.temp>$=temp;

                                        if($<s1.id_flag>3==1){
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=0;
                                        }
                                        if($<s1.id_flag>1==1){
                                            strcpy(id_name,$<s1.strval>1);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=0;
                                        }    
                                    }
                    | C T_DIV_SHORT C /*call variable access */
                                    {   
                                        AST_NODE *temp=create_ast_node("/=");
                                        insert_child_ast_node(temp,$<s1.temp>1);
                                        insert_child_ast_node(temp,$<s1.temp>3);
                                        $<s1.temp>$=temp;

                                        if($<s1.id_flag>3==1){
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=0;
                                        }
                                        if($<s1.id_flag>1==1){
                                            strcpy(id_name,$<s1.strval>1);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=0;
                                        }    
                                    }
                    | C T_MOD_SHORT C /*call variable access */
                                    {   
                                        AST_NODE *temp=create_ast_node("%=");
                                        insert_child_ast_node(temp,$<s1.temp>1);
                                        insert_child_ast_node(temp,$<s1.temp>3);
                                        $<s1.temp>$=temp;

                                        if($<s1.id_flag>3==1){
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=0;
                                        }
                                        if($<s1.id_flag>1==1){
                                            strcpy(id_name,$<s1.strval>1);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=0;
                                        }    
                                    }
                    | C T_LOR C /*call variable access */
                                    {   
                                        AST_NODE *temp=create_ast_node("||");
                                        insert_child_ast_node(temp,$<s1.temp>1);
                                        insert_child_ast_node(temp,$<s1.temp>3);
                                        $<s1.temp>$=temp;

                                        if($<s1.id_flag>3==1){
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=0;
                                        }
                                        if($<s1.id_flag>1==1){
                                            strcpy(id_name,$<s1.strval>1);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=0;
                                        }    
                                    }
                    | C T_LAND C /*call variable access */
                                    {   
                                        AST_NODE *temp=create_ast_node("&&");
                                        insert_child_ast_node(temp,$<s1.temp>1);
                                        insert_child_ast_node(temp,$<s1.temp>3);
                                        $<s1.temp>$=temp;

                                        if($<s1.id_flag>3==1){
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=0;
                                        }
                                        if($<s1.id_flag>1==1){
                                            strcpy(id_name,$<s1.strval>1);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=0;
                                        } 
                                    }    
                    | C T_BITOR C /*call variable access */
                                    {   
                                        AST_NODE *temp=create_ast_node("|");
                                        insert_child_ast_node(temp,$<s1.temp>1);
                                        insert_child_ast_node(temp,$<s1.temp>3);
                                        $<s1.temp>$=temp;

                                        if($<s1.id_flag>3==1){
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=0;
                                        }
                                        if($<s1.id_flag>1==1){
                                            strcpy(id_name,$<s1.strval>1);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=0;
                                        }     
                                    }
                    | C T_XOR C  /*call variable access */
                                    {   
                                        AST_NODE *temp=create_ast_node("^");
                                        insert_child_ast_node(temp,$<s1.temp>1);
                                        insert_child_ast_node(temp,$<s1.temp>3);
                                        $<s1.temp>$=temp;

                                        if($<s1.id_flag>3==1){
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=0;
                                        }
                                        if($<s1.id_flag>1==1){
                                            strcpy(id_name,$<s1.strval>1);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=0;
                                        }     
                                    }
                    | C T_BITAND C /*call variable access */
                                    {   
                                        AST_NODE *temp=create_ast_node("&");
                                        insert_child_ast_node(temp,$<s1.temp>1);
                                        insert_child_ast_node(temp,$<s1.temp>3);
                                        $<s1.temp>$=temp;

                                        if($<s1.id_flag>3==1){
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=0;
                                        }
                                        if($<s1.id_flag>1==1){
                                            strcpy(id_name,$<s1.strval>1);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=0;
                                        }     
                                    }
                    | C T_BIT_LEFT_SHIFT C /*call variable access */
                                    {   
                                        AST_NODE *temp=create_ast_node("<<");
                                        insert_child_ast_node(temp,$<s1.temp>1);
                                        insert_child_ast_node(temp,$<s1.temp>3);
                                        $<s1.temp>$=temp;

                                        if($<s1.id_flag>3==1){
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=0;
                                        }
                                        if($<s1.id_flag>1==1){
                                            strcpy(id_name,$<s1.strval>1);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=0;
                                        }     
                                    }
                    | C T_BIT_RIGHT_SHIFT C /*call variable access */
                                    {   
                                        AST_NODE *temp=create_ast_node(">>");
                                        insert_child_ast_node(temp,$<s1.temp>1);
                                        insert_child_ast_node(temp,$<s1.temp>3);
                                        $<s1.temp>$=temp;

                                        if($<s1.id_flag>3==1){
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=0;
                                        }
                                        if($<s1.id_flag>1==1){
                                            strcpy(id_name,$<s1.strval>1);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=0;
                                        }     
                                    }
                    | C T_PLUS C /*call variable access */
                                    {   
                                        AST_NODE *temp=create_ast_node("+");
                                        insert_child_ast_node(temp,$<s1.temp>1);
                                        insert_child_ast_node(temp,$<s1.temp>3);
                                        $<s1.temp>$=temp;

                                        if($<s1.id_flag>3==1 && $<s1.id_flag>1==1){
                                            //if C is variable->s1.id_flag
                                            strcpy(id_name,$<s1.strval>1);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy(id_name,$<s1.strval>3);
                                            node *t2=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
    	                                    /* add temporary variable to symbol table*/
    	                                    int res=set_dtype(t1->datatype,t2->datatype,d_type,"+");
    	                                    if(res==-1){
    	                                    	yyerror("TypeError:Invalid type of operands for +");
    	                                    }
    										//evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp(t1->datatype,t2->datatype)){
                                                yyerror("Semantic Error in %: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t1->datatype,"int"))){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.ival=new_val1->ival + new_val2->ival;
                                                }
                                                else if(!strcmp(t1->datatype,"short")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.ival=new_val1->sival + new_val2->sival;
                                                    strcpy(d_type,"int");
                                                }
                                                else if(!strcmp(t1->datatype,"long")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.lival=new_val1->lival + new_val2->lival;

                                                }
                                                else if(!strcmp(t1->datatype,"byte")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.ival=new_val1->sival + new_val2->sival;
                                                    strcpy(d_type,"int");

                                                }
                                                else if(!strcmp(t1->datatype,"float")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.fval=new_val1->fval + new_val2->fval;
                                                }
                                                else if(!strcmp(t1->datatype,"double")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.dval=new_val1->dval + new_val2->dval;
                                                }
                                                else if(!strcmp(t1->datatype,"char")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.ival=new_val1->cval + new_val2->cval;
                                                    strcpy(d_type,"int");
                                                }
                                                else if(!strcmp(t1->datatype,"String")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    strcat(new_val.sval,new_val1->sval);
                                                    strcat(new_val.sval,new_val2->sval);
                                                }
                                                else{
                                                    yyerror("Semantic Error in %: Incompatible types");
                                                }
                                            }
                                            if(res==-1){
                                                yyerror("TypeError:Invalid type of operands for %");
                                            }
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("+",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else if($<s1.id_flag>1==1 && $<s1.id_flag>3==0){
                                        	strcpy(id_name,$<s1.strval>1);
                                            node *t2=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
    	                                    /* add temporary variable to symbol table*/
    	                                    int res=set_dtype(t2->datatype,$<s1.d_type>3,d_type,"+");
    	                                    if(res==-1){
    	                                    	yyerror("TypeError:Invalid type of operands for +");
    	                                    }
    										//evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>3,t2->datatype)){
                                                yyerror("Semantic Error in +: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t2->datatype,"int"))){
                                                    new_val2->ival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.ival=new_val1->ival + new_val2->ival;
                                                }
                                                else if(!strcmp(t2->datatype,"short")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.ival=new_val1->sival + new_val2->sival;
                                                    strcpy(d_type,"int");
                                                }
                                                else if(!strcmp(t2->datatype,"long")){
                                                    new_val2->lival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.lival=new_val1->lival + new_val2->lival;

                                                }
                                                else if(!strcmp(t2->datatype,"byte")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.ival=new_val1->sival + new_val2->sival;
                                                    strcpy(d_type,"int");
                                                }
                                                else if(!strcmp(t2->datatype,"float")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.fval=new_val1->fval + new_val2->fval;
                                                }
                                                else if(!strcmp(t2->datatype,"double")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.dval=new_val1->dval + new_val2->dval;
                                                }
                                                else if(!strcmp(t2->datatype,"char")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.ival=new_val1->cval + new_val2->cval;
                                                    strcpy(d_type,"int");
                                                }
                                                else if(!strcmp(t2->datatype,"String")){
                                                    strcpy(new_val2->sval,$<s1.strval>3);
                                                    get_value(t2,new_val1);
                                                    strcpy(new_val.sval,new_val1->sval);
                                                    strcpy(new_val.sval,new_val2->sval);
                                                }
                                                else{
                                                    yyerror("Semantic Error in +: Incompatible types");
                                                }
                                            }
                                            if(res==-1){
                                                yyerror("TypeError:Invalid type of operands for +");
                                            }
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("+",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else if($<s1.id_flag>1==0 && $<s1.id_flag>3==1){
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
    	                                    /* add temporary variable to symbol table*/
    	                                    int res=set_dtype(t1->datatype,$<s1.d_type>1,d_type,"+");
    	                                    if(res==-1){
    	                                    	yyerror("TypeError:Invalid type of operands for +");
    	                                    }
    										//evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>1,t1->datatype)){
                                                yyerror("Semantic Error in *: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t1->datatype,"int"))){
                                                    new_val1->ival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.ival=new_val1->ival + new_val2->ival;
                                                }
                                                else if(!strcmp(t1->datatype,"short")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.ival=new_val1->sival + new_val2->sival;
                                                    strcpy(d_type,"int");

                                                }
                                                else if(!strcmp(t1->datatype,"long")){
                                                    new_val1->lival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.lival=new_val1->lival + new_val2->lival;

                                                }
                                                else if(!strcmp(t1->datatype,"byte")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.ival=new_val1->sival + new_val2->sival;
                                                    strcpy(d_type,"int");

                                                }
                                                else if(!strcmp(t1->datatype,"float")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.fval=new_val1->fval + new_val2->fval;
                                                }
                                                else if(!strcmp(t1->datatype,"double")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.dval=new_val1->dval + new_val2->dval;
                                                }
                                                else if(!strcmp(t1->datatype,"char")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.ival=new_val1->cval + new_val2->cval;
                                                    strcpy(d_type,"int");

                                                }
                                                else if(!strcmp(t1->datatype,"String")){
                                                    strcpy(new_val1->sval,$<s1.strval>1);
                                                    get_value(t1,new_val2);
                                                    strcpy(new_val.sval,new_val1->sval);
                                                    strcpy(new_val.sval,new_val2->sval);
                                                }
                                                else{
                                                    yyerror("Semantic Error in +: Incompatible types");
                                                }
                                            }
                                            if(res==-1){
                                                yyerror("TypeError:Invalid type of operands for +");
                                            }
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("+",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else {
                                        	strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
    	                                    /* add temporary variable to symbol table*/
    	                                    int res=set_dtype($<s1.d_type>3,$<s1.d_type>1,d_type,"+");
    	                                    if(res==-1){
    	                                    	yyerror("TypeError:Invalid type of operands for +");
    	                                    }
    										//evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>1,$<s1.d_type>3)){
                                                yyerror("Semantic Error in +: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp($<s1.d_type>1,"int"))){
                                                    new_val1->ival=$<s1.intval>1;
                                                    new_val2->ival=$<s1.intval>3;
                                                    new_val.ival=new_val1->ival + new_val2->ival;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"short")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.ival=new_val1->sival + new_val2->sival;
                                                    strcpy(d_type,"int");
                                                }
                                                else if(!strcmp($<s1.d_type>1,"long")){
                                                    new_val1->lival=$<s1.intval>1;
                                                    new_val2->lival=$<s1.intval>3;
                                                    new_val.lival=new_val1->lival + new_val2->lival;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"byte")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.ival=new_val1->sival + new_val2->sival;
                                                    strcpy(d_type,"int");

                                                }
                                                else if(!strcmp($<s1.d_type>1,"float")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.fval=new_val1->fval + new_val2->fval;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"double")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.dval=new_val1->dval + new_val2->dval;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"char")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.ival=new_val1->cval + new_val2->cval;
                                                    strcpy(d_type,"int");
                                                }
                                                else{
                                                    yyerror("Semantic Error in +: Incompatible types");
                                                }
                                            }
                                            if(res==-1){
                                                yyerror("TypeError:Invalid type of operands for +");
                                            }
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("+",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
    	                                    $<s1.id_flag>$=1;
                                        }
                                        
                                    }
                    | C T_MINUS C /*call variable access */
                                    {   
                                        AST_NODE *temp=create_ast_node("-");
                                        insert_child_ast_node(temp,$<s1.temp>1);
                                        insert_child_ast_node(temp,$<s1.temp>3);
                                        $<s1.temp>$=temp;

                                        if($<s1.id_flag>3==1 && $<s1.id_flag>1==1){
                                            //if C is variable->s1.id_flag
                                            strcpy(id_name,$<s1.strval>1);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy(id_name,$<s1.strval>3);
                                            node *t2=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
    	                                    /* add temporary variable to symbol table*/
    	                                    int res=set_dtype(t1->datatype,t2->datatype,d_type,"-");
    	                                    if(res==-1){
    	                                    	yyerror("TypeError:Invalid type of operands for -");
    	                                    }
    										//evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp(t1->datatype,t2->datatype)){
                                                yyerror("Semantic Error in %: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t1->datatype,"int"))){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.ival=new_val1->ival - new_val2->ival;
                                                }
                                                else if(!strcmp(t1->datatype,"short")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->sival - new_val2->sival;

                                                }
                                                else if(!strcmp(t1->datatype,"long")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.lival=new_val1->lival - new_val2->lival;

                                                }
                                                else if(!strcmp(t1->datatype,"byte")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->sival - new_val2->sival;
                                                }
                                                else if(!strcmp(t1->datatype,"float")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.fval=new_val1->fval - new_val2->fval;
                                                }
                                                else if(!strcmp(t1->datatype,"double")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.dval=new_val1->dval - new_val2->dval;
                                                }
                                                else if(!strcmp(t1->datatype,"char")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.cval=new_val1->cval - new_val2->cval;
                                                }
                                                else{
                                                    yyerror("Semantic Error in %: Incompatible types");
                                                }
                                            }
                                            if(res==-1){
                                                yyerror("TypeError:Invalid type of operands for %");
                                            }
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("-",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else if($<s1.id_flag>1==1 && $<s1.id_flag>3==0){
                                        	strcpy(id_name,$<s1.strval>1);
                                            node *t2=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
    	                                    /* add temporary variable to symbol table*/
    	                                    int res=set_dtype(t2->datatype,$<s1.d_type>3,d_type,"-");
    	                                    if(res==-1){
    	                                    	yyerror("TypeError:Invalid type of operands for -");
    	                                    }
    										//evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>3,t2->datatype)){
                                                yyerror("Semantic Error in *: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t2->datatype,"int"))){
                                                    new_val2->ival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.ival=new_val1->ival - new_val2->ival;
                                                }
                                                else if(!strcmp(t2->datatype,"short")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->sival - new_val2->sival;
                                                }
                                                else if(!strcmp(t2->datatype,"long")){
                                                    new_val2->lival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.lival=new_val1->lival - new_val2->lival;

                                                }
                                                else if(!strcmp(t2->datatype,"byte")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->sival - new_val2->sival;
                                                }
                                                else if(!strcmp(t2->datatype,"float")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.fval=new_val1->fval - new_val2->fval;
                                                }
                                                else if(!strcmp(t2->datatype,"double")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.dval=new_val1->dval - new_val2->dval;
                                                }
                                                else if(!strcmp(t2->datatype,"char")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.cval=new_val1->cval - new_val2->cval;
                                                }
                                                else{
                                                    yyerror("Semantic Error in -: Incompatible types");
                                                }
                                            }
                                            if(res==-1){
                                                yyerror("TypeError:Invalid type of operands for -");
                                            }
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("-",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else if($<s1.id_flag>1==0 && $<s1.id_flag>3==1){
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
    	                                    /* add temporary variable to symbol table*/
    	                                    int res=set_dtype(t1->datatype,$<s1.d_type>1,d_type,"-");
    	                                    if(res==-1){
    	                                    	yyerror("TypeError:Invalid type of operands for -");
    	                                    }
    										//evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>1,t1->datatype)){
                                                yyerror("Semantic Error in -: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t1->datatype,"int"))){
                                                    new_val1->ival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.ival=new_val1->ival - new_val2->ival;
                                                }
                                                else if(!strcmp(t1->datatype,"short")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->sival - new_val2->sival;
                                                }
                                                else if(!strcmp(t1->datatype,"long")){
                                                    new_val1->lival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.lival=new_val1->lival - new_val2->lival;

                                                }
                                                else if(!strcmp(t1->datatype,"byte")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->sival- new_val2->sival;
                                                }
                                                else if(!strcmp(t1->datatype,"float")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.fval=new_val1->fval - new_val2->fval;
                                                }
                                                else if(!strcmp(t1->datatype,"double")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.dval=new_val1->dval - new_val2->dval;
                                                }
                                                else if(!strcmp(t1->datatype,"char")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.cval=new_val1->cval - new_val2->cval;

                                                }
                                                else{
                                                    yyerror("Semantic Error in -: Incompatible types");
                                                }
                                            }
                                            if(res==-1){
                                                yyerror("TypeError:Invalid type of operands for -");
                                            }
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("-",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else{
                                        	strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
    	                                    /* add temporary variable to symbol table*/
    	                                    int res=set_dtype($<s1.d_type>3,$<s1.d_type>1,d_type,"-");
    	                                    if(res==-1){
    	                                    	yyerror("TypeError:Invalid type of operands for -");
    	                                    }
    										//evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>1,$<s1.d_type>3)){
                                                yyerror("Semantic Error in -: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp($<s1.d_type>1,"int"))){
                                                    new_val1->ival=$<s1.intval>1;
                                                    new_val2->ival=$<s1.intval>3;
                                                    new_val.ival=new_val1->ival - new_val2->ival;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"short")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.sival=new_val1->sival - new_val2->sival;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"long")){
                                                    new_val1->lival=$<s1.intval>1;
                                                    new_val2->lival=$<s1.intval>3;
                                                    new_val.lival=new_val1->lival - new_val2->lival;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"byte")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.sival=new_val1->sival - new_val2->sival;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"float")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.fval=new_val1->fval- new_val2->fval;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"double")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.dval=new_val1->dval - new_val2->dval;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"char")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.cval=new_val1->cval - new_val2->cval;
                                                }
                                                else{
                                                    yyerror("Semantic Error in -: Incompatible types");
                                                }
                                            }
                                            if(res==-1){
                                                yyerror("TypeError:Invalid type of operands for -");
                                            }
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("-",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
    	                                    $<s1.id_flag>$=1;
                                        }
                                        
                                    }
                    | C T_MUL C /*call variable access */
                                    {   
                                        AST_NODE *temp=create_ast_node("*");
                                        insert_child_ast_node(temp,$<s1.temp>1);
                                        insert_child_ast_node(temp,$<s1.temp>3);
                                        $<s1.temp>$=temp;

                                        if($<s1.id_flag>3==1 && $<s1.id_flag>1==1){
                                            //if C is variable->s1.id_flag
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy(id_name,$<s1.strval>1);
                                            node *t2=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
    	                                    /* add temporary variable to symbol table*/
    	                                    int res=set_dtype(t1->datatype,t2->datatype,d_type,"*");
    	                                    if(res==-1){
    	                                    	yyerror("TypeError:Invalid type of operands for *");
    	                                    }
    										//evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp(t1->datatype,t2->datatype)){
                                                yyerror("Semantic Error in %: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t1->datatype,"int"))){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.ival=new_val1->ival * new_val2->ival;
                                                }
                                                else if(!strcmp(t1->datatype,"short")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.ival=new_val1->sival * new_val2->sival;
                                                    strcpy(d_type,"int");
                                                }
                                                else if(!strcmp(t1->datatype,"long")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.lival=new_val1->lival * new_val2->lival;

                                                }
                                                else if(!strcmp(t1->datatype,"byte")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.ival=new_val1->sival * new_val2->sival;
                                                    strcpy(d_type,"int");

                                                }
                                                else if(!strcmp(t1->datatype,"float")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.fval=new_val1->fval * new_val2->fval;
                                                }
                                                else if(!strcmp(t1->datatype,"double")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.dval=new_val1->dval * new_val2->dval;
                                                }
                                                else if(!strcmp(t1->datatype,"char")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.ival=new_val1->cval * new_val2->cval;
                                                    strcpy(d_type,"int");
                                                }
                                                else{
                                                    yyerror("Semantic Error in %: Incompatible types");
                                                }
                                            }
                                            if(res==-1){
                                                yyerror("TypeError:Invalid type of operands for %");
                                            }
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("*",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else if($<s1.id_flag>1==1 && $<s1.id_flag>3==0){
                                        	strcpy(id_name,$<s1.strval>1);
                                            node *t2=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
    	                                    /* add temporary variable to symbol table*/
    	                                    int res=set_dtype(t2->datatype,$<s1.d_type>3,d_type,"*");
    	                                    if(res==-1){
    	                                    	yyerror("TypeError:Invalid type of operands for *");
    	                                    }
    										//evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>3,t2->datatype)){
                                                yyerror("Semantic Error in *: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t2->datatype,"int"))){
                                                    new_val2->ival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.ival=new_val1->ival * new_val2->ival;
                                                }
                                                else if(!strcmp(t2->datatype,"short")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.ival=new_val1->sival * new_val2->sival;
                                                    strcpy(d_type,"int");
                                                }
                                                else if(!strcmp(t2->datatype,"long")){
                                                    new_val2->lival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.lival=new_val1->lival * new_val2->lival;

                                                }
                                                else if(!strcmp(t2->datatype,"byte")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.ival=new_val1->sival * new_val2->sival;
                                                    strcpy(d_type,"int");
                                                }
                                                else if(!strcmp(t2->datatype,"float")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.fval=new_val1->fval * new_val2->fval;
                                                }
                                                else if(!strcmp(t2->datatype,"double")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.dval=new_val1->dval * new_val2->dval;
                                                }
                                                else if(!strcmp(t2->datatype,"char")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.ival=new_val1->cval * new_val2->cval;
                                                    strcpy(d_type,"int");
                                                }
                                                else{
                                                    yyerror("Semantic Error in *: Incompatible types");
                                                }
                                            }
                                            if(res==-1){
                                                yyerror("TypeError:Invalid type of operands for *");
                                            }
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("*",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else if($<s1.id_flag>1==0 && $<s1.id_flag>3==1){
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
    	                                    /* add temporary variable to symbol table*/
    	                                    int res=set_dtype(t1->datatype,$<s1.d_type>1,d_type,"*");
    	                                    if(res==-1){
    	                                    	yyerror("TypeError:Invalid type of operands for *");
    	                                    }
    										//evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>1,t1->datatype)){
                                                yyerror("Semantic Error in *: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t1->datatype,"int"))){
                                                    new_val1->ival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.ival=new_val1->ival * new_val2->ival;
                                                }
                                                else if(!strcmp(t1->datatype,"short")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.ival=new_val1->sival * new_val2->sival;
                                                    strcpy(d_type,"int");

                                                }
                                                else if(!strcmp(t1->datatype,"long")){
                                                    new_val1->lival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.lival=new_val1->lival * new_val2->lival;

                                                }
                                                else if(!strcmp(t1->datatype,"byte")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.ival=new_val1->sival * new_val2->sival;
                                                    strcpy(d_type,"int");

                                                }
                                                else if(!strcmp(t1->datatype,"float")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.fval=new_val1->fval * new_val2->fval;
                                                }
                                                else if(!strcmp(t1->datatype,"double")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.dval=new_val1->dval * new_val2->dval;
                                                }
                                                else if(!strcmp(t1->datatype,"char")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.ival=new_val1->cval * new_val2->cval;
                                                    strcpy(d_type,"int");

                                                }
                                                else{
                                                    yyerror("Semantic Error in *: Incompatible types");
                                                }
                                            }
                                            if(res==-1){
                                                yyerror("TypeError:Invalid type of operands for *");
                                            }
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("*",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else{
                                        	strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
    	                                    /* add temporary variable to symbol table*/
    	                                    int res=set_dtype($<s1.d_type>3,$<s1.d_type>1,d_type,"*");
    	                                    if(res==-1){
    	                                    	yyerror("TypeError:Invalid type of operands for *");
    	                                    }
    										//evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>1,$<s1.d_type>3)){
                                                yyerror("Semantic Error in *: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp($<s1.d_type>1,"int"))){
                                                    new_val1->ival=$<s1.intval>1;
                                                    new_val2->ival=$<s1.intval>3;
                                                    new_val.ival=new_val1->ival * new_val2->ival;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"short")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.ival=new_val1->sival * new_val2->sival;
                                                    strcpy(d_type,"int");
                                                }
                                                else if(!strcmp($<s1.d_type>1,"long")){
                                                    new_val1->lival=$<s1.intval>1;
                                                    new_val2->lival=$<s1.intval>3;
                                                    new_val.lival=new_val1->lival * new_val2->lival;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"byte")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.ival=new_val1->sival * new_val2->sival;
                                                    strcpy(d_type,"int");

                                                }
                                                else if(!strcmp($<s1.d_type>1,"float")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.fval=new_val1->fval * new_val2->fval;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"double")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.dval=new_val1->dval * new_val2->dval;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"char")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.ival=new_val1->cval * new_val2->cval;
                                                    strcpy(d_type,"int");
                                                }
                                                else{
                                                    yyerror("Semantic Error in *: Incompatible types");
                                                }
                                            }
                                            if(res==-1){
                                                yyerror("TypeError:Invalid type of operands for *");
                                            }
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("*",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
    	                                    $<s1.id_flag>$=1;

                                        }
                                        
                                    }
                    | C T_DIV C /*call variable access */
                                    {   
                                        AST_NODE *temp=create_ast_node("/");
                                        insert_child_ast_node(temp,$<s1.temp>1);
                                        insert_child_ast_node(temp,$<s1.temp>3);
                                        $<s1.temp>$=temp;

                                        if($<s1.id_flag>3==1 && $<s1.id_flag>1==1){
                                            //if C is variable->s1.id_flag
                                            strcpy(id_name,$<s1.strval>1);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy(id_name,$<s1.strval>3);
                                            node *t2=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
    	                                    /* add temporary variable to symbol table*/
    	                                    int res=set_dtype(t1->datatype,t2->datatype,d_type,"/");
    	                                    if(res==-1){
    	                                    	yyerror("TypeError:Invalid type of operands for /");
    	                                    }
                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp(t1->datatype,t2->datatype)){
                                                yyerror("Semantic Error in %: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t1->datatype,"int"))){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.ival=new_val1->ival / new_val2->ival;
                                                }
                                                else if(!strcmp(t1->datatype,"short")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->sival / new_val2->sival;

                                                }
                                                else if(!strcmp(t1->datatype,"long")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.lival=new_val1->lival / new_val2->lival;

                                                }
                                                else if(!strcmp(t1->datatype,"byte")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->sival / new_val2->sival;
                                                }
                                                else if(!strcmp(t1->datatype,"float")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.fval=new_val1->fval / new_val2->fval;
                                                }
                                                else if(!strcmp(t1->datatype,"double")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.dval=new_val1->dval / new_val2->dval;
                                                }
                                                else if(!strcmp(t1->datatype,"char")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.cval=new_val1->cval / new_val2->cval;
                                                }
                                                else{
                                                    yyerror("Semantic Error in %: Incompatible types");
                                                }
        										insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
        	                                    add_quadruple("/",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                        }
                                    }   
                                        else if($<s1.id_flag>1==1 && $<s1.id_flag>3==0){
                                        	strcpy(id_name,$<s1.strval>1);
                                            node *t2=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
    	                                    /* add temporary variable to symbol table*/
    	                                    int res=set_dtype(t2->datatype,$<s1.d_type>3,d_type,"/");
    	                                    if(res==-1){
    	                                    	yyerror("TypeError:Invalid type of operands for /");
    	                                    }
    										//evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>3,t2->datatype)){
                                                yyerror("Semantic Error in /: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t2->datatype,"int"))){
                                                    new_val2->ival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.ival=new_val1->ival / new_val2->ival;
                                                }
                                                else if(!strcmp(t2->datatype,"short")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->sival / new_val2->sival;

                                                }
                                                else if(!strcmp(t2->datatype,"long")){
                                                    new_val2->lival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.lival=new_val1->lival / new_val2->lival;

                                                }
                                                else if(!strcmp(t2->datatype,"byte")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->sival / new_val2->sival;
                                                }
                                                else if(!strcmp(t2->datatype,"float")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.fval=new_val1->fval / new_val2->fval;
                                                }
                                                else if(!strcmp(t2->datatype,"double")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.dval=new_val1->dval / new_val2->dval;
                                                }
                                                else if(!strcmp(t2->datatype,"char")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.cval=new_val1->cval / new_val2->cval;
                                                }
                                                else{
                                                    yyerror("Semantic Error in /: Incompatible types");
                                                }
                                            }
                                            if(res==-1){
                                                yyerror("TypeError:Invalid type of operands for /");
                                            }
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("/",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else if($<s1.id_flag>1==0 && $<s1.id_flag>3==1){
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
    	                                    /* add temporary variable to symbol table*/
    	                                    int res=set_dtype(t1->datatype,$<s1.d_type>1,d_type,"/");
    	                                    if(res==-1){
    	                                    	yyerror("TypeError:Invalid type of operands for /");
    	                                    }
    										//evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>1,t1->datatype)){
                                                yyerror("Semantic Error in /: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t1->datatype,"int"))){
                                                    new_val1->ival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.ival=new_val1->ival / new_val2->ival;
                                                }
                                                else if(!strcmp(t1->datatype,"short")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->sival / new_val2->sival;

                                                }
                                                else if(!strcmp(t1->datatype,"long")){
                                                    new_val1->lival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.lival=new_val1->lival / new_val2->lival;

                                                }
                                                else if(!strcmp(t1->datatype,"byte")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->sival / new_val2->sival;
                                                }
                                                else if(!strcmp(t1->datatype,"float")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.fval=new_val1->fval / new_val2->fval;
                                                }
                                                else if(!strcmp(t1->datatype,"double")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.dval=new_val1->dval / new_val2->dval;
                                                }
                                                else if(!strcmp(t1->datatype,"char")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.cval=new_val1->cval / new_val2->cval;
                                                }
                                                else{
                                                    yyerror("Semantic Error in /: Incompatible types");
                                                }
                                            }
                                            if(res==-1){
                                                yyerror("TypeError:Invalid type of operands for /");
                                            }
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("/",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else{
                                        	strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
    	                                    /* add temporary variable to symbol table*/
    	                                    int res=set_dtype($<s1.d_type>3,$<s1.d_type>1,d_type,"/");
    	                                    if(res==-1){
    	                                    	yyerror("TypeError:Invalid type of operands for /");
    	                                    }
    										//evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>1,$<s1.d_type>3)){
                                                yyerror("Semantic Error in /: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp($<s1.d_type>1,"int"))){
                                                    new_val1->ival=$<s1.intval>1;
                                                    new_val2->ival=$<s1.intval>3;
                                                    new_val.ival=new_val1->ival / new_val2->ival;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"short")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.sival=new_val1->sival / new_val2->sival;

                                                }
                                                else if(!strcmp($<s1.d_type>1,"long")){
                                                    new_val1->lival=$<s1.intval>1;
                                                    new_val2->lival=$<s1.intval>3;
                                                    new_val.lival=new_val1->lival / new_val2->lival;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"byte")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.sival=new_val1->sival / new_val2->sival;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"float")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.fval=new_val1->fval / new_val2->fval;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"double")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.dval=new_val1->dval / new_val2->dval;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"char")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.cval=new_val1->cval / new_val2->cval;
                                                }
                                                else{
                                                    yyerror("Semantic Error in /: Incompatible types");
                                                }
                                            }
                                            if(res==-1){
                                                yyerror("TypeError:Invalid type of operands for /");
                                            }
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("/",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
    	                                    $<s1.id_flag>$=1;
                                        }
                                        
                                    }     
                    | C T_MOD C /*call variable access */
                                    {   
                                        AST_NODE *temp=create_ast_node("%");
                                        insert_child_ast_node(temp,$<s1.temp>1);
                                        insert_child_ast_node(temp,$<s1.temp>3);
                                        $<s1.temp>$=temp;

                                        printf("Adding\n");
                                        //if C is literal-> s1.intval
                                     
                                        if($<s1.id_flag>3==1 && $<s1.id_flag>1==1){
                                            //if C is variable->s1.id_flag
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy(id_name,$<s1.strval>1);
                                            node *t2=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;


                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
    	                                    /* add temporary variable to symbol table*/
    	                                    int res=set_dtype(t1->datatype,t2->datatype,d_type,"%");

                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp(t1->datatype,t2->datatype)){
                                                yyerror("Semantic Error in %: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t1->datatype,"int"))){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.ival=new_val1->ival % new_val2->ival;
                                                }
                                                else if(!strcmp(t1->datatype,"short")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->sival % new_val2->sival;

                                                }
                                                else if(!strcmp(t1->datatype,"long")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.lival=new_val1->lival % new_val2->lival;

                                                }
                                                else if(!strcmp(t1->datatype,"byte")){
                                                    get_value(t1,new_val1); 
                                                    get_value(t2,new_val2);
                                                    new_val.sival=new_val1->sival % new_val2->sival;
                                                }
                                                else{
                                                    yyerror("Semantic Error in %: Incompatible types");
                                                }
                                            }
    	                                    if(res==-1){
    	                                    	yyerror("TypeError:Invalid type of operands for %");
    	                                    }
    										insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
    	                                    add_quadruple("%",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else if($<s1.id_flag>1==1 && $<s1.id_flag>3==0){
                                        	strcpy(id_name,$<s1.strval>1);
                                            node *t2=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
    	                                    /* add temporary variable to symbol table*/
    	                                    int res=set_dtype(t2->datatype,$<s1.d_type>3,d_type,"%");
    	                                    if(res==-1){
    	                                    	yyerror("TypeError:Invalid type of operands for %");
    	                                    }

                                            //evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>3,t2->datatype)){
                                                yyerror("Semantic Error in %: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t2->datatype,"int"))){
                                                    new_val2->ival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.ival=new_val1->ival % new_val2->ival;
                                                }
                                                else if(!strcmp(t2->datatype,"short")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->sival % new_val2->sival;

                                                }
                                                else if(!strcmp(t2->datatype,"long")){
                                                    new_val2->lival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.lival=new_val1->lival % new_val2->lival;

                                                }
                                                else if(!strcmp(t2->datatype,"byte")){
                                                    new_val2->sival=$<s1.intval>3;
                                                    get_value(t2,new_val1);
                                                    new_val.sival=new_val1->sival % new_val2->sival;
                                                }
                                                else{
                                                    yyerror("Semantic Error in %: Incompatible types");
                                                }
                                            }
                                            if(res==-1){
                                                yyerror("TypeError:Invalid type of operands for %");
                                            }
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("%",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else if($<s1.id_flag>1==0 && $<s1.id_flag>3==1){
                                            strcpy(id_name,$<s1.strval>3);
                                            node *t1=variable_access(t,id_name);
                                            $<s1.id_flag>$=1;

                                            strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
    	                                    /* add temporary variable to symbol table*/
    	                                    int res=set_dtype(t1->datatype,$<s1.d_type>1,d_type,"%");
    	                                    if(res==-1){
    	                                    	yyerror("TypeError:Invalid type of operands for %");
    	                                    }
    										//evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>1,t1->datatype)){
                                                yyerror("Semantic Error in %: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp(t1->datatype,"int"))){
                                                    new_val1->ival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.ival=new_val1->ival % new_val2->ival;
                                                }
                                                else if(!strcmp(t1->datatype,"short")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->sival % new_val2->sival;

                                                }
                                                else if(!strcmp(t1->datatype,"long")){
                                                    new_val1->lival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.lival=new_val1->lival % new_val2->lival;

                                                }
                                                else if(!strcmp(t1->datatype,"byte")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    get_value(t1,new_val2);
                                                    new_val.sival=new_val1->sival % new_val2->sival;
                                                }
                                                else{
                                                    yyerror("Semantic Error in %: Incompatible types");
                                                }
                                            }
                                            if(res==-1){
                                                yyerror("TypeError:Invalid type of operands for %");
                                            }
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("%",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
                                        }
                                        else{
                                        	strcpy($<s1.strval>$,gen_temp()); //generates a new temp variable
    	                                    /* add temporary variable to symbol table*/
    	                                    int res=set_dtype($<s1.d_type>3,$<s1.d_type>1,d_type,"%");
    	                                    if(res==-1){
    	                                    	yyerror("TypeError:Invalid type of operands for %");
    	                                    }
    										//evaluate value of temporary variable
                                            VALUES *new_val1=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES *new_val2=(VALUES *)malloc(sizeof(VALUES));
                                            VALUES new_val;
                                            if(strcmp($<s1.d_type>1,$<s1.d_type>3)){
                                                yyerror("Semantic Error in %: Incompatible types");
                                            }
                                            else{
                                                if((!strcmp($<s1.d_type>1,"int"))){
                                                    new_val1->ival=$<s1.intval>1;
                                                    new_val2->ival=$<s1.intval>3;
                                                    new_val.ival=new_val1->ival % new_val2->ival;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"short")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.sival=new_val1->sival % new_val2->sival;

                                                }
                                                else if(!strcmp($<s1.d_type>1,"long")){
                                                    new_val1->lival=$<s1.intval>1;
                                                    new_val2->lival=$<s1.intval>3;
                                                    new_val.lival=new_val1->lival % new_val2->lival;
                                                }
                                                else if(!strcmp($<s1.d_type>1,"byte")){
                                                    new_val1->sival=$<s1.intval>1;
                                                    new_val2->sival=$<s1.intval>3;
                                                    new_val.sival=new_val1->sival % new_val2->sival;
                                                }
                                                else{
                                                    yyerror("Semantic Error in %: Incompatible types");
                                                }
                                            }
                                            if(res==-1){
                                                yyerror("TypeError:Invalid type of operands for %");
                                            }
                                            insert_table(t,"T_ID",1,$<s1.strval>$,d_type,new_val);
                                            add_quadruple("%",$<s1.strval>1,$<s1.strval>3,$<s1.strval>$);
                                            ;
                                            free(new_val1);
                                            free(new_val2);
    	                                    $<s1.id_flag>$=1;

                                        }
                                        
                                    }
                    | T_INCREMENT C /*call variable access */
                                    {   
                                        if($<s1.id_flag>2==1){
                                            strcpy(id_name,$<s1.strval>2);
                                            node *t1=variable_access(t,id_name);
                                            
                                        }
                                        $<s1.id_flag>$=0;
                                    }
                    | T_DECREMENT C /*call variable access */ 
                    				{	
                    					if($<s1.id_flag>2==1){
                    						strcpy(id_name,$<s1.strval>2);
                    						node *t1=variable_access(t,id_name);
                    						
                    					}
                                        $<s1.id_flag>$=0;
                    				}
                    | T_LNOT C {    
                                        if($<s1.id_flag>2==1){
                                            strcpy(id_name,$<s1.strval>2);
                                            node *t1=variable_access(t,id_name);
                                            
                                        }
                                        $<s1.id_flag>$=0;
                                    }
                    | O {
                            $<s1.id_flag>$=$<s1.id_flag>1;
                            $<s1.intval>$=$<s1.intval>1;
                            $<s1.doubval>$=$<s1.doubval>1;
                            strcpy($<s1.strval>$,$<s1.strval>1);
                            $<s1.boolval>$=$<s1.boolval>1;
                            $<s1.ch>$=$<s1.ch>1;
                            strcpy($<s1.d_type>$,$<s1.d_type>1);
                            $<s1.temp>$=$<s1.temp>1;

                            printf("Reducing C->O %d %d\n",$<s1.id_flag>$,$<s1.intval>$);
                            }
                    ;
    O:              O T_INCREMENT /*call variable access */
                                    {    
                                        if($<s1.id_flag>1==1){
                                            strcpy(id_name,$<s1.strval>1);
                                            node *t1=variable_access(t,id_name);
                                            
                                        }
                                        strcpy($<s1.strval>$,$<s1.strval>1);
                                        $<s1.id_flag>$=0;
                                    }
                    | O T_DECREMENT /*call variable access */
                                    {    
                                        if($<s1.id_flag>1==1){
                                            strcpy(id_name,$<s1.strval>1);
                                            node *t1=variable_access(t,id_name);
                                        }
                                        strcpy($<s1.strval>$,$<s1.strval>1);
                                        $<s1.id_flag>$=0;
                                    }
                    | H {
                            $<s1.id_flag>$=$<s1.id_flag>1;
                            $<s1.intval>$=$<s1.intval>1;
                            $<s1.doubval>$=$<s1.doubval>1;
                            strcpy($<s1.strval>$,$<s1.strval>1);
                            $<s1.boolval>$=$<s1.boolval>1;
                            $<s1.ch>$=$<s1.ch>1;
                            strcpy($<s1.d_type>$,$<s1.d_type>1);
                            $<s1.temp>$=$<s1.temp>1;

                            printf("Reducing O->H %d %d\n",$<s1.id_flag>$,$<s1.intval>$);   
                        }
                    ;


    /* TODO: TAKE CARE OF T_CHARACTER */
    H:              T_ID {strcpy($<s1.strval>$,$<s1.strval>1);$<s1.id_flag>$=1;$<s1.temp>$=create_ast_node($<s1.strval>1);}
                    | T_LEFT_PARAN C T_RIGHT_PARAN {$$=$2;$<s1.id_flag>$=0;}
                    | T_ID  T_LEFT_BRACKET T_DIGIT T_RIGHT_BRACKET 
                                    {strcpy($<s1.strval>$,$<s1.strval>1);$<s1.id_flag>$=1;}
                    | T_DIGIT {$<s1.intval>$=$<s1.intval>1;$<s1.id_flag>$=0;strcpy($<s1.d_type>$,"int");strcpy($<s1.strval>$,$<s1.strval>1);
                    $<s1.temp>$=create_ast_node($<s1.strval>1);
                    }
                    | T_CHARACTER {$<s1.id_flag>$=0;$<s1.ch>$=$<s1.ch>1;strcpy($<s1.d_type>$,"char");strcpy($<s1.strval>$,$<s1.strval>1); 
                    $<s1.temp>$=create_ast_node($<s1.strval>1);
                    }
                    | string 
                    | T_DECIMAL {$<s1.id_flag>$=0;$<s1.doubval>$=$<s1.doubval>1;strcpy($<s1.d_type>$,"float");strcpy($<s1.strval>$,$<s1.strval>1);
                    $<s1.temp>$=create_ast_node($<s1.strval>1);
                    }
                    | T_TRUE {$<s1.boolval>$=1;$<s1.id_flag>$=0;strcpy($<s1.d_type>$,"boolean");strcpy($<s1.strval>$,$<s1.strval>1);
                    $<s1.temp>$=create_ast_node($<s1.strval>1);
                    }
                    | T_FALSE {$<s1.boolval>$=0;$<s1.id_flag>$=0;strcpy($<s1.d_type>$,"boolean");strcpy($<s1.strval>$,$<s1.strval>1);
                    $<s1.temp>$=create_ast_node($<s1.strval>1);
                    }
                    ;
    /*Z:              T_ID
                    | T_LEFT_PARAN C T_RIGHT_PARAN
                    | integer
                    | T_SQUOTE T_CHARACTER T_SQUOTE
                    | string
                    | T_DECIMAL
                    | T_TRUE
                    | T_FALSE
                    ;*/
    /*Z:              T_ID T_EQUALTO Y
                    | T_ID T_ADD_SHORT Y
                    | T_ID T_SUB_SHORT Y
                    | T_ID T_MUL_SHORT Y
                    | T_ID T_DIV_SHORT Y
                    | T_ID T_MOD_SHORT Y
                    ;
    Y:              T_ID T_EQUALTO Y
                    | T_ID T_ADD_SHORT Y
                    | T_ID T_SUB_SHORT Y
                    | T_ID T_MUL_SHORT Y
                    | T_ID T_DIV_SHORT Y
                    | T_ID T_MOD_SHORT Y
                    | C
                    | T_ID
                    | integer
                    | T_SQUOTE T_CHARACTER T_SQUOTE
                    | string
                    | T_DECIMAL
                    ;*/

    Q:              T_LEFT_FLOW_PARAN inside_q
                    ;
    inside_q:       T_ID
                    |T_DIGIT
                    |T_SQUOTE T_CHARACTER T_SQUOTE
                    |T_DECIMAL T_COMMA inside_q
                    | R
                    ;
    R:              T_RIGHT_FLOW_PARAN
                    ;
    /*integer:        T_DIGIT X {printf("integer found\n");}
                    ;*/
    /*X:              /*lambda*/ 
    /*                | T_DIGIT X
                    ;*/


    S2:             T_IF {
                        int hash_index=hash_scope(current_level);
                        strcpy(label_arr[hash_index].L1,new_label());
                        scope_numbering[ast_scope]=create_ast_node("ifstmt");
                        insert_child_ast_node(scope_numbering[ast_scope-1],scope_numbering[ast_scope]);
                        ast_scope++;

                    }
                    T_LEFT_PARAN bool_exp 
                    {
                        int hash_index=hash_scope(current_level);

                        AST_NODE *child1=$<s1.temp>4;
                        insert_child_ast_node(scope_numbering[ast_scope-1],child1);

                        AST_NODE *temp=create_ast_node("if");
                        scope_numbering[ast_scope]=temp;
                        printf("hello\n");
                        insert_child_ast_node(scope_numbering[ast_scope-1],temp);
                        printf("%s\n",scope_numbering[ast_scope-1]->name);
                        ast_scope++;
                        printf("%s\n",child1->name);

                        add_quadruple("ifFalse",$<s1.strval>4,NULL,label_arr[hash_index].L1);
                    }
                    T_RIGHT_PARAN  T_LEFT_FLOW_PARAN {enter_scope();} stmt 
                    T_RIGHT_FLOW_PARAN {
                        printf("%s\n",scope_numbering[ast_scope-1]->name);
                        //this is BLOCK
                        printf("hi\n");
                        AST_NODE *child2=scope_numbering[ast_scope-1];

                        printf("%s\n",child2->name);
                        exit_scope();
                        printf("Scope is %s\n",current_level);
                        insert_child_ast_node(scope_numbering[ast_scope-1],child2);
                        ast_scope--;
                        printf("%s \n",scope_numbering[ast_scope-1]->name);
                        printf("The number of children %d\n",scope_numbering[ast_scope-1]->num_children);
                        printf("First child %s\n",scope_numbering[ast_scope-1]->child[0]->name);
                        printf("second child %s\n",scope_numbering[ast_scope-1]->child[1]->name);
                        int hash_index=hash_scope(current_level);

                        add_quadruple("Label",NULL,NULL,label_arr[hash_index].L1);                    
                    }
                    N
                    {
                            printf("elseeeee");
                            printf("%s\n",scope_numbering[ast_scope-1]->name);
                            insert_child_ast_node(scope_numbering[ast_scope-1],$<s1.temp>12);
                            printf("s1.temp 12 %s\n",($<s1.temp>12)->name);
                            ast_scope--;
                            printf("%s\n",scope_numbering[ast_scope-1]->child[1]->name); 
                    }

                    | T_IF 
                    {
                        int hash_index=hash_scope(current_level);

                        strcpy(label_arr[hash_index].L1,new_label());
                        scope_numbering[ast_scope]=create_ast_node("ifstmt");
                        insert_child_ast_node(scope_numbering[ast_scope-1],scope_numbering[ast_scope]);

                        ast_scope++;

                        

                    } T_LEFT_PARAN bool_exp 
                    {
                        int hash_index=hash_scope(current_level);

                        AST_NODE *child1=$<s1.temp>4;
                        insert_child_ast_node(scope_numbering[ast_scope-1],child1);

                        AST_NODE *temp=create_ast_node("if");
                        scope_numbering[ast_scope]=temp;
                        insert_child_ast_node(scope_numbering[ast_scope-1],temp);
                        ast_scope++;
                        add_quadruple("ifFalse",$<s1.strval>4,NULL,label_arr[hash_index].L1);
                    }
                    T_RIGHT_PARAN stmt
                    {
                        int hash_index=hash_scope(current_level);

                        AST_NODE *child2=scope_numbering[ast_scope-1];
                        ast_scope--;
                        insert_child_ast_node(scope_numbering[ast_scope-1],child2);
                        ast_scope--;
                        ast_scope--;
                        add_quadruple("Label",NULL,NULL,label_arr[hash_index].L1);                    
                    } 
                    ;
    /*Y:            stmt
                    | S2
                    ;*/
    //Z:              /*lambda*/
    /*                |stmt Z
                    ;*/
    N:              T_ELSE T_LEFT_FLOW_PARAN {enter_scope();} 
                    stmt T_RIGHT_FLOW_PARAN 
                    {
                        AST_NODE *temp=create_ast_node("else");
                        AST_NODE *child2=scope_numbering[ast_scope-1];
                        insert_child_ast_node(temp,child2);
                        $<s1.temp>$=temp;
                        exit_scope();
                    }
                    | T_ELSE stmt
                    ;
    string:         T_QUOTE I
                    ;
    I:              T_QUOTE
                    |T_CHARACTER I 
                    ;
    %%


    void initialize_table(symbol_table *t){
            t->first=NULL;
    }
    node* insert_table(symbol_table *t,char *token,int flag_dtype,char *token_name,char *d_type,VALUES val){
            printf("Insert table called\n");
            if(strlen(token_name)>31){
                    fprintf(stderr,"%s\n","Identifier longer than 31 characters! Truncating to the first 31 characters!");
                    token_name[31]='\0';
            }
            printf("Check done\n");
            //Check if token already exists
            node *s=t->first;
            if(t->first!=NULL){
                while(s!=NULL){
                    if(!strcmp(s->token_name,token_name)){
                        if(!strcmp(s->scope_number,current_level)){
                            printf("Compile Error:Identifier already exists!");
                            exit(1);
                        }
                    }
                    s=s->next;
                }
            }

            node *temp=(node *)malloc(sizeof(node));
            strcpy(temp->token_name,token_name);
            char *str=(char *)malloc(sizeof(char)*strlen(token));
            strcpy(str,token);
            strcpy(temp->token,str);
            temp->line_number=yylloc.first_line;
            //printf("%d",temp->line_number);
            temp->first_column=yylloc.first_column;
            temp->last_column=yylloc.last_column;
            strcpy(temp->scope_number,current_level);
            temp->useful_flag=0;

            if(flag_dtype==1){
                printf("dtype %s\n",d_type);
                strcpy(temp->datatype,d_type);
            }


            if(!strcmp(temp->datatype,"String")){
                strcpy((temp->value).sval,val.sval);
                strcpy(temp->c_dtype,"char");
            }
            else if(!strcmp(temp->datatype,"double")){
                (temp->value).dval=val.dval;
                strcpy(temp->c_dtype,"double");
            }
            else if(!strcmp(temp->datatype,"float")){
                (temp->value).fval=val.fval;
                strcpy(temp->c_dtype,"float");
            }
            else if(!strcmp(temp->datatype,"int")){
                (temp->value).ival=val.ival;
                strcpy(temp->c_dtype,"int");   
            }
            else if(!strcmp(temp->datatype,"long")){
                (temp->value).lival=val.lival;
                strcpy(temp->c_dtype,"long int");
            }
            else if(!strcmp(temp->datatype,"char")){
                (temp->value).cval=val.cval;
                strcpy(temp->c_dtype,"char");

            }
            else if(!strcmp(temp->datatype,"short")){
                (temp->value).sival=val.sival;
                strcpy(temp->c_dtype,"short int");
            }
            else if(!strcmp(temp->datatype,"byte")){
                (temp->value).sival=val.sival;
                strcpy(temp->c_dtype,"short int");
            }
            else if(!strcmp(temp->datatype,"boolean")){
                (temp->value).sival=val.sival;
                strcpy(temp->c_dtype,"short int");

            }

            printf("Created a new node\n");
            temp->next=NULL;
            //no node in Linked List
            if(t==NULL)printf("it is null\n");
            if(t->first==NULL){
                    printf("No node\n");
                    t->first=temp;
            }
            else{
                    printf("in else\n");
                    node *n=t->first;
                    while(n->next!=NULL){
                            n=n->next;
                    }
                    n->next=temp;
            }
            return temp;
    }
    void free_table(symbol_table *t){
            //Linked list not empty
            if(t->first!=NULL){
                    node *temp=t->first;
                    while(temp!=NULL){
                            node *n=temp;
                            t->first=temp->next;
                            free(n->token);
                            free(n);
                            temp=t->first;
                    }
            }
    }

    void display_table(symbol_table *t){
            node *temp=t->first;
            if(temp==NULL)printf("Nothing to display in symbol table\n");
            while(temp!=NULL){
                    printf("Token type: %s\t",temp->token);
                    printf("Token data type %s\t",temp->datatype);
                    printf("Token name: %s\t",temp->token_name);
                    printf("Line number: %d\t",temp->line_number);
                    printf("First column: %d\t",temp->first_column);
                    printf("Last column: %d\t",temp->last_column);
                    printf("Scope number %s\t",temp->scope_number);
                    printf("Value ");
                    if(!strcmp(temp->c_dtype,"int")){
                        printf("%d\n",(temp->value).ival);
                    }
                    else if(!strcmp(temp->c_dtype,"short int")){
                        printf("%d\n",(temp->value).sival);
                    }
                    else if(!strcmp(temp->c_dtype,"long int")){
                        printf("%ld\n",(temp->value).lival);
                    }
                    else if(!strcmp(temp->c_dtype,"char")){
                        printf("%c\n",(temp->value).cval);
                    }
                    else if(!strcmp(temp->c_dtype,"double")){
                        printf("%f\n",(temp->value).dval);
                    }
                    else if(!strcmp(temp->c_dtype,"float")){
                        printf("%lf\n",(temp->value).fval);
                    }
                    else{
                        printf("hi");
                    }
                    temp=temp->next;
            }
    }
    /*void initialize_stack(stack *stk){
            stk->top=-1;
    }*/
    //Stores variable name and scope number as a new stack entry
    /*void insert_stack(stack *stk,char *variable_name){
            if(stk->top==100){
                    fprintf(stderr,"%s\n","Stack is full")
            }
            ++(stk->top);
            strcpy(stk->n[stk->top].token_name,variable_name);
            stk->n[stk->top].scope_number=current_level;
    }
    void search_stack(stack *stk,char *token_name){
            //Traverse down the stack and search for token_name. 
            //Function is called in order to determine the scope in which a variable is referred to
            int temp=stk->top;
            while(temp!=0){
                    if(!strcmp(token_name,stk->n[temp].token_name)){
                            //Variable found

                    }        
                    temp--;
            }
            //Variable not found. Throw error
            fprintf(stderr,"%s\n","Undefined reference to variable");
    }*/
    int num_digits(int val){
            int temp=val;
            int count=0;
            while(temp!=0){
                    temp=temp/10;
                    count++;
            }
            return count;
    }
    //TODO: Handle size of current_level exceeding 100
    void my_itoa(int val,char *arr)
    {
            int digits=num_digits(val);
            int temp=val;
            int i=0;
            while(temp!=0){
                    arr[i]=(temp/(int) pow(10,digits-i-1))+'0';
                    temp=temp%(int)(pow(10,digits-i-1));
                    i++;
            }
            arr[i]='\0';
            current_level_length+=digits+1;
    }
    void enter_scope(){
            printf("Entered enter scope%s\n",current_level);
            if(current_level_length>=100){
                    fprintf(stderr, "%s\n","Too much scoping!");
                    exit(0);
            }
            current_level[current_level_length]='_';
            my_itoa(previous_level+1,current_level+current_level_length+1);
            current_level[current_level_length]='\0';
            printf("Exiting enter scope\n");
            printf("%s\n",current_level);
            scope_numbering[ast_scope]=create_ast_node("BLOCK");
            ast_scope++;
    }
    void exit_scope(){
            if(current_level_length==1){
                    current_level[0]='\0';
                    current_level_length=0;
            }
            int j=0;
            while(current_level[current_level_length-1-j]!='_')j++;
            char *buff2=(char *)malloc(sizeof(char)*(strlen(current_level)+1));
            strcpy(buff2,current_level+current_level_length-j);
            previous_level=atoi(buff2);
            current_level[current_level_length-1-j]='\0';
            free(buff2);
            current_level_length=current_level_length-1-j;
            ast_scope--;
    }
    /*void remove_stack(stack *stk){
            stk->top--;
    }*/
    int diff_scope(char *entry_scope, char *given_scope){
            //use an efficient Longest Prefix Matching algorithm

            //using Naive String Matching
            int i=0,j=0;
            int n=strlen(given_scope);
            int m=strlen(entry_scope);
            if(m>n)return -1;
            //Runs in O(m)
            int count=0;
            while(j<=m){
                    if(entry_scope[j]==given_scope[j])count=count+2;
                    else break;
                    j=j+2;
            }
            return count;
            printf("Exiting diff scope\n");
    }
    //traverse through the symbol table and determine the scope of the variable accessed
    node* variable_access(symbol_table *t,char *var_name){
            printf("Entered variable access with var_name %s\n",var_name);
            if(t->first==NULL){
                    printf("Symbol table is empty");
            }       
            int flag=0;
            node *temp=t->first;
            int max_scope=0;
            node *closest_entry;
            while(temp!=NULL){
                    //call diff_scope() that finds how close that scope is the variable in the entry to the current scope
                    if(strcmp(temp->token_name,var_name)){temp=temp->next;continue;}
                    int val=diff_scope(temp->scope_number,current_level);
                    flag=1;
                    if(val>max_scope){
                            closest_entry=temp;
                            max_scope=val;
                    }
                    //if(val==max_scope)break;
                   	temp=temp->next;
            }
            if(flag==0){
                printf("Variable %s does not exist!\n",var_name);
                exit(1);
            }
            printf("variable access end %s\n",closest_entry->token_name);
            (closest_entry->useful_flag)++;
            return closest_entry;

    }
    //Returns the datatype of the result based on precedence of data types
    //Return -1 if operands are incompatible
    int set_dtype(char *type1,char *type2,char *d_type,char *op_val){
    	if(!strcmp(type1,type2)) {strcpy(d_type,type1);return 0;}
    	if(type2==NULL){
    		//only one operand
    	}

    	if((!strcmp(type1,"double"))||(!strcmp(type2,"double"))){
    		strcpy(d_type,"double");
    	}
    	if((!strcmp(type1,"float"))||(!strcmp(type2,"float"))){
    		strcpy(d_type,"float");
    	}
    	if((!strcmp(type1,"long"))||(!strcmp(type2,"long"))){
    		strcpy(d_type,"long");
    	}
    	if((!strcmp(type1,"int"))||(!strcmp(type2,"int"))){
    		strcpy(d_type,"int");
    	}
    	if((!strcmp(type1,"char"))||(!strcmp(type2,"char"))){
    		strcpy(d_type,"char");
    	}
    	if((!strcmp(type1,"short"))||(!strcmp(type2,"short"))){
    		strcpy(d_type,"short");
    	}
    	if((!strcmp(type1,"byte"))||(!strcmp(type2,"byte"))){
    		strcpy(d_type,"byte");
    	}
    	if((!strcmp(type1,"boolean"))||(!strcmp(type2,"boolean"))){
    		strcpy(d_type,"boolean");
    	}
    	//Check for compatability
    	
    	return 0;
    }
    char* gen_temp(){
    	sprintf(temp_buffer,"t%d",temp_counter);
    	temp_counter++;
    	return temp_buffer;
    }
    char* new_label(){
        sprintf(label_buffer,"L%d",label_counter);
        label_counter++;
        return label_buffer;
    }
    void display_quadruple(){
    	for(int i=0;i<QUAD_INDEX;i++){
    		printf("%s %s %s %s\n",QUAD[i].operator_val,QUAD[i].op1,QUAD[i].op2,QUAD[i].res);
    	}
    }
    void add_quadruple(char *operator,char *op1,char *op2,char *res){
    	printf("Entering add_quadruple\n");
    	strcpy(QUAD[QUAD_INDEX].operator_val,operator);
    	if(op1==NULL && op2==NULL){
    		QUAD[QUAD_INDEX].op1[0]='\0';
    		QUAD[QUAD_INDEX].op2[0]='\0';	
    	}
    	else strcpy(QUAD[QUAD_INDEX].op1,op1);
    	if(op2!=NULL)
    		strcpy(QUAD[QUAD_INDEX].op2,op2);
    	else
    		QUAD[QUAD_INDEX].op2[0]='\0';
    	strcpy(QUAD[QUAD_INDEX].res,res);
    	printf("QUAD[QUAD_INDEX].res %s\n",QUAD[QUAD_INDEX].res);
    	QUAD_INDEX++;
    }
    //TODO: Implementing type compatibility 
    void get_value(node *temp,VALUES *new_val){
        if(!strcmp(temp->datatype,"int")){       
            new_val->ival=(temp->value).ival;
        }
        if(!strcmp(temp->datatype,"float")){
            new_val->fval=(temp->value).fval;
        }
        if(!strcmp(temp->datatype,"double")){
            new_val->dval=(temp->value).dval;
        }
        if(!strcmp(temp->datatype,"byte")){
            new_val->sival=(temp->value).sival;
        }
        if(!strcmp(temp->datatype,"long")){
            new_val->lival=(temp->value).lival;
        }
        if(!strcmp(temp->datatype,"char")){
            new_val->cval=(temp->value).cval;
        }
        if(!strcmp(temp->datatype,"boolean")){
            new_val->sival=(temp->value).sival;
        }
        if(!strcmp(temp->datatype,"short")){
            new_val->sival=(temp->value).sival;
        }
    }
    AST_NODE* create_ast_node(char *op){
        AST_NODE *temp=(AST_NODE *)malloc(sizeof(AST_NODE));
        temp->num_children=0;
        temp->max_children=100;
        strcpy(temp->name,op);
        for(int i=0;i<temp->max_children;i++){
            temp->child[i]=NULL;
        }
        return temp;
    }
    void insert_child_ast_node(AST_NODE *parent,AST_NODE *child){
        if(parent->num_children==parent->max_children){
            printf("Maximum number of children in AST reached!\n");
            exit(1);
        }
        parent->child[parent->num_children++]=child;
    }

    void display_AST(AST_NODE *root){
        printf("AST of the tree is \n");
        if(root!=NULL && root->num_children==0){
            printf("%s\n",root->name);
            return; 
        }
        AST_NODE *temp=root;
        int i=0;
        while(temp->child[i]!=NULL){
            if(i==1)printf("%s\n",temp->name);
            display_AST(temp->child[i]);
            i++;
        }
        if(i==1){
            printf("%s\n",temp->name);
        }
    }
    //works only for single digit scope numbers
    int hash_scope(char *current_level){
        int i=0;
        int sum=0;
        while(current_level[i]!='\0'){
            if(current_level[i]!='_')sum=sum+current_level[i]-'0';
            i++;
        }
        return sum;
    }
    void dead_code_elimination(){
        int optimized_quad_counter=0;
        printf("ICG Code after dead code elimination:\n");

        for(int i=0;i<QUAD_INDEX;i++){
            int flag=0;
            if(QUAD[i].res!=NULL && (strncmp(QUAD[i].res,"L",1))){
                for(int j=i;j<QUAD_INDEX;j++){
                    if(QUAD[j].op1!=NULL){
                        if(!strcmp(QUAD[i].res,QUAD[j].op1))flag=1;
                    }
                    if(QUAD[j].op2!=NULL){
                        if(!strcmp(QUAD[i].res,QUAD[j].op2))flag=1;
                    }
                }
                if(flag==1){
                    strcpy(OPTIMIZED_QUAD[optimized_quad_counter].operator_val,QUAD[i].operator_val);
                    strcpy(OPTIMIZED_QUAD[optimized_quad_counter].op1,QUAD[i].op1);
                    strcpy(OPTIMIZED_QUAD[optimized_quad_counter].op2,QUAD[i].op2);
                    strcpy(OPTIMIZED_QUAD[optimized_quad_counter].res,QUAD[i].res);
                    printf("%s %s %s %s\n",OPTIMIZED_QUAD[optimized_quad_counter].operator_val,OPTIMIZED_QUAD[optimized_quad_counter].op1,OPTIMIZED_QUAD[optimized_quad_counter].op2,OPTIMIZED_QUAD[optimized_quad_counter].res);
                    optimized_quad_counter++;
                }   
            }
            else{
                strcpy(OPTIMIZED_QUAD[optimized_quad_counter].operator_val,QUAD[i].operator_val);
                    strcpy(OPTIMIZED_QUAD[optimized_quad_counter].op1,QUAD[i].op1);
                    strcpy(OPTIMIZED_QUAD[optimized_quad_counter].op2,QUAD[i].op2);
                    strcpy(OPTIMIZED_QUAD[optimized_quad_counter].res,QUAD[i].res);
                    printf("%s %s %s %s\n",OPTIMIZED_QUAD[optimized_quad_counter].operator_val,OPTIMIZED_QUAD[optimized_quad_counter].op1,OPTIMIZED_QUAD[optimized_quad_counter].op2,OPTIMIZED_QUAD[optimized_quad_counter].res);
                    optimized_quad_counter++;
            }    
        }
    }
    /*void dead_code_elimination(){
        printf("ICG Code after dead code elimination:\n");
        int optimized_quad_counter=0;
        //traverse the quadruple table
        for(int i=0;i<QUAD_INDEX;i++){
            if(QUAD[i].res!=NULL && (strncmp(QUAD[i].res,"L",1))){
                strcpy(id_name,QUAD[i].res);
                node *t1=variable_access(t,id_name);
                printf("useful flag %d\n",t1->useful_flag);
                if(t1->useful_flag>1){
                    strcpy(OPTIMIZED_QUAD[optimized_quad_counter].operator_val,QUAD[i].operator_val);
                    strcpy(OPTIMIZED_QUAD[optimized_quad_counter].op1,QUAD[i].op1);
                    strcpy(OPTIMIZED_QUAD[optimized_quad_counter].op2,QUAD[i].op2);
                    strcpy(OPTIMIZED_QUAD[optimized_quad_counter].res,QUAD[i].res);
                    printf("%s %s %s %s\n",OPTIMIZED_QUAD[optimized_quad_counter].operator_val,OPTIMIZED_QUAD[optimized_quad_counter].op1,OPTIMIZED_QUAD[optimized_quad_counter].op2,OPTIMIZED_QUAD[optimized_quad_counter].res);
                    optimized_quad_counter++;
                }
            }
        }
    }*/
    int main()
    {
            //initialize_stack(stk);
            //struct quad OPTIMIZED_QUAD[100];
            FILE *fptr=fopen("output","w");
            flag_dtype=0;
            t=(struct symbol_table *)malloc(sizeof(struct symbol_table));
            t->first=NULL;
            printf("In  main\n");
            int c=yyparse();
            if(c==0)
                    printf("Success!");
            else
                    printf("Failure!");
    }
    int yyerror(char *s)
    {
      fprintf(stderr, "%s\n",s);
      return 0;
    }
    int yywrap()
    {
      return(1);
    }

    /*C:              T_ID T_EQUALTO C
                    | T_ID T_ADD_SHORT C
                    | T_ID T_SUB_SHORT C
                    | T_ID T_MUL_SHORT C
                    | T_ID T_DIV_SHORT C
                    | T_ID T_MOD_SHORT C
                    |J_prime
    J_prime:        J_prime T_LOR J
                    | J
                    ;
    J:              K
                    |J T_LAND K
                    ;
    K:              L
                                    | K T_BITOR L
                    ;
    L:              M
                    |L T_XOR M
                    ;
    M:              A
                    |M T_BITAND A
                    ;
    A:              A T_BIT_LEFT_SHIFT D
                    | A T_BIT_RIGHT_SHIFT D
                    |D
                    ;
    D:              E
                    | D T_PLUS E
                    | D T_MINUS E
                    ;
    E:              F
                    | E T_MUL F
                    | E T_DIV F
                    | E T_MOD F
                    ;
    F:              T_INCREMENT F
                    | T_DECREMENT F
                    |G
                    ;
    G:              H T_INCREMENT
                    | H T_DECREMENT
                    | H
                    | T_LNOT H
                    ;

    S:              T_IF {
                        strcpy(L1,new_label());
                        scope_numbering[ast_scope]=create_ast_node("ifstmt");
                        insert_child_ast_node(scope_numbering[ast_scope-1],scope_numbering[ast_scope]);
                        ast_scope++;

                        AST_NODE *temp=create_ast_node("if");
                        scope_numbering[ast_scope]=temp;
                        insert_child_ast_node(scope_numbering[ast_scope-1],temp);
                        ast_scope++;

                    } T_LEFT_PARAN bool_exp 
                    {
                        add_quadruple("ifFalse",$<s1.strval>4,NULL,L1);
                    } T_RIGHT_PARAN T_LEFT_FLOW_PARAN {enter_scope();} stmt
                    {
                        add_quadruple("Label",NULL,NULL,L1);                    
                    } 
                    T_RIGHT_FLOW_PARAN {
                        AST_NODE *child1=$<s1.temp>4;
                        AST_NODE *child2=scope_numbering[ast_scope-1];
                        exit_scope();

                        insert_child_ast_node(scope_numbering[ast_scope-1],child2);
                        ast_scope--;
                        insert_child_ast_node(scope_numbering[ast_scope-1],child1);
                        ast_scope--;

                        add_quadruple("Label",NULL,NULL,L1);  

                    }
                    */
