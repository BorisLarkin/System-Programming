MYCODE SEGMENT 'CODE'
;��#4 2024 ������ ��5-41�
ASSUME CS:MYCODE
String db '           $',0
hext DB '0123456789ABCDEF'       
LET DB '�'
;������, �� ���஬� �㤥� �ந�������� ��室
BREAK_SYMBOL DB '*'

;������� ������� � HEX �� AL
HEX PROC
    LEA DI, String
    MOV BX, OFFSET hext
    PUSH AX
    SHR AL, 4
    XLAT
    STOSB
    POP AX
    PUSH AX
    AND AL, 00001111b
    XLAT
    STOSB
    POP AX
    MOV AX, 'h'
    STOSW
    MOV AH, 09h
    LEA DX, STRING
    RET
HEX ENDP

CLSSCR PROC
    MOV AH, 0H
    INT 10H
    RET
CLSSCR ENDP

PUTCH PROC
    MOV AH, 02H
    INT 21H
    RET
PUTCH ENDP

CLRF PROC
    MOV DL, 10
    CALL PUTCH
    MOV DL, 13
    CALL PUTCH
    RET
CLRF ENDP

;��७��� �������� ᨬ��� � AL
GETCH PROC
   MOV AH, 08H
   INT 21H
   RET
GETCH ENDP

;�뢮��� ⠡���� ��� �।���⥫쭮 ��������� LET
PRINTCODES PROC
    looppr:
        MOV DL, LET
        CALL PUTCH
        MOV DL, '-'
        CALL PUTCH
        MOV AL, LET
        CALL HEX
        INT 21H
        CALL CLRF
        ADD LET, 1
    loop looppr
    ;2 \n, ⠪ ��� CLRSCR �� ���� ��࠭ ���������
    CALL CLRF
    CALL CLRF
    RET
PRINTCODES ENDP

START:
; ����㧪� ᥣ���⭮�� ॣ���� ������ DS
     PUSH CS
     POP  DS
     PUSH DS
     POP ES
     PUSH ES
; �뢮� ᨬ����� �� ��࠭
    CALL CLSSCR
    loopmain:
        MOV CX,20
        CALL GETCH
        CMP AL, BREAK_SYMBOL
        JZ term
        MOV LET, AL
        CALL CLSSCR
        CALL PRINTCODES
    loop loopmain    
; ��室 �� �ணࠬ��
term:
     ;��室 � ����� 5
     MOV AL, 5
     MOV AH, 4CH
     INT 21H
MYCODE ENDS
END START


