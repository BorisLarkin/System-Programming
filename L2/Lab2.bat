@echo off

REM Initializing variables
SET help_pr=MY_help.bat
REM Shifting args
SHIFT
if NOT [%1] == [] (
    SET help_pr=%1
)
if [%0] == [Нет] (
    SET clear_sc=0
)
if [%0] == [Да](
    SET clear_sc=1
)
else (
    REM Стандартное значение 
    set clear_sc=1
)
echo %0
echo %clear_sc%

:menu

REM Меню
echo 1. Rename files
echo 2. Help
echo 3. Exit

REM Запрос нажатия клавиши
CHOICE /C:123 /M "Choose an option 1-3: "
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
goto fin

:fin
echo Program terminated.
pause
if %clear_sc%==1 cls