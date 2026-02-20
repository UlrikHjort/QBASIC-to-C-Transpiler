REM Bubble sort demonstration
PRINT "Bubble Sort Demo"
PRINT "Sorting 5 numbers"

REM Initialize array with unsorted numbers
DIM arr(5)
arr(1) = 64
arr(2) = 34
arr(3) = 25
arr(4) = 12
arr(5) = 22

PRINT "Original array:"
FOR i = 1 TO 5
    PRINT arr(i);
NEXT i
PRINT

REM Bubble sort algorithm
FOR i = 1 TO 4
    FOR j = 1 TO 5 - i
        IF arr(j) > arr(j + 1) THEN
            REM Swap elements
            temp = arr(j)
            arr(j) = arr(j + 1)
            arr(j + 1) = temp
        END IF
    NEXT j
NEXT i

PRINT "Sorted array:"
FOR i = 1 TO 5
    PRINT arr(i);
NEXT i
PRINT

END
