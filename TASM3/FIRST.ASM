MYCODE SEGMENT 'CODE'
    ASSUME CS:MYCODE
    PUBLIC LET
LET  DB 'A'
START:
; �������� ����������� �������� ������ DS
     PUSH CS
     POP  DS
; ����� ������ ������� �� �����
     MOV AH, 02
     MOV DL, LET
     INT 21H
; ����� �� ���������
     MOV AL, 0
     MOV AH, 4CH
     INT 21H
MYCODE ENDS
END START


