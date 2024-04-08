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

;Возвращает по адресу DS:DX буффер строки
GETSTRING PROC
    mov ah, 0AH ; Буфферный ввод строки
    lea DX, buffer ;DS:DX указывает на буффер строки
    int 21H
    MOV bl, buffer[1] ; Число считанных символов 
    MOV inputLength, bl
    add inputLength, 1 ;Учитываем +'$'
    mov SI, OFFSET DX
    add SI, 2 ; Указываем на Реальное начало строки, введенной в буффер
    MOV AL, inputLength ;загружаем число в AL
    CBW ;Преобразуем в двухбайтовый тип
    add SI, AX ; SI Указывает на байт за концом строки
    mov SI,'$' ;Завершение строки
    RET
GETSTRING ENDP

MAIN PROC
; Загрузка сегментного регистра данных DS
    MOV AX, DTSEG
    MOV DS, AX
    MOV AX, STSEG
    MOV DS, AX
    PUSH DS
    POP ES
    PUSH BP
; Вывод символов на экран
    loopmain:
        CALL CLSSCR
        CALL GETSTRING
        MOV BL, buffer[2]
        CMP BL, BREAK_SYMBOL ;первый символ ввода с '*'
        JZ term
        MOV AL, inputLength
        CBW
        MOV CX, AX ;Число символов
        lea SI, buffer
        ADD SI, 2
        loopstr:
            CALL CLRF
            MOV AL, [SI]
            CALL HEX
            INT 21H
            MOV DL, ' '
            CALL PUTCH
            ADD SI, 1
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
    inputLength db 255   ; number of read characters
    buffer db 255 DUP('$') ; actual buffer
    BREAK_SYMBOL DB '*'     ;Символ, по которому будет производится выход
DTSEG ENDS

END MAIN