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
    MOV AH, 09h
    LEA DX, STRING
    RET
HEX ENDP

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

;Возвращает по адресу ds:dx буффер строки, в AH - длину 
GETSTRING PROC
    mov dx, offset bufferSize ; load our pointer to the beginning of the structure
    mov ah, 0AH ; Буфферный ввод строки
    lea dx, buffer ;ds:dx указывает на буффер строки
    int 21H
    mov inputLength, 1;offset dx + 1 ; Число считанных символов ;Учитываем +'$'
    add dx, 2 ; Реальное начало строки
    mov si, dx
    add si, 5;inputLength ; si Указывает на байт за концом строки
    mov byte [si], '$' ;Завершение строки
GETSTRING ENDP

MAIN PROC
; Загрузка сегментного регистра данных DS
    MOV AX, DTSEG
    MOV DS, AX
    MOV AX, STSEG
    MOV DS, AX
    PUSH DS
    POP ES
; Вывод символов на экран
    loopmain:
        CALL CLSSCR
        CALL GETSTRING
        CMP byte [dx], BREAK_SYMBOL
        JZ term
        MOV CX, 5;inputLength ;Число символов
        loopstr:
            MOV LET, byte [si + inputLength - CX]
            MOV AL, LET 
            CALL HEX
            INT 21H
            MOV DL, ' '
            CALL PUTCH
        loop loopstr
    loop loopmain
ENDP MAIN    
; Выход из программы
term:
     ;Выход с кодом 5
     MOV AL, 5
     MOV AH, 4CH
     INT 21H
MYCODE ENDS

STSEG SEGMENT stack 'stack'
    dw 255 dup (0)
STSEG ENDS

DTSEG SEGMENT 'DATA'
    String db '           $',0
    hext DB '0123456789ABCDEF'       
    LET DB 'А'
    bufferSize  db 255  ; 20 char + RETURN
    inputLength db 0   ; number of read characters
    buffer db 255 DUP('$') ; actual buffer
    BREAK_SYMBOL DB '*'     ;Символ, по которому будет производится выход
    dw 255 dup ($)
DTSEG ENDS

END MAIN