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

extern int yylex();
extern int yyparse();
extern FILE *yyin;
extern int line_num;

void yyerror(const char *s);

FILE *output_file;
int indent_level = 0;
int temp_var_count = 0;

// Symbol table for variables
typedef struct {
    char *name;
    int is_string;
    int is_array;
    int dimensions;
} Variable;

Variable variables[1000];
int var_count = 0;

// Label tracking for GOTO/GOSUB
typedef struct {
    int line_num;
    int is_defined;
} Label;

Label labels[1000];
int label_count = 0;

void add_variable(const char *name, int is_string);
void add_array(const char *name, int is_string, int dimensions);
void emit_variables();
void emit_indent();
void add_label(int line_num);
void emit_goto_label(int line_num);
char* new_temp();
char* new_label();
%}

%union {
    int ival;
    double fval;
    char *sval;
    struct {
        char *code;
        int is_string;
    } expr_type;
}

%token PRINT INPUT LET IF THEN ELSE ENDIF FOR TO STEP NEXT WHILE WEND DO LOOP UNTIL END
%token DIM AS INTEGER_TYPE STRING_TYPE SINGLE_TYPE DOUBLE_TYPE
%token GOTO GOSUB RETURN
%token AND OR NOT
%token LE GE NE LT GT EQ
%token PLUS MINUS MULT DIV INTDIV MOD POW
%token LPAREN RPAREN LBRACKET RBRACKET COMMA SEMICOLON COLON NEWLINE
%token SIN COS TAN ATN SQR ABS INT RND LOG EXP
%token LEN ASC CHRS LEFTS RIGHTS MIDS STRS VAL

%token <ival> INTEGER LINE_NUMBER
%token <fval> FLOAT
%token <sval> STRING STRING_VAR IDENTIFIER

%type <sval> expr term factor variable array_access function_call
%type <ival> opt_line_number

%left OR
%left AND
%left NOT
%left EQ NE LT GT LE GE
%left PLUS MINUS
%left MULT DIV INTDIV MOD
%right POW
%right UMINUS

%%

program:
    { 
        fprintf(output_file, "#include <stdio.h>\n");
        fprintf(output_file, "#include <stdlib.h>\n");
        fprintf(output_file, "#include <string.h>\n");
        fprintf(output_file, "#include <math.h>\n\n");
        fprintf(output_file, "int main() {\n");
        indent_level++;
    }
    statements END opt_newlines
    { 
        indent_level--;
        emit_indent();
        fprintf(output_file, "return 0;\n");
        fprintf(output_file, "}\n");
    }
    ;

statements:
    /* empty */
    | statements statement
    ;

statement:
    NEWLINE
    | opt_line_number print_stmt NEWLINE
    | opt_line_number input_stmt NEWLINE
    | opt_line_number assignment NEWLINE
    | opt_line_number if_stmt
    | opt_line_number for_stmt
    | opt_line_number while_stmt
    | opt_line_number do_stmt
    | opt_line_number dim_stmt NEWLINE
    | opt_line_number goto_stmt NEWLINE
    | opt_line_number gosub_stmt NEWLINE
    | opt_line_number return_stmt NEWLINE
    ;

opt_line_number:
    /* empty */ { $$ = 0; }
    | LINE_NUMBER 
    { 
        $$ = $1; 
        add_label($1);
        emit_indent();
        fprintf(output_file, "label_%d:;\n", $1);
    }
    ;

print_stmt:
    PRINT print_list
    {
        emit_indent();
        fprintf(output_file, "printf(\"\\n\");\n");
    }
    | PRINT
    {
        emit_indent();
        fprintf(output_file, "printf(\"\\n\");\n");
    }
    ;

print_list:
    print_item
    | print_list SEMICOLON print_item
    | print_list COMMA print_item { fprintf(output_file, "    printf(\"\\t\");\n"); }
    ;

print_item:
    expr 
    { 
        emit_indent();
        fprintf(output_file, "printf(\"%%g\", (double)%s);\n", $1);
        free($1);
    }
    | STRING 
    { 
        emit_indent();
        // Escape backslashes in string literals
        char *escaped = malloc(strlen($1) * 2 + 1);
        char *src = $1;
        char *dst = escaped;
        while (*src) {
            if (*src == '\\' && src > $1 && src < $1 + strlen($1) - 1) {
                // It's a backslash inside the string (not the quotes)
                *dst++ = '\\';
                *dst++ = '\\';
                src++;
            } else {
                *dst++ = *src++;
            }
        }
        *dst = '\0';
        fprintf(output_file, "printf(\"%%s\", %s);\n", escaped);
        free(escaped);
        free($1);
    }
    | /* empty */
    ;

input_stmt:
    INPUT STRING SEMICOLON variable
    {
        add_variable($4, strchr($4, '$') != NULL);
        emit_indent();
        // Escape backslashes in string literals
        char *escaped = malloc(strlen($2) * 2 + 1);
        char *src = $2;
        char *dst = escaped;
        while (*src) {
            if (*src == '\\' && src > $2 && src < $2 + strlen($2) - 1) {
                *dst++ = '\\';
                *dst++ = '\\';
                src++;
            } else {
                *dst++ = *src++;
            }
        }
        *dst = '\0';
        fprintf(output_file, "printf(\"%%s\", %s);\n", escaped);
        free(escaped);
        emit_indent();
        if (strchr($4, '$')) {
            fprintf(output_file, "scanf(\"%%s\", %s);\n", $4);
        } else {
            fprintf(output_file, "scanf(\"%%lf\", &%s);\n", $4);
        }
        free($2);
        free($4);
    }
    | INPUT variable
    {
        add_variable($2, strchr($2, '$') != NULL);
        emit_indent();
        if (strchr($2, '$')) {
            fprintf(output_file, "scanf(\"%%s\", %s);\n", $2);
        } else {
            fprintf(output_file, "scanf(\"%%lf\", &%s);\n", $2);
        }
        free($2);
    }
    ;

assignment:
    LET variable EQ expr
    {
        add_variable($2, strchr($2, '$') != NULL);
        emit_indent();
        fprintf(output_file, "%s = %s;\n", $2, $4);
        free($2);
        free($4);
    }
    | variable EQ expr
    {
        add_variable($1, strchr($1, '$') != NULL);
        emit_indent();
        fprintf(output_file, "%s = %s;\n", $1, $3);
        free($1);
        free($3);
    }
    | LET array_access EQ expr
    {
        emit_indent();
        fprintf(output_file, "%s = %s;\n", $2, $4);
        free($2);
        free($4);
    }
    | array_access EQ expr
    {
        emit_indent();
        fprintf(output_file, "%s = %s;\n", $1, $3);
        free($1);
        free($3);
    }
    ;

if_stmt:
    IF expr THEN NEWLINE 
    {
        emit_indent();
        fprintf(output_file, "if (%s) {\n", $2);
        indent_level++;
    }
    statements ENDIF NEWLINE
    {
        indent_level--;
        emit_indent();
        fprintf(output_file, "}\n");
        free($2);
    }
    | IF expr THEN NEWLINE 
    {
        emit_indent();
        fprintf(output_file, "if (%s) {\n", $2);
        indent_level++;
    }
    statements ELSE NEWLINE 
    {
        indent_level--;
        emit_indent();
        fprintf(output_file, "} else {\n");
        indent_level++;
    }
    statements ENDIF NEWLINE
    {
        indent_level--;
        emit_indent();
        fprintf(output_file, "}\n");
        free($2);
    }
    ;

for_stmt:
    FOR variable EQ expr TO expr NEWLINE 
    {
        add_variable($2, 0);
        emit_indent();
        fprintf(output_file, "for (%s = %s; %s <= %s; %s++) {\n", 
                $2, $4, $2, $6, $2);
        indent_level++;
    }
    statements NEXT variable NEWLINE
    {
        indent_level--;
        emit_indent();
        fprintf(output_file, "}\n");
        free($2);
        free($4);
        free($6);
        free($11);
    }
    | FOR variable EQ expr TO expr STEP expr NEWLINE 
    {
        add_variable($2, 0);
        emit_indent();
        fprintf(output_file, "for (%s = %s; %s <= %s; %s += %s) {\n", 
                $2, $4, $2, $6, $2, $8);
        indent_level++;
    }
    statements NEXT variable NEWLINE
    {
        indent_level--;
        emit_indent();
        fprintf(output_file, "}\n");
        free($2);
        free($4);
        free($6);
        free($8);
        free($13);
    }
    ;

while_stmt:
    WHILE expr NEWLINE 
    {
        emit_indent();
        fprintf(output_file, "while (%s) {\n", $2);
        indent_level++;
    }
    statements WEND NEWLINE
    {
        indent_level--;
        emit_indent();
        fprintf(output_file, "}\n");
        free($2);
    }
    ;

do_stmt:
    DO NEWLINE 
    {
        emit_indent();
        fprintf(output_file, "do {\n");
        indent_level++;
    }
    statements LOOP UNTIL expr NEWLINE
    {
        indent_level--;
        emit_indent();
        fprintf(output_file, "} while (!(%s));\n", $7);
        free($7);
    }
    | DO NEWLINE 
    {
        emit_indent();
        fprintf(output_file, "do {\n");
        indent_level++;
    }
    statements LOOP WHILE expr NEWLINE
    {
        indent_level--;
        emit_indent();
        fprintf(output_file, "} while (%s);\n", $7);
        free($7);
    }
    | DO NEWLINE 
    {
        emit_indent();
        fprintf(output_file, "do {\n");
        indent_level++;
    }
    statements LOOP NEWLINE
    {
        indent_level--;
        emit_indent();
        fprintf(output_file, "} while (0);\n");
    }
    | DO UNTIL expr NEWLINE 
    {
        emit_indent();
        fprintf(output_file, "while (!(%s)) {\n", $3);
        indent_level++;
    }
    statements LOOP NEWLINE
    {
        indent_level--;
        emit_indent();
        fprintf(output_file, "}\n");
        free($3);
    }
    | DO WHILE expr NEWLINE 
    {
        emit_indent();
        fprintf(output_file, "while (%s) {\n", $3);
        indent_level++;
    }
    statements LOOP NEWLINE
    {
        indent_level--;
        emit_indent();
        fprintf(output_file, "}\n");
        free($3);
    }
    ;

goto_stmt:
    GOTO INTEGER
    {
        emit_indent();
        fprintf(output_file, "goto label_%d;\n", $2);
        add_label($2);
    }
    ;

gosub_stmt:
    GOSUB INTEGER
    {
        emit_indent();
        fprintf(output_file, "/* GOSUB not fully supported - use functions instead */\n");
        emit_indent();
        fprintf(output_file, "goto label_%d;\n", $2);
        add_label($2);
    }
    ;

return_stmt:
    RETURN
    {
        emit_indent();
        fprintf(output_file, "/* RETURN not fully supported */\n");
    }
    ;

dim_stmt:
    DIM variable LPAREN INTEGER RPAREN
    {
        add_array($2, strchr($2, '$') != NULL, 1);
        free($2);
    }
    | DIM variable LPAREN INTEGER COMMA INTEGER RPAREN
    {
        add_array($2, strchr($2, '$') != NULL, 2);
        free($2);
    }
    | DIM variable AS type
    {
        /* Simple variable declaration */
        add_variable($2, strchr($2, '$') != NULL);
        free($2);
    }
    ;

type:
    INTEGER_TYPE
    | STRING_TYPE
    | SINGLE_TYPE
    | DOUBLE_TYPE
    ;

expr:
    term { $$ = $1; }
    | expr PLUS term 
    { 
        char *temp = new_temp();
        emit_indent();
        fprintf(output_file, "double %s = %s + %s;\n", temp, $1, $3);
        free($1);
        free($3);
        $$ = temp;
    }
    | expr MINUS term 
    { 
        char *temp = new_temp();
        emit_indent();
        fprintf(output_file, "double %s = %s - %s;\n", temp, $1, $3);
        free($1);
        free($3);
        $$ = temp;
    }
    | expr LT term
    {
        char *result = malloc(256);
        snprintf(result, 256, "(%s < %s)", $1, $3);
        free($1);
        free($3);
        $$ = result;
    }
    | expr GT term
    {
        char *result = malloc(256);
        snprintf(result, 256, "(%s > %s)", $1, $3);
        free($1);
        free($3);
        $$ = result;
    }
    | expr LE term
    {
        char *result = malloc(256);
        snprintf(result, 256, "(%s <= %s)", $1, $3);
        free($1);
        free($3);
        $$ = result;
    }
    | expr GE term
    {
        char *result = malloc(256);
        snprintf(result, 256, "(%s >= %s)", $1, $3);
        free($1);
        free($3);
        $$ = result;
    }
    | expr EQ term
    {
        char *result = malloc(256);
        snprintf(result, 256, "(%s == %s)", $1, $3);
        free($1);
        free($3);
        $$ = result;
    }
    | expr NE term
    {
        char *result = malloc(256);
        snprintf(result, 256, "(%s != %s)", $1, $3);
        free($1);
        free($3);
        $$ = result;
    }
    ;

term:
    factor { $$ = $1; }
    | term MULT factor 
    { 
        char *temp = new_temp();
        emit_indent();
        fprintf(output_file, "double %s = %s * %s;\n", temp, $1, $3);
        free($1);
        free($3);
        $$ = temp;
    }
    | term DIV factor 
    { 
        char *temp = new_temp();
        emit_indent();
        fprintf(output_file, "double %s = %s / %s;\n", temp, $1, $3);
        free($1);
        free($3);
        $$ = temp;
    }
    | term INTDIV factor 
    { 
        char *temp = new_temp();
        emit_indent();
        fprintf(output_file, "int %s = (int)%s / (int)%s;\n", temp, $1, $3);
        free($1);
        free($3);
        $$ = temp;
    }
    | term MOD factor 
    { 
        char *temp = new_temp();
        emit_indent();
        fprintf(output_file, "int %s = (int)%s %% (int)%s;\n", temp, $1, $3);
        free($1);
        free($3);
        $$ = temp;
    }
    | term POW factor 
    { 
        char *temp = new_temp();
        emit_indent();
        fprintf(output_file, "double %s = pow(%s, %s);\n", temp, $1, $3);
        free($1);
        free($3);
        $$ = temp;
    }
    ;

factor:
    INTEGER 
    { 
        char buf[32];
        snprintf(buf, sizeof(buf), "%d", $1);
        $$ = strdup(buf);
    }
    | FLOAT 
    { 
        char buf[32];
        snprintf(buf, sizeof(buf), "%g", $1);
        $$ = strdup(buf);
    }
    | variable { $$ = $1; }
    | array_access { $$ = $1; }
    | function_call { $$ = $1; }
    | STRING { $$ = $1; }
    | LPAREN expr RPAREN { $$ = $2; }
    | MINUS factor %prec UMINUS
    {
        char *temp = new_temp();
        emit_indent();
        fprintf(output_file, "double %s = -%s;\n", temp, $2);
        free($2);
        $$ = temp;
    }
    ;

array_access:
    IDENTIFIER LPAREN expr RPAREN
    {
        char *result = malloc(256);
        snprintf(result, 256, "%s[(int)%s]", $1, $3);
        free($1);
        free($3);
        $$ = result;
    }
    | IDENTIFIER LPAREN expr COMMA expr RPAREN
    {
        /* For 2D arrays, we'll use simple linear indexing */
        char *result = malloc(256);
        snprintf(result, 256, "%s[(int)%s * 100 + (int)%s]", $1, $3, $5);
        free($1);
        free($3);
        free($5);
        $$ = result;
    }
    ;

function_call:
    SIN LPAREN expr RPAREN
    {
        char *result = malloc(256);
        snprintf(result, 256, "sin(%s)", $3);
        free($3);
        $$ = result;
    }
    | COS LPAREN expr RPAREN
    {
        char *result = malloc(256);
        snprintf(result, 256, "cos(%s)", $3);
        free($3);
        $$ = result;
    }
    | TAN LPAREN expr RPAREN
    {
        char *result = malloc(256);
        snprintf(result, 256, "tan(%s)", $3);
        free($3);
        $$ = result;
    }
    | ATN LPAREN expr RPAREN
    {
        char *result = malloc(256);
        snprintf(result, 256, "atan(%s)", $3);
        free($3);
        $$ = result;
    }
    | SQR LPAREN expr RPAREN
    {
        char *result = malloc(256);
        snprintf(result, 256, "sqrt(%s)", $3);
        free($3);
        $$ = result;
    }
    | ABS LPAREN expr RPAREN
    {
        char *result = malloc(256);
        snprintf(result, 256, "fabs(%s)", $3);
        free($3);
        $$ = result;
    }
    | INT LPAREN expr RPAREN
    {
        char *result = malloc(256);
        snprintf(result, 256, "floor(%s)", $3);
        free($3);
        $$ = result;
    }
    | RND LPAREN expr RPAREN
    {
        char *result = malloc(256);
        snprintf(result, 256, "((double)rand() / RAND_MAX)");
        free($3);
        $$ = result;
    }
    | RND
    {
        char *result = malloc(256);
        snprintf(result, 256, "((double)rand() / RAND_MAX)");
        $$ = result;
    }
    | LOG LPAREN expr RPAREN
    {
        char *result = malloc(256);
        snprintf(result, 256, "log(%s)", $3);
        free($3);
        $$ = result;
    }
    | EXP LPAREN expr RPAREN
    {
        char *result = malloc(256);
        snprintf(result, 256, "exp(%s)", $3);
        free($3);
        $$ = result;
    }
    | LEN LPAREN expr RPAREN
    {
        char *result = malloc(256);
        snprintf(result, 256, "strlen(%s)", $3);
        free($3);
        $$ = result;
    }
    ;

variable:
    IDENTIFIER { $$ = $1; }
    | STRING_VAR { $$ = $1; }
    ;

opt_newlines:
    /* empty */
    | opt_newlines NEWLINE
    ;

%%

void add_variable(const char *name, int is_string) {
    // Check if variable already exists
    for (int i = 0; i < var_count; i++) {
        if (strcmp(variables[i].name, name) == 0) {
            return; // Already declared
        }
    }
    
    // Add new variable
    variables[var_count].name = strdup(name);
    variables[var_count].is_string = is_string;
    variables[var_count].is_array = 0;
    variables[var_count].dimensions = 0;
    var_count++;
    
    // Emit declaration
    emit_indent();
    if (is_string) {
        fprintf(output_file, "char %s[256] = \"\";\n", name);
    } else {
        fprintf(output_file, "double %s = 0;\n", name);
    }
}

void add_array(const char *name, int is_string, int dimensions) {
    // Check if already exists
    for (int i = 0; i < var_count; i++) {
        if (strcmp(variables[i].name, name) == 0) {
            return;
        }
    }
    
    // Add new array
    variables[var_count].name = strdup(name);
    variables[var_count].is_string = is_string;
    variables[var_count].is_array = 1;
    variables[var_count].dimensions = dimensions;
    var_count++;
    
    // Emit declaration
    emit_indent();
    if (dimensions == 1) {
        if (is_string) {
            fprintf(output_file, "char %s[1000][256];\n", name);
        } else {
            fprintf(output_file, "double %s[1000];\n", name);
        }
    } else if (dimensions == 2) {
        if (is_string) {
            fprintf(output_file, "char %s[10000][256];\n", name);
        } else {
            fprintf(output_file, "double %s[10000];\n", name);
        }
    }
}

void add_label(int line_num) {
    // Check if label already exists
    for (int i = 0; i < label_count; i++) {
        if (labels[i].line_num == line_num) {
            labels[i].is_defined = 1;
            return;
        }
    }
    
    // Add new label
    labels[label_count].line_num = line_num;
    labels[label_count].is_defined = 0;
    label_count++;
}

void emit_indent() {
    for (int i = 0; i < indent_level; i++) {
        fprintf(output_file, "    ");
    }
}

char* new_temp() {
    char *temp = malloc(32);
    snprintf(temp, 32, "temp_%d", temp_var_count++);
    return temp;
}

char* new_label() {
    char *label = malloc(32);
    snprintf(label, 32, "label_%d", label_count++);
    return label;
}

void yyerror(const char *s) {
    fprintf(stderr, "Error at line %d: %s\n", line_num, s);
}

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <input.bas> [output.c]\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror(argv[1]);
        return 1;
    }

    const char *output_filename = argc > 2 ? argv[2] : "output.c";
    output_file = fopen(output_filename, "w");
    if (!output_file) {
        perror(output_filename);
        fclose(yyin);
        return 1;
    }

    int result = yyparse();

    fclose(yyin);
    fclose(output_file);

    if (result == 0) {
        printf("Compilation successful! Output written to %s\n", output_filename);
    }

    return result;
}
