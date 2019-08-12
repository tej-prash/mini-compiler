%{

    #include<stdio.h>
    
    #ifndef _HEADER_H
    #define _HEADER_H

    #include "while_java.h"

    #endif

    #include "y.tab.h"
    #define YY_USER_ACTION \
        yylloc.first_line = yylloc.last_line; \
        yylloc.first_column = yylloc.last_column; \
        for(int i = 0; yytext[i] != '\0'; i++) { \
            if(yytext[i] == '\n') { \
                yylloc.last_line++; \
                yylloc.last_column = 0; \
            } \
            else { \
                yylloc.last_column++; \
            } \
        }
    extern YYSTYPE yylval;
    //extern struct symbol_table;
    extern struct symbol_table *t=NULL;
    extern int flag_dtype;
    extern char d_type[10];
    extern char id_name[32];
    extern char current_level[100];
    extern int current_level_length;
    extern int previous_level;


%}


%%
import    {fprintf(stdout,"%s","import\n");return(T_IMPORT);}
(public|private|protected)     {fprintf(stdout,"%s","T_ACCESS_SPECIFIER\n");return T_ACCESS_SPECIFIER;}
static      {fprintf(stdout,"%s","T_STATIC\n");return(T_STATIC);}
main    {fprintf(stdout,"%s","T_MAIN\n");return(T_MAIN);}
"[|]"     {fprintf(stdout,"%s","T_BITOR\n");return T_BITOR;}
"while"    {fprintf(stdout,"%s","T_WHILE\n");return T_WHILE;}
"if"           {fprintf(stdout,"%s","T_IF\n");return T_IF;}
"else"      {fprintf(stdout,"%s","T_ELSE\n");return T_ELSE;}
"void"          {fprintf(stdout,"%s","T_VOID\n");return T_VOID;}

class {fprintf(stdout,"%s","T_CLASS\n");return T_CLASS;}
true {fprintf(stdout,"%s","T_TRUE\n");strcpy(yylval.s1.strval,yytext);return T_TRUE;}
false {fprintf(stdout,"%s","T_FALSE\n");strcpy(yylval.s1.strval,yytext);return T_FALSE;}

(int|float|char|boolean|short|long|double|byte|String)  {fprintf(stdout,"%s","T_DTYPE\n"); strcpy(d_type,yytext);strcpy(yylval.strval,yytext);flag_dtype=1; return(T_DTYPE);}
[a-zA-Z_]([a-zA-Z0-9_])*        {  fprintf(stdout,"%s","T_ID\n"); strcpy(yylval.s1.strval,yytext); printf("%s\n",yylval.s1.strval);return(T_ID);}


(0|1|2|3|4|5|6|7|8|9)+   {printf("T_DIGIT\n");strcpy(yylval.s1.strval,yytext); yylval.s1.intval=atoi(yylval.s1.strval);printf("intval %d\n",yylval.s1.intval);printf("strval %s\n",yylval.s1.strval);return(T_DIGIT);}
(0|1|2|3|4|5|6|7|8|9)+\.(0|1|2|3|4|5|6|7|8|9)+  {printf("T_DECIMAL");strcpy(yylval.s1.strval,yytext);return T_DECIMAL;}
"\'"([a-zA-Z0-9])"\'" {printf("T_CHARACTER\n");strcpy(yylval.s1.strval,yytext);yylval.s1.ch=yytext[0];return T_CHARACTER;}


"\("   {fprintf(stdout,"%s","T_LEFT_PARAN\n");return(T_LEFT_PARAN);}
"\)"   {fprintf(stdout,"%s","T_RIGHT_PARAN\n");return(T_RIGHT_PARAN);}
"\{"    {fprintf(stdout,"%s","T_LEFT_FLOW_PARAN\n");return(T_LEFT_FLOW_PARAN);}
"\}"    {fprintf(stdout,"%s","T_RIGHT_FLOW_PARAN\n");return(T_RIGHT_FLOW_PARAN);}
";"    {fprintf(stdout,"%s","T_SEMICOLON\n");return(T_SEMICOLON);}
"\."     {fprintf(stdout,"%s","T_DOT\n");return(T_DOT);}
"["     {fprintf(stdout,"%s","T_LEFT_BRACKET\n");return(T_LEFT_BRACKET);}
"]"     {fprintf(stdout,"%s","T_RIGHT_BRACKET\n");return(T_RIGHT_BRACKET);}

"=="   {fprintf(stdout,"%s","T_DOUBLE_EQUALTO\n");return T_DOUBLE_EQUALTO;}
"!="   {fprintf(stdout,"%s","T_NOT_EQUALTO\n");return T_NOT_EQUALTO;}
"!"     {fprintf(stdout,"%s","T_LNOT\n");return T_LNOT;}
"<="  {fprintf(stdout,"%s","T_LESS_EQUALTO\n");return T_LESS_EQUALTO;}
">="  {fprintf(stdout,"%s","T_GREATER_EQUALTO\n");return T_GREATER_EQUALTO;}
"++"    {fprintf(stdout,"%s","T_INCREMENT\n");return(T_INCREMENT);}
"--"      {fprintf(stdout,"%s","T_DECREMENT\n");return T_DECREMENT;}
"+="   {fprintf(stdout,"%s","T_ADD_SHORT\n");return T_ADD_SHORT;}
"-="    {fprintf(stdout,"%s","T_SUB_SHORT\n");return T_SUB_SHORT;}
"*="    {fprintf(stdout,"%s","T_MUL_SHORT\n");return T_MUL_SHORT;}
"/="    {fprintf(stdout,"%s","T_DIV_SHORT\n");return T_DIV_SHORT;}
"%="   {fprintf(stdout,"%s","T_MOD_SHORT\n");return T_MOD_SHORT;}
"\^"       {fprintf(stdout,"%s","T_XOR\n");return T_XOR;}
"<<"   {fprintf(stdout,"%s","T_BIT_LEFT_SHIFT\n");return T_BIT_LEFT_SHIFT;}
">>"   {fprintf(stdout,"%s","T_BIT_RIGHT_SHIFT\n");return T_BIT_RIGHT_SHIFT;}
"<"     {fprintf(stdout,"%s","T_LESSTHAN\n");return T_LESSTHAN;}
">"     {fprintf(stdout,"%s","T_GREATERTHAN\n");return T_GREATERTHAN;}
"="     {fprintf(stdout,"%s","T_EQUALTO\n");return T_EQUALTO;}
"\\n"    {fprintf(stdout,"%s","T_NEWLINE\n");return T_NEWLINE;}
"\+"     {fprintf(stdout,"%s","T_PLUS\n");return T_PLUS;}
"-"     {fprintf(stdout,"%s","T_MINUS\n");return T_MINUS;}
"\*"     {fprintf(stdout,"%s","T_MUL\n");return T_MUL;}
"/"     {fprintf(stdout,"%s","T_DIV\n");return T_DIV;}

[&][&]     {fprintf(stdout,"%s","T_LAND\n");return T_LAND;}
[|][|]    {fprintf(stdout,"%s","T_LOR\n");return T_LOR;}
"&"   {fprintf(stdout,"%s","T_BITAND\n");return T_BITAND;}

"%"   {fprintf(stdout,"%s","T_MOD\n");return T_MOD;}
"\'"  {fprintf(stdout,"%s","T_SQUOTE\n");return T_SQUOTE;}
"\,"     {fprintf(stdout,"%s","T_COMMA\n");return T_COMMA;}
'\"'           {return T_QUOTE;}
