REM Test array support
DIM numbers(10)
DIM names$(5)

PRINT "Filling array with squares"
FOR i = 1 TO 10
    numbers(i) = i * i
NEXT i

PRINT "Array contents:"
FOR i = 1 TO 10
    PRINT "numbers(", i, ") =", numbers(i)
NEXT i

PRINT "Sum of array:"
sum = 0
FOR i = 1 TO 10
    sum = sum + numbers(i)
NEXT i
PRINT "Total:", sum

END
