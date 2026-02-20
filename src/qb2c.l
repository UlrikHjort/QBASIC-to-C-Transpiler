/***************************************************************************
--                     Qbasic to C transpiler
--
--           Copyright (C) 2026 By Ulrik Hørlyk Hjort
--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
-- LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
-- OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
-- WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
-- ***************************************************************************/
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "qb2c.tab.h"

int line_num = 1;
%}

%option noyywrap
%option case-insensitive

%%

"REM".*             { /* ignore comments */ }
"PRINT"             { return PRINT; }
"INPUT"             { return INPUT; }
"LET"               { return LET; }
"IF"                { return IF; }
"THEN"              { return THEN; }
"ELSE"              { return ELSE; }
"END IF"            { return ENDIF; }
"FOR"               { return FOR; }
"TO"                { return TO; }
"STEP"              { return STEP; }
"NEXT"              { return NEXT; }
"WHILE"             { return WHILE; }
"WEND"              { return WEND; }
"DO"                { return DO; }
"LOOP"              { return LOOP; }
"UNTIL"             { return UNTIL; }
"END"               { return END; }
"DIM"               { return DIM; }
"AS"                { return AS; }
"INTEGER"           { return INTEGER_TYPE; }
"STRING"            { return STRING_TYPE; }
"SINGLE"            { return SINGLE_TYPE; }
"DOUBLE"            { return DOUBLE_TYPE; }
"GOTO"              { return GOTO; }
"GOSUB"             { return GOSUB; }
"RETURN"            { return RETURN; }

"SIN"               { return SIN; }
"COS"               { return COS; }
"TAN"               { return TAN; }
"ATN"               { return ATN; }
"SQR"               { return SQR; }
"ABS"               { return ABS; }
"INT"               { return INT; }
"RND"               { return RND; }
"LOG"               { return LOG; }
"EXP"               { return EXP; }
"LEN"               { return LEN; }
"ASC"               { return ASC; }
"CHR$"              { return CHRS; }
"LEFT$"             { return LEFTS; }
"RIGHT$"            { return RIGHTS; }
"MID$"              { return MIDS; }
"STR$"              { return STRS; }
"VAL"               { return VAL; }

"AND"               { return AND; }
"OR"                { return OR; }
"NOT"               { return NOT; }

"<="                { return LE; }
">="                { return GE; }
"<>"                { return NE; }
"<"                 { return LT; }
">"                 { return GT; }
"="                 { return EQ; }

"+"                 { return PLUS; }
"-"                 { return MINUS; }
"*"                 { return MULT; }
"/"                 { return DIV; }
"\\"                { return INTDIV; }
"MOD"               { return MOD; }
"^"                 { return POW; }

"("                 { return LPAREN; }
")"                 { return RPAREN; }
"["                 { return LBRACKET; }
"]"                 { return RBRACKET; }
","                 { return COMMA; }
";"                 { return SEMICOLON; }
":"                 { return COLON; }

^[ \t]*[0-9]+       { yylval.ival = atoi(yytext); return LINE_NUMBER; }
[0-9]+              { yylval.ival = atoi(yytext); return INTEGER; }
[0-9]*\.[0-9]+      { yylval.fval = atof(yytext); return FLOAT; }
\"[^\"]*\"          { 
                      yylval.sval = strdup(yytext); 
                      return STRING; 
                    }

[A-Za-z][A-Za-z0-9_]*\$ { 
                      yylval.sval = strdup(yytext); 
                      return STRING_VAR; 
                    }
[A-Za-z][A-Za-z0-9_]* { 
                      yylval.sval = strdup(yytext); 
                      return IDENTIFIER; 
                    }

[ \t]+              { /* ignore whitespace */ }
\n                  { line_num++; return NEWLINE; }
\r\n                { line_num++; return NEWLINE; }

.                   { fprintf(stderr, "Unknown character: %s\n", yytext); }

%%
