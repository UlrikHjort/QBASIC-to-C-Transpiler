REM Working features demo
PRINT "QBASIC Transpiler Demo"
PRINT

REM Test operators
a = 17
b = 5
PRINT "17 MOD 5 =", a MOD b
PRINT "17 \ 5 =", a \ b
PRINT "2 ^ 8 =", 2 ^ 8
PRINT

REM Test math functions
PRINT "SQR(16) =", SQR(16)
PRINT "ABS(-7) =", ABS(-7)
PRINT "INT(3.9) =", INT(3.9)
PRINT

REM Test FOR loop
PRINT "Counting:"
FOR i = 1 TO 5
    PRINT i;
NEXT i
PRINT
PRINT

REM Test arrays
DIM values(5)
PRINT "Filling array:"
FOR i = 1 TO 5
    values(i) = i * 10
    PRINT values(i);
NEXT i
PRINT
PRINT

REM Test IF
x = 15
IF x > 10 THEN
    PRINT "x is greater than 10"
END IF

IF x < 20 THEN
    PRINT "x is less than 20"
END IF
PRINT

REM Test GOTO
PRINT "Before GOTO"
GOTO 100
PRINT "This is skipped"
100 PRINT "After GOTO"

PRINT
PRINT "Demo complete!"
END
