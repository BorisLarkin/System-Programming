@echo off
cls
echo ������������ ����, ��������� �� ������ ����������.
set /p f_disk=�������� ���� � ������ (� ������� 'C:'):
set /p f_path=������� ���� � ����� (� ������� '\folder1\f2\'):
set /p name1=������� ������� �������� �����:
set /p name2=������� ����� ��� ��� �����:
@echo on
rename %f_disk%%f_path%%name1% %name2%
@echo off
exit /b
