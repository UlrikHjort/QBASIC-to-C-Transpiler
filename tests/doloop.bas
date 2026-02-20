REM Test working DO...LOOP variants (3 of 4 forms)
PRINT "Test 1: DO WHILE...LOOP"
x = 1
DO WHILE x <= 3
    PRINT "x =", x
    x = x + 1
LOOP

PRINT "Test 2: DO UNTIL...LOOP"
y = 1
DO UNTIL y > 3
    PRINT "y =", y
    y = y + 1
LOOP

PRINT "Test 3: DO...LOOP UNTIL"
z = 10
DO
    PRINT "z =", z
    z = z - 1
LOOP UNTIL z < 8

PRINT "All 3 working forms tested!"
END
