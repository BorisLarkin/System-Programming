@ECHO off

REM Изменение кодировки cmd
chcp 1251
REM Инициализация справочника и флага очистки экрана, значения по умолчанию
SET help_pr=MY_help.bat
SET clear_sc=1

REM Флажок очистки экрана
if "%1"=="Нет" set clear_sc=0
if "%1"=="Да" set clear_sc=1

REM Сдвиг аргументов
SHIFT
rem Название файла справки
IF NOT (%1) == () SET help_pr=%1
 
:menu
cls
REM Меню
ECHO 1. ПЕРЕИМЕНОВАТЬ файл
ECHO 2. Информация о команде "RENAME"
ECHO 3. Пример использования команды "RENAME"
ECHO 4. Справка
ECHO 5. Выход

REM Запрос нажатия клавиши
CHOICE /C:12345 /M "Выберите опцию 1-5: "
IF ERRORLEVEL 5 goto 5
IF ERRORLEVEL 4 goto 4
IF ERRORLEVEL 3 goto 3
IF ERRORLEVEL 2 goto 2
IF ERRORLEVEL 1 goto 1
goto fin

:1
REM Вызов вложенного коммандного файла со скриптом переименования
CALL rename.bat
pause
goto menu

:2
REM Получение информации о команде
cls
ECHO Команда RENAME:
rename /?
pause
goto menu

:3 
REM Использование команды RENAME
cls
ECHO Пример использования команды RENAME:
echo Создан файл "test.txt".
@ECHO ON
echo.>"test.txt"
@echo off
pause
echo Переименование файла из test.txt в example.txt
@echo on
rename "test.txt" "example.txt"
@echo off
echo Исполнено.
pause
del "example.txt"
goto menu

:4
REM Вызов вложенного коммандного файла справки
CALL %help_pr%
pause
goto menu

:5
:fin
REM Окончание + проверка флажка очистки
ECHO Программа завершила работу.
pause
IF %clear_sc%==1 CLS