echo off

REM Initializing variables
SET help_pr=MY_help.bat
SET clear_sc=1
REM Shifting args
SHIFT
if [%1] NEQ [] SET help_pr=%1
if [%0] == "Нет" SET clear_sc=0

:menu
if clear_sc==1 cls
REM Menu
echo 1. Rename files
echo 2. Help
echo 3. Exit

REM Request key press
CHOICE /C:123 /D:1 /T:10 /M "Choose an option 1-5: "
if ERRORLEVEL 3 goto 3
if ERRORLEVEL 2 goto 2
if ERRORLEVEL 1 goto 1
goto fin

:1
CALL rename.bat
pause
goto menu

:2
echo 2
CALL %help_pr%
pause
goto menu

:3 
echo 3
pause
goto fin

:fin
ECHO Завершение программы...