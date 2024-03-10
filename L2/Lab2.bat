@ECHO off

REM Изменение кодировки cmd
chcp 65001
REM Инициализация переменных, default values

SET help_pr=MY_help.bat
SET clear_sc=1 
SET batch_path=%~dp0

REM Флажок очистки
if "%1"=="Нет" set clear_sc=0
if not "%1"=="Нет" set clear_sc=1

REM Сдвиг аргументов
SHIFT
IF NOT (%1) == () SET help_pr=%1
 
:menu
cls
REM Меню
ECHO 1. RENAME files
ECHO 2. RENAME information
ECHO 3. RENAME example
ECHO 4. Help
ECHO 5. Exit

REM Запрос нажатия клавиши
CHOICE /C:12345 /M "Choose an option 1-3: "
IF ERRORLEVEL 5 goto 5
IF ERRORLEVEL 4 goto 4
IF ERRORLEVEL 3 goto 3
IF ERRORLEVEL 2 goto 2
IF ERRORLEVEL 1 goto 1
goto fin

:1
CALL rename.bat
pause
goto menu

:2
ECHO Команда RENAME:
rename /?
pause
goto menu

:3 
ECHO Пример использования команды RENAME:
echo Создан файл "test.txt".
echo.>batch_path"test.txt"
pause
echo Переименование файла из test.txt в example.txt
rename batch_path "test.txt" "example.txt"
echo Исполнено.
pause
del batch_path"example.txt"
goto menu

:4
CALL %help_pr%
pause
goto menu

:5
:fin
ECHO Program terminated.
pause
IF %clear_sc%==1 CLS