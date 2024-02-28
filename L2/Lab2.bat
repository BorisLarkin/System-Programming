echo off

REM Initializing variables
SET help_pr=MY_help.bat
SET clear_sc=1
REM Shifting args
SHIFT
if (%0)=() SET help_pr=%0
if (%1)=Нет SET clear_sc=0

:menu
if clear_sc=1 cls
REM Menu
echo 1. Mode 1
echo 2. Mode 2
echo 3. Mode 3
echo 4. Help
echo 5. Exit

REM Request key press
CHOICE /C:12345 /D:1 /T:10 /M "Choose an option 1-5: "
if ERRORLEVEL 5 goto 5
if ERRORLEVEL 4 goto 4
if ERRORLEVEL 3 goto 3
if ERRORLEVEL 2 goto 2
if ERRORLEVEL 1 goto 1
goto fin

:1
echo 1
pause
goto menu

:2
echo 2
pause
goto menu

:3
echo 3
pause
goto menu

:4
echo 4
CALL %help_pr%
pause
goto menu

:5 
echo 5
pause
goto fin

:fin
ECHO Завершение программы...