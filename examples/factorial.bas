REM Factorial calculator
PRINT "Factorial Calculator"
PRINT "Enter a number:"
INPUT n

LET result = 1
FOR i = 1 TO n
    result = result * i
NEXT i

PRINT "Factorial of", n, "is", result

END
