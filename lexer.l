%{
#include "parser.h"
#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno;
int current_line = 1;
%}

%option noyywrap

DIGIT    [0-9]
LETTER   [a-zA-Z]

%%

[ \t]+         {/* 忽略空格和制表符 */}
[\r\n]         {current_line++;}

"if"           {return IF;}
"else"         {return ELSE;}
"return"       {return RETURN;}

">"           { return GREATER_THAN; }
"<"           { return LESS_THAN; }
"=="          { return DOUBLE_EQUAL; }
"!="          { return NOT_EQUAL; }

"-"            {return MINUS;}
"+"            {return PLUS;}
"*"            {return MULT;}
"/"            {return DIV;}
"="            {return EQUAL;}

"("            {return L_PAREN;}
")"            {return R_PAREN;}
"{"            {return L_BRACE;}
"}"            {return R_BRACE;}
";"            {return SEMICOLON;}
","            {return COMMA;}

int            {return INT;}
char           {return CHAR;}
printf         {return PRINTF;}
scanf          {return SCANF;}
#include       {return INCLUDE;}
main           {return MAIN;}

"<stdio.h>"    {return STDIO_H;}

{DIGIT}+       {yylval.dval = atof(yytext); return NUMBER;}
{LETTER}([_a-zA-Z0-9])*   {yylval.sval = strdup(yytext); return IDENTIFIER;}

\"[^\"\n]*\"   { yylval.sval = strdup(yytext); return STRING; }
"&"([a-zA-Z_][a-zA-Z0-9_]*)   { yylval.sval = strdup(yytext); return POINTER; }

.              {printf("Error at line %d: unrecognized symbol \"%s\"\n", current_line, yytext); exit(0);}

%%
