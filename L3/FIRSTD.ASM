MYCODE SEGMENT 'CODE'
;��#3 2024 ������ ��5-41� ���#11
ASSUME CS:MYCODE
PUBLIC LET
LET  DB '�'

;�������⥫쭮� �������
CLRSCR PROC
    MOV AH, 0H
    INT 10H
    RET
CLRSCR ENDP

PUTCH PROC
    MOV AH, 02H
    INT 21H
    RET
PUTCH ENDP

;������ ����祭�� ᨬ��� � AL
GETCH PROC
    MOV AH, 08H
    INT 21H
    RET
GETCH ENDP

CLRF PROC
    MOV DL, 10
    CALL PUTCH
    MOV DL, 13
    CALL PUTCH
    RET
CLRF ENDP

START:
; ����㧪� ᥣ���⭮�� ॣ���� ������ DS
     PUSH CS
     POP  DS
; �뢮� ᨬ����� �� ��࠭
    CALL CLRSCR
    MOV DL, LET 
    CALL PUTCH
    CALL CLRF
    MOV DL, '�'
    CALL PUTCH
    CALL CLRF
    MOV DL, '�'
    CALL PUTCH
    CALL CLRF
    MOV DL, '�'
    CALL PUTCH
    CALL CLRF
    CALL GETCH
    MOV DL, AL
    CALL PUTCH
    CALL CLRF
; ��室 �� �ணࠬ��
     MOV AL, 0
     MOV AH, 4CH
     INT 21H
MYCODE ENDS
END START


