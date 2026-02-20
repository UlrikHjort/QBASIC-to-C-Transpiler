REM Temperature converter
PRINT "Temperature Converter"
PRINT "1. Celsius to Fahrenheit"
PRINT "2. Fahrenheit to Celsius"
PRINT "Enter choice (1 or 2):"
INPUT choice

celsius = 0
fahrenheit = 0

IF choice = 1 THEN
    PRINT "Enter temperature in Celsius:"
    INPUT celsius
    fahrenheit = celsius * 9 / 5 + 32
    PRINT celsius, "C =", fahrenheit, "F"
END IF

IF choice = 2 THEN
    PRINT "Enter temperature in Fahrenheit:"
    INPUT fahrenheit
    celsius = (fahrenheit - 32) * 5 / 9
    PRINT fahrenheit, "F =", celsius, "C"
END IF

END
