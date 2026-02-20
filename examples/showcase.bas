REM QBASIC TRanspiler Feature Showcase
REM Demonstrates all working features

PRINT "=== QBASIC to C Transpiler Demo ==="
PRINT

REM === Variables and Arithmetic ===
PRINT "1. Basic Arithmetic"
a = 10
b = 3
PRINT "a =", a, "b =", b
PRINT "a + b =", a + b
PRINT "a - b =", a - b
PRINT "a * b =", a * b
PRINT "a / b =", a / b
PRINT "a \ b =", a \ b
PRINT "a MOD b =", a MOD b
PRINT "a ^ b =", a ^ b
PRINT

REM === Math Functions ===
PRINT "2. Math Functions"
x = 3.14159
PRINT "x =", x
PRINT "SIN(x) =", SIN(x)
PRINT "COS(x) =", COS(x)
PRINT "SQR(x) =", SQR(x)
PRINT "ABS(-5.5) =", ABS(-5.5)
PRINT "INT(3.7) =", INT(3.7)
PRINT

REM === Loops ===
PRINT "3. FOR Loop"
FOR i = 1 TO 5
    PRINT "i =", i
NEXT i
PRINT

PRINT "4. WHILE Loop"
count = 0
WHILE count < 3
    PRINT "count =", count
    count = count + 1
WEND
PRINT

REM === Arrays ===
PRINT "5. Arrays"
DIM nums(5)
FOR i = 1 TO 5
    nums(i) = i * 2
NEXT i

PRINT "Array contents:"
FOR i = 1 TO 5
    PRINT "nums(", i, ") =", nums(i)
NEXT i
PRINT

REM === Conditionals ===
PRINT "6. IF/THEN/ELSE"
score = 85
IF score >= 90 THEN
    PRINT "Grade: A"
ELSE
    IF score >= 80 THEN
        PRINT "Grade: B"
    ELSE
        PRINT "Grade: C"
    END IF
END IF
PRINT

REM === GOTO and Labels ===
PRINT "7. GOTO and Line Numbers"
counter = 1
100 PRINT "Loop iteration:", counter
    counter = counter + 1
    IF counter <= 3 THEN
        GOTO 100
    END IF
PRINT

PRINT "=== Demo Complete ==="
END
