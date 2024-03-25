MYCODE SEGMENT 'CODE'
;ЛР#3 2024 ЛАРКИН ИУ5-41Б Вар#11
ASSUME CS:MYCODE
PUBLIC LET
LET  DB 'Л'

;Дополнительное задание
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

;Кладет полученный символ в AL
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
; Загрузка сегментного регистра данных DS
     PUSH CS
     POP  DS
; Вывод символов на экран
    CALL CLRSCR
    MOV DL, LET 
    CALL PUTCH
    CALL CLRF
    MOV DL, 'А'
    CALL PUTCH
    CALL CLRF
    MOV DL, 'Б'
    CALL PUTCH
    CALL CLRF
    MOV DL, 'В'
    CALL PUTCH
    CALL CLRF
    CALL GETCH
    MOV DL, AL
    CALL PUTCH
    CALL CLRF
; Выход из программы
     MOV AL, 0
     MOV AH, 4CH
     INT 21H
MYCODE ENDS
END START


