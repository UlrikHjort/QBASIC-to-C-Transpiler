REM Greatest Common Divisor (GCD) using Euclidean algorithm
PRINT "GCD Calculator"
PRINT "Enter first number:"
INPUT a
PRINT "Enter second number:"
INPUT b

REM Store originals for display
original_a = a
original_b = b

REM Euclidean algorithm
DO WHILE b > 0
    temp = b
    b = a MOD b
    a = temp
LOOP

PRINT "GCD of", original_a, "and", original_b, "is", a

END
