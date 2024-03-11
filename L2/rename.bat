@echo off
cls
echo Переименуйте файл, выбранный по Вашему усмотрению.
set /p f_disk=Выберите диск с файлом (в формате 'C:'):
set /p f_path=Введите путь к файлу (в формате '\folder1\f2\'):
set /p name1=Введите текущее название файла:
set /p name2=Введите новое имя для файла:
@echo on
rename %f_disk%%f_path%%name1% %name2%
@echo off
exit /b
