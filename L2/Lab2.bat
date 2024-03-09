@ECHO off

REM Инициализация переменных

SET help_pr=MY_help.bat
REM Стандартное значение 
SET clear_sc=1 

REM Сдвиг аргументов
SHIFT
IF NOT [%1] == [] (
    SET help_pr=%1
)

:menu
cls
REM Меню
ECHO 1. Rename files
ECHO 2. Help
ECHO 3. Exit

REM Запрос нажатия клавиши
CHOICE /C:123 /M "Choose an option 1-3: "
IF ERRORLEVEL 3 goto 3
IF ERRORLEVEL 2 goto 2
IF ERRORLEVEL 1 goto 1
goto fin

:1
CALL rename.bat
pause
goto menu

:2
ECHO %help_pr%
CALL %help_pr%
pause
goto menu

:3 
ECHO 3
goto fin

:fin
ECHO Program terminated.
pause
IF %clear_sc%==1 CLS