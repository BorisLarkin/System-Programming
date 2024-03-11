@ECHO off

REM ��������� ��������� cmd
chcp 1251
REM ������������� ����������� � ����� ������� ������, �������� �� ���������
SET help_pr=MY_help.bat
SET clear_sc=1

REM ������ ������� ������
if "%1"=="���" set clear_sc=0
if "%1"=="��" set clear_sc=1

REM ����� ����������
SHIFT
rem �������� ����� �������
IF NOT (%1) == () SET help_pr=%1
 
:menu
cls
REM ����
ECHO 1. ������������� ����
ECHO 2. ���������� � ������� "RENAME"
ECHO 3. ������ ������������� ������� "RENAME"
ECHO 4. �������
ECHO 5. �����

REM ������ ������� �������
CHOICE /C:12345 /M "�������� ����� 1-5: "
IF ERRORLEVEL 5 goto 5
IF ERRORLEVEL 4 goto 4
IF ERRORLEVEL 3 goto 3
IF ERRORLEVEL 2 goto 2
IF ERRORLEVEL 1 goto 1
goto fin

:1
REM ����� ���������� ����������� ����� �� �������� ��������������
CALL rename.bat
pause
goto menu

:2
REM ��������� ���������� � �������
cls
ECHO ������� RENAME:
rename /?
pause
goto menu

:3 
REM ������������� ������� RENAME
cls
ECHO ������ ������������� ������� RENAME:
echo ������ ���� "test.txt".
@ECHO ON
echo.>"test.txt"
@echo off
pause
echo �������������� ����� �� test.txt � example.txt
@echo on
rename "test.txt" "example.txt"
@echo off
echo ���������.
pause
del "example.txt"
goto menu

:4
REM ����� ���������� ����������� ����� �������
CALL %help_pr%
pause
goto menu

:5
:fin
REM ��������� + �������� ������ �������
ECHO ��������� ��������� ������.
pause
IF %clear_sc%==1 CLS