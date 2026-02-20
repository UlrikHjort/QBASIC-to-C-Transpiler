REM Test GOTO and line numbers
PRINT "Starting program"

10 PRINT "This is line 10"
   PRINT "Going to line 30"
   GOTO 30

20 PRINT "This is line 20 (skipped)"

30 PRINT "This is line 30"
   PRINT "End of program"

END
