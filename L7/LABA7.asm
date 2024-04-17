TITLE  Большаков ИУ5-00
DATASG SEGMENT 'DATA'
TABLHEX DB '0123456789ABCDEF'
MSG DB 'Введите шетнадцатеричное число(HHHH, * - конец программы):$'
BUF    DB  100 DUP( 0 )
DECW   DW  0
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
    MOV CX, 3
METLOOP:
; Цикл ввода строки
    CALL GETSIMB
    CMP AL, '*'
    JE MEND
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
; Ожидание завершения программы
;    MOV AH, 01H
;    INT 021H
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
     MOV SI , OFFSET BUF
     MOV CX , 4
; Цикл
MVVOD:
MCICL:
     CMP CX , 4
     JE MC1
     CALL GETSIMB
    CMP AL, '*'
    JE MEND
MC1:
; Проверка символа на правильность
     CMP AL , 30H
     JL MCICL
     CMP AL , 39H
     JLE MBUF
     CMP AL , 65
     JL MCICL
     CMP AL , 70
     JG MCICL
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
       JMP MS2
MS1:   SUB AL , 55
MS2:
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
;
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



