REM Prime number checker
PRINT "Prime Number Checker"
PRINT "Enter a number to check:"
INPUT num

isprime = 1

IF num < 2 THEN
    isprime = 0
END IF

IF num = 2 THEN
    isprime = 1
END IF

IF num > 2 THEN
    divisor = 2
    limit = SQR(num)
    
    DO WHILE divisor <= limit
        IF num MOD divisor = 0 THEN
            isprime = 0
            divisor = limit + 1
        END IF
        divisor = divisor + 1
    LOOP
END IF

IF isprime = 1 THEN
    PRINT num, "is prime"
END IF

IF isprime = 0 THEN
    PRINT num, "is not prime"
END IF

END
