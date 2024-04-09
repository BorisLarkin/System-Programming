MYCODE SEGMENT 'CODE'
;ЛР#5 2024 ЛАРКИН ИУ5-41Б Вар#11
ASSUME CS:MYCODE, DS:DTSEG, SS:STSEG

;ПЕРЕВОД СИМВОЛА В HEX из AL
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
    MOV AX, '$'
    STOSW
    LEA DX, STRING
    RET
HEX ENDP

GETCH PROC
   MOV AH, 08H
   INT 21H
   RET
GETCH ENDP

CLSSCR PROC
     PUSH BX
     PUSH CX
     PUSH AX
     MOV   AX,0600H   ;Запрос на очистку экрана.
     MOV   BH,07      ;Нормальный атрибут (черно/белый).
     MOV   CX,0000    ;Верхняя левая позиция.
     MOV   DX,184FH   ;Нижняя правая позиция.
     INT   10H        ;Передача управления в BIOS.
     POP AX
     POP CX
     POP BX
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

PUTSTR PROC
    MOV AH, 09h
    INT 21H
    RET
PUTSTR ENDP

;Возвращает по адресу DS:DX буффер строки
GETSTRING PROC
    LEA DI, buffer ;DS:DX указывает на буффер строки
    MOV CX, 20
    CYCLE_INPUT:
        CALL GETCH
        MOV DX, AX
        CALL PUTCH
        CMP AL, '$'
        JE endofstring
        CMP AL, BREAK_SYMBOL
        JZ term
        STOSB
    LOOP CYCLE_INPUT
    endofstring:
        MOV AX, 20
        SUB AX, CX
        MOV inputLength, AX
    RET
GETSTRING ENDP

MAIN PROC
; Загрузка регистров данных
    MOV AX, DTSEG
    MOV DS, AX
    MOV AX, STSEG
    MOV SS, AX
    PUSH DS
    POP ES
; Вывод символов на экран
    CALL CLSSCR
    LEA DX, start
    CALL PUTSTR
    loopmain:
        CALL CLRF
        CALL GETSTRING
        MOV CX, inputLength ;Число символов
        lea SI, buffer
        MOV DL, '='
        CALL PUTCH
        loopstr:
            LODSB
            CALL HEX
            MOV AH, 09h
            INT 21H
            CALL PUTCH
        loop loopstr
        CALL GETCH
        CALL CLSSCR
        jmp loopmain
ENDP MAIN    
; Выход из программы
term:
     ;Выход с кодом 0
     MOV AL, 0
     MOV AH, 4CH
     INT 21H
MYCODE ENDS

STSEG SEGMENT stack
    dw 128 dup (0)
STSEG ENDS

DTSEG SEGMENT
    String db '           $',0
    hext DB '0123456789ABCDEF'       
    inputLength dw 20  ; number of read characters
    buffer db 20 DUP(0) ; actual buffer
    BREAK_SYMBOL DB '*'     ;Символ, по которому будет производится выход
    start DB "Введите доллар для окончания строки; '*' - для окончания работы$"
DTSEG ENDS

END MAIN