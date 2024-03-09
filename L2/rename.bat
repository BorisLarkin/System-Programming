echo off
cls
echo Rename a file of your liking.
set /p disk = Choose a disk of the file:
set /p path = Type in the path to the file:
set /p name1 = Enter the existing name of the file:
set /p name2 = Enter a new name for the file:
rename [disk][path]name1 name2
cls
exit /b