%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "lexer.h"

void yyerror(const char *msg);
%}

%code {
void printWithLineNo(const char* format, ...) {
    va_list args;
    va_start(args, format);
    printf("%d: ", yylineno);
    vprintf(format, args);
    va_end(args);
}
}

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
program: include_statement main_func { printWithLineNo("End of program.\n"); }
       ;

include_statement: INCLUDE STDIO_H { printWithLineNo("%Include Statement.\n"); }
            ;

main_func: INT MAIN L_PAREN R_PAREN L_BRACE statement_list R_BRACE { printWithLineNo("Main Statement.\n"); }
         ;

statement_list: statement { printWithLineNo("Statement\n"); }
              | statement_list statement { printWithLineNo("Statement\n"); }
              | error_statement { printWithLineNo("Error: Invalid statement\n"); yyerrok; }
              ;

error_statement: error SEMICOLON { printWithLineNo("Error statement\n"); }
               | error '\n' { printWithLineNo("Error statement\n"); yyerrok; }
               ;

statement: if_else_statement
         | RETURN expression SEMICOLON { printWithLineNo("Return statement\n"); }
         | PRINTF L_PAREN expression_list R_PAREN SEMICOLON { printWithLineNo("Printf statement\n"); }
         | SCANF L_PAREN expression_list R_PAREN SEMICOLON { printWithLineNo("Scanf statement\n"); }
         | declaration SEMICOLON { printWithLineNo("Declaration\n"); }
         | assignment SEMICOLON { printWithLineNo("Assignment\n"); } 
         ;


if_statement:
            IF L_PAREN expression R_PAREN L_BRACE statement_list R_BRACE { printWithLineNo("IF statement\n"); }

if_else_if_statement: if_statement ELSE IF L_PAREN expression R_PAREN L_BRACE statement_list R_BRACE { printWithLineNo("IF-ELSE-IF statement\n"); }
                    | if_else_if_statement ELSE IF L_PAREN expression R_PAREN L_BRACE statement_list R_BRACE { printWithLineNo("IF-ELSE-IF statement\n"); }
                    ;

if_else_statement: if_statement ELSE L_BRACE statement_list R_BRACE { printWithLineNo("IF-ELSE statement\n"); }
                 | if_else_if_statement ELSE L_BRACE statement_list R_BRACE { printWithLineNo("IF-ELSE-IF-ELSE statement\n"); }
                 ;

assignment: IDENTIFIER EQUAL expression { printWithLineNo("Assignment: %s\n", $1); }
          ;

declaration: type identifier_list { printWithLineNo("Declaration\n"); }
           ;

type: INT { printWithLineNo("Type: int\n"); }
    | CHAR { prprintWithLineNointf("Type: char\n"); }
    ;

identifier_list: IDENTIFIER { printWithLineNo("Identifier: %s\n", $1); }
               | identifier_list COMMA IDENTIFIER { printWithLineNo("Identifier: %s\n", $3); }
               ;

expression_list: expression { printWithLineNo("Expression\n"); }
                | expression_list COMMA expression { printWithLineNo("Expression\n"); }
                ;

expression: NUMBER { printWithLineNo("Number: %i\n", $1); }
          | IDENTIFIER { printWithLineNo("Identifier: %s\n", $1); }
          | STRING { printWithLineNo("STRING: %s\n", $1); }
          | POINTER { printWithLineNo("STRING: %s\n", $1); }
          | expression GREATER_THAN expression { printWithLineNo("Greater-than expression\n"); }
          | expression LESS_THAN expression { printWithLineNo("Less-than expression\n"); }
          | expression DOUBLE_EQUAL expression { printWithLineNo("Equal expression\n"); }
          | expression NOT_EQUAL expression { printWithLineNo("Not equal expression\n"); }
          | expression PLUS expression { printWithLineNo("Addition expression\n"); }
          | expression MINUS expression { printWithLineNo("Subtraction expression\n"); }
          | expression MULT expression { printWithLineNo("Multiplication expression\n"); }
          | expression DIV expression { printWithLineNo("Division expression\n"); }
          | L_PAREN expression R_PAREN { printWithLineNo("Parenthesized expression\n"); }
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