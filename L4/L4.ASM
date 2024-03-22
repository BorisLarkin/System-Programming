MYCODE SEGMENT 'CODE'
; ЛАРКИН ИУ5-41Б
ASSUME CS:MYCODE
String db '           $',0
hext DB '0123456789ABCDEF'       
let DB 'А'
;ПЕРЕВОД СИМВОЛА В HEX
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

CLS PROC
    MOV AH, 0
    INT 10H
    RET
CLS ENDP

PUTCH PROC
    MOV AH, 02H
    INT 21H
    RET
PUTCH ENDP

CLRF PROC
    MOV DL, 10
    CALL PUTCH
    MOV DL, 8
    CALL PUTCH
    RET
CLRF ENDP

GETCH PROC
   MOV AH, 07H
   INT 21H
   MOV LET, AL
   RET
GETCH ENDP

PRINTCODES PROC
    looppr:
        MOV AL, LET
        MOV DL, AL
        CALL PUTCH
        MOV DL, '-'
        CALL PUTCH
        MOV AL, LET
        CALL HEX
        INT 21H
        CALL CLRF
        ADD LET, 1
    loop looppr
    RET
PRINTCODES ENDP

START:
; Загрузка сегментного регистра данных DS
     PUSH CS
     POP  DS
     PUSH DS
     POP ES
; Вывод символов на экран
    MOV CX, 20
    MOV let, 'А'
    CALL PRINTCODES
    MOV CX, 20
    CALL GETCH
    CALL PRINTCODES    
; Выход из программы
     MOV AL, 0
     MOV AH, 4CH
     INT 21H
MYCODE ENDS
END START


