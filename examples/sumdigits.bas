REM Sum of digits calculator
PRINT "Sum of Digits Calculator"
PRINT "Enter a positive integer:"
INPUT num

IF num < 0 THEN
    num = ABS(num)
    PRINT "Using absolute value:", num
END IF

original = num
sum = 0

DO WHILE num > 0
    digit = num MOD 10
    sum = sum + digit
    num = INT(num / 10)
LOOP

PRINT "Sum of digits of", original, "is", sum

END
