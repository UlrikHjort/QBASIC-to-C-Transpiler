REM Multiplication table generator
PRINT "Multiplication Table"
PRINT "Enter a number:"
INPUT n

PRINT "Multiplication table for", n, ":"
PRINT

FOR i = 1 TO 10
    result = n * i
    PRINT n, "x", i, "=", result
NEXT i

END
