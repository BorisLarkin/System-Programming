MYCODE SEGMENT 'CODE'
    ASSUME CS:MYCODE
    PUBLIC LET
LET  DB 'A'
START:
; ����㧪� ᥣ���⭮�� ॣ���� ������ DS
     PUSH CS
     POP  DS
; �뢮� ������ ᨬ���� �� ��࠭
     MOV AH, 02
     MOV DL, LET
     INT 21H
; ��室 �� �ணࠬ��
     MOV AL, 0
     MOV AH, 4CH
     INT 21H
MYCODE ENDS
END START


