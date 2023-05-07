/* calculator. */
%{
 #include <stdio.h>
 #include <stdlib.h>
 #include "lexer.h"
 void yyerror(const char *msg);

 // Here is an example how to create custom data structure
 typedef struct custom_data {
    char* name;
    int counter;
 } custom_data;

%}

%union{
  double dval;
  int ival;
  struct custom_data* cval; // define the pointer type for custom data structure
}

%error-verbose
%locations

%start input
%token MULT DIV PLUS MINUS EQUAL L_PAREN R_PAREN END
%token <dval> NUMBER
%type <dval> exp
%type <cval> input
%left PLUS MINUS
%left MULT DIV
%nonassoc UMINUS


%% 
input:	{ $$ = malloc(sizeof(custom_data)); $$->name = "input"; $$->counter = 0; }
			| input line { $$ = $1; $1->counter++; }
			;

line:		exp EQUAL END         { printf("\t%f\n", $1);}
			;

exp:		NUMBER                { $$ = $1; }
			| exp PLUS exp        { $$ = $1 + $3; }
			| exp MINUS exp       { $$ = $1 - $3; }
			| exp MULT exp        { $$ = $1 * $3; }
			| exp DIV exp         { if ($3==0) yyerror("divide by zero"); else $$ = $1 / $3; }
			| MINUS exp %prec UMINUS { $$ = -$2; }
			| L_PAREN exp R_PAREN { $$ = $2; }
			;
%%

int main(int argc, char **argv) {
   if (argc > 1) {
      yyin = fopen(argv[1], "r");
      if (yyin == NULL){
         printf("syntax: %s filename\n", argv[0]);
      }//end if
   }//end if
   yyparse(); // Calls yylex() for tokens.
   return 0;
}

void yyerror(const char *msg) {
   printf("** Line %d: %s\n", yylloc.first_line, msg);
}
