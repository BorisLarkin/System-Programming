echo off
:menu
cls
echo 1. ����� 1 �������  DIR
echo 2. ����� 2
echo 3. ��室

be ask "�롥�� �㭪� (1,2,3)" '123'
REM  default=1 timeout=4 adjust=0 3

if errorlevel 3 goto 3
if errorlevel 2 goto 2
if errorlevel 1 goto 1
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
goto fin

:fin
ECHO �����襭�� �ணࠬ��