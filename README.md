# QBASIC to C Transpiler

A transpiler that translates **[QBASIC](https://en.wikipedia.org/wiki/QBasic)** programs to C code, built with Flex and Bison. I started this project back in the 1990 but never completed it. Far from complete and will never be more complete than this. 


## Quick Start

```bash
# Build the transpiler
make

# Compile a QBASIC program
bin/qb2c examples/fibonacci.bas output/fibonacci.c
gcc -o output/fibonacci output/fibonacci.c -lm
echo "10" | ./output/fibonacci

# Run all tests
make test-all
```

## Supported Features

### Basic I/O
- `PRINT` - Output text and numbers (supports semicolons and commas)
- `INPUT` - Read user input

### Variables
- Numeric variables (double precision)
- String variables (name ends with `$`)
- Automatic declaration

### Arrays
- 1D arrays: `DIM array(size)`
- 2D arrays: `DIM array(rows, cols)`
- Array access: `array(index)` or `array(i, j)`

### Operators
- Arithmetic: `+`, `-`, `*`, `/`, `\` (integer division), `MOD`, `^` (power)
- Comparison: `<`, `>`, `<=`, `>=`, `=`, `<>`
- Logical: `AND`, `OR`, `NOT`

### Control Structures
- `IF...THEN...ELSE...END IF`
- `FOR...TO...STEP...NEXT`
- `WHILE...WEND`
- `DO WHILE condition...LOOP` 
- `DO UNTIL condition...LOOP` 
- `DO...LOOP UNTIL condition` 
- `GOTO` with line numbers

### Built-in Functions
- **Math**: `SIN()`, `COS()`, `TAN()`, `ATN()`, `SQR()`, `ABS()`, `INT()`, `LOG()`, `EXP()`, `RND`
- **String**: `LEN()` (partial support)

### Comments
- `REM` - Comment lines

### Line Numbers
- Optional line numbers (e.g., `10 PRINT "Hello"`)
- Used with `GOTO`

## Known Limitations

- `GOSUB`/`RETURN` not fully supported
- String operations limited
- No file I/O
- No user-defined functions/procedures

## Example Programs

- **Algorithms**: Fibonacci, prime checker, GCD, bubble sort
- **Utilities**: Calculator, temperature converter, multiplication table
- **Demos**: Feature showcase, factorial, sum of digits

## Requirements

**[Bison](https://en.wikipedia.org/wiki/GNU_Bison)** (or Yacc)

**[Flex](https://en.wikipedia.org/wiki/Flex_(lexical_analyzer_generator))**
(or lex)

C compiler
