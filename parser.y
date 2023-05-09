%{
#include <stdio.h>
#include <stdlib.h>
#include "lexer.h"

void yyerror(const char *msg);
%}

%union {
    int dval;
    char* sval;
}

%define parse.error verbose
%locations

%token <dval> NUMBER
%token <sval> IDENTIFIER
%token <sval> STRING
%token <sval> POINTER
%token IF ELSE RETURN MINUS PLUS MULT DIV EQUAL
%token L_PAREN R_PAREN L_BRACE R_BRACE SEMICOLON
%token INT CHAR PRINTF SCANF INCLUDE STDIO_H COMMA MAIN
%token GREATER_THAN LESS_THAN DOUBLE_EQUAL NOT_EQUAL

%left MULT DIV
%left MINUS PLUS

%start program

%%
program: include_statement main_func { printf("Input is valid.\n"); }
       ;

include_statement: INCLUDE STDIO_H { printf("%Include Statement.\n"); }
            ;

main_func: INT MAIN L_PAREN R_PAREN L_BRACE statement_list R_BRACE { printf("Main Function.\n"); }
         ;

statement_list: statement { printf("Statement\n"); }
              | statement_list statement { printf("Statement\n"); }
              | error '\n' { yyerrok; /* 繼續解析 */ }
              | error { yyerrok; /* 繼續解析 */ }
              ;

statement: if_else_statement
         | RETURN expression SEMICOLON { printf("Return statement\n"); }
         | PRINTF L_PAREN expression_list R_PAREN SEMICOLON { printf("Printf statement\n"); }
         | SCANF L_PAREN expression_list R_PAREN SEMICOLON { printf("Scanf statement\n"); }
         | declaration SEMICOLON { printf("Declaration\n"); }
         | assignment SEMICOLON { printf("Assignment\n"); } 
         ;


if_statement:
            IF L_PAREN expression R_PAREN L_BRACE statement_list R_BRACE { printf("IF statement\n"); }

if_else_if_statement: if_statement ELSE IF L_PAREN expression R_PAREN L_BRACE statement_list R_BRACE { printf("IF-ELSE-IF statement\n"); }
                    | if_else_if_statement ELSE IF L_PAREN expression R_PAREN L_BRACE statement_list R_BRACE { printf("IF-ELSE-IF statement\n"); }
                    ;

if_else_statement: if_statement ELSE L_BRACE statement_list R_BRACE { printf("IF-ELSE statement\n"); }
                 | if_else_if_statement ELSE L_BRACE statement_list R_BRACE { printf("IF-ELSE-IF-ELSE statement\n"); }
                 ;

assignment: IDENTIFIER EQUAL expression { printf("Assignment: %s\n", $1); }
          ;

declaration: type identifier_list { printf("Declaration\n"); }
           ;

type: INT { printf("Type: int\n"); }
    | CHAR { printf("Type: char\n"); }
    ;

identifier_list: IDENTIFIER { printf("Identifier: %s\n", $1); }
               | identifier_list COMMA IDENTIFIER { printf("Identifier: %s\n", $3); }
               ;

expression_list: expression { printf("Expression\n"); }
                | expression_list COMMA expression { printf("Expression\n"); }
                ;

expression: NUMBER { printf("Number: %i\n", $1); }
          | IDENTIFIER { printf("Identifier: %s\n", $1); }
          | STRING { printf("STRING: %s\n", $1); }
          | POINTER { printf("STRING: %s\n", $1); }
          | expression GREATER_THAN expression { printf("Greater-than expression\n"); }
          | expression LESS_THAN expression { printf("Less-than expression\n"); }
          | expression DOUBLE_EQUAL expression { printf("Equal expression\n"); }
          | expression NOT_EQUAL expression { printf("Not equal expression\n"); }
          | expression PLUS expression { printf("Addition expression\n"); }
          | expression MINUS expression { printf("Subtraction expression\n"); }
          | expression MULT expression { printf("Multiplication expression\n"); }
          | expression DIV expression { printf("Division expression\n"); }
          | L_PAREN expression R_PAREN { printf("Parenthesized expression\n"); }
          ;

%%

int main(int argc, char** argv) {
    if (argc < 2) {
        printf("Usage: %s input_file\n", argv[0]);
        return 1;
    }

    FILE* file = fopen(argv[1], "r");
    if (!file) {
        perror("Error opening file");
        return 1;
    }

    yyin = file;
    yyparse();

    fclose(file);
    return 0;
}

//TODO 需要再錯誤發生時，印出錯誤的行數，在繼續判斷錯誤
void yyerror(const char *msg) {
   printf("** Line %d: %s\n", yylloc.first_line, msg);
}