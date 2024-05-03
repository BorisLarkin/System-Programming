TITLE  Ларкин ИУ5-41
;ЛР #7 2024 Ларкин ИУ5-41Б
DATASG SEGMENT 'DATA'
TABLHEX DB '0123456789ABCDEF'
MSG DB 'Введите шестнадцатеричное число(HHHH, * - конец программы):$'
BUF    DB  100 DUP( 0 )
DECW   DW  0
MSGERR DB 'Ошибка символа!$'
MSGEND DB 'Завершение программы ЛР7, Ларкин Б. В. ИУ5-41, Вар. 11. Нажмите любую клавишу...$'
DATASG ENDS

STSEG SEGMENT STACK 'STACK'
 DW 256 DUP(0)
STSEG ENDS

MYCODE SEGMENT 'CODE'
    ASSUME CS:MYCODE, DS:DATASG, SS:STSEG
START:
; Загрузка сегментного регистра данных DS
    MOV AX, DATASG
    MOV DS, AX
;; Цикл проверки ввода *
    MOV AH, 00H
    MOV AL, 03H
    INT  10H
;
    MOV AH, 9H
    LEA DX, MSG
    INT 21h
    CALL LFCR
;;
    MOV CX, 10
METLOOP:
; Ввод шетн. числа и запоминание в BUF
     CALL HEXADR
;
     MOV DL, ' '
     CALL PUTCH
     MOV DL, '='
     CALL PUTCH
     MOV DL, ' '
     CALL PUTCH
; Вывод шестнадцатеричного числа
     CALL PRINTHEX
     MOV DL, ' '
     CALL PUTCH
     MOV DL, ' '
     CALL PUTCH
; Перевод в десятичное и печать
     CALL DECPRINT
; Цикл вывода шетнадцатеричной строки
    CALL LFCR
LOOP METLOOP

MEND:
    MOV AH, 9H
    LEA DX, MSGEND
    INT 21h
    CALL GETSIMB
; Очистка экрана
    MOV AH, 00H
    MOV AL, 03H
    INT  10H

; Выход из прораммы
    MOV AH, 4Ch
    MOV AL, 0
    INT 21H
; Продецуры программы
HEXADR PROC
    ; Подготовка цикла ввода
    proc_start:
        MOV SI , OFFSET BUF
        MOV CX , 4
    ; Цикл   до 4-х  символов
    MVVOD:
        MCICL:
            CALL GETSIMB
            CMP AL, '*'
            JE MEND
        MC1:
        ; Проверка символа на правильность
        CMP AL , 30H
        JE MBUF
        CMP AL , 31H
        JE MBUF
        CMP AL , 32H
        JE MBUF
        CMP AL , 33H
        JE MBUF
        CMP AL , 34H
        JE MBUF
        CMP AL , 35H
        JE MBUF
        CMP AL , 36H
        JE MBUF
        CMP AL , 37H
        JE MBUF
        CMP AL , 38H
        JE MBUF
        CMP AL , 39H
        JE MBUF
        CMP AL , 'A'
        JE MBUF
        CMP AL , 'B'
         JE MBUF
        CMP AL,  'C'
        JE  MBUF
        CMP AL , 'D'
        JE MBUF
        CMP AL , 'E'
        JE MBUF
        CMP AL,  'F'
        JE  MBUF
        CMP AL , 'a'
        JE MBUF
        CMP AL , 'b'
         JE MBUF
        CMP AL,  'c'
        JE  MBUF
        CMP AL , 'd'
        JE MBUF
        CMP AL , 'e'
        JE MBUF
        CMP AL,  'f'
        JE  MBUF 
    
        ERROR:
            MOV DL, AL
            CALL PUTCH
            CALL LFCR
            MOV AL,'#'
            MOV DX , OFFSET MSGERR
            mov AH , 09H
            INT 21H
            CALL LFCR
            JMP proc_start 
    
        ; Запись в буфер и печать
        MBUF:
            MOV [SI], AL
            INC SI
            ; Печать символа
            MOV DL, AL
            CALL PUTCH
    LOOP MVVOD
;
    MOV  BYTE PTR [SI], '$'
    RET
HEXADR ENDP
;;
PRINTHEX PROC
      MOV DX , OFFSET BUF
      MOV AH , 09H
      INT 21h
      RET
PRINTHEX ENDP
;
SIMPER PROC
       CMP AL , 39H
       JG MS1
       SUB AL , 30H
       JMP MSE
MS1:   CMP AL , 'F'
       JG MS2
       SUB AL , 'A'
       ADD AL,10
       JMP MSE
MS2:   SUB AL , 'a'
       ADD AL,10
       
MSE:
       RET
SIMPER ENDP
DECPRINT PROC
    ; Первод в машинное представление
    MOV SI , OFFSET BUF
    MOV BX , 4096
    MOV DECW , 0
    MOV CX , 4
    CPER:
       MOV AL , [SI]
       CALL SIMPER
       MOV AH, 0
       MUL BX
       MOV DX , DECW
       ADD DX , AX
       MOV DECW , DX
       SHR BX , 1
       SHR BX , 1
       SHR BX , 1
       SHR BX , 1
       INC SI
    LOOP  CPER
    ; Перевод в десятичное представление
    MOV CX , 5
    MOV BX , 10000

    MDEC:
       MOV AX , DECW
       MOV DX , 0
       DIV BX
       MOV DECW , DX
       ADD AL , 30H
       MOV DL , AL
       CALL PUTCH
       MOV AX, BX
       MOV DX , 0
       MOV BX , 10
       DIV BX
       MOV BX , AX
    LOOP MDEC
    RET
DECPRINT ENDP

; Процедура вывода символа на DL
PUTCH PROC
      MOV AH , 2
      INT 21H
      RET
PUTCH ENDP
; Процедура перевода строки
LFCR PROC
     MOV DL, 10
     CALL PUTCH
     MOV DL, 13
     CALL PUTCH
     RET
LFCR ENDP

; Procedyra vivoda simvola
GETSIMB PROC
; enter simbol
    MOV AH, 08H
    INT 21H
    RET
GETSIMB ENDP
;
MYCODE ENDS

END START
