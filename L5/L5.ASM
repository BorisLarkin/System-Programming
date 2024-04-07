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

;Возвращает по адресу ds:DX буффер строки, в AH - длину 
GETSTRING PROC
    mov ah, 0AH ; Буфферный ввод строки
    lea DX, buffer ;ds:DX указывает на буффер строки
    int 21H
    mov SI, OFFSET DX
    add SI, 1 ; Указываем на число символов, введенных в буффер
    MOV AX, BYTE [SI]
    MOV inputLength, AX ; Число считанных символов 
    add inputLength, 1 ;Учитываем +'$'
    add DX, 2 ; Реальное начало строки
    mov SI, OFFSET DX
    add SI, inputLength ; SI Указывает на байт за концом строки
    mov SI,'$' ;Завершение строки
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
        CMP [buffer], BREAK_SYMBOL
        JZ term
        MOV CX, inputLength ;Число символов
        loopstr:
            MOV AL, byte [SI + inputLength - CX] 
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
    bufferSIze  db 255  ; 20 char + RETURN
    inputLength db 0   ; number of read characters
    buffer db 255 DUP('$') ; actual buffer
    BREAK_SYMBOL DB '*'     ;Символ, по которому будет производится выход
    dw 255 dup ($)
DTSEG ENDS

END MAIN