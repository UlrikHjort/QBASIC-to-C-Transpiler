REM Fibonacci sequence generator
PRINT "Fibonacci Sequence Generator"
PRINT "How many terms?"
INPUT n

PRINT "First", n, "Fibonacci numbers:"

a = 0
b = 1
count = 1

REM Print first term
PRINT a;

REM Print remaining terms
DO WHILE count < n
    PRINT b;
    temp = a + b
    a = b
    b = temp
    count = count + 1
LOOP

PRINT
PRINT "Done!"

END
