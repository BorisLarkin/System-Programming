STSEG SEGMENT STACK 'STACK'
   DW 256 DUP(0)
STSEG ENDS

MYCODE SEGMENT 'CODE'
   ASSUME CS:MYCODE, DS:MYCODE, SS:STSEG
START:
; Загрузка регистров
   PUSH CS
   POP DS
   PUSH DS
   POP ES
   MOV AH , 51H ;Получение ID текущего процесса (PSP адрес)
   int 21H
   MOV ES , BX
   mov save_psp , ES
; получение счетчика  ES
   MOV AL , ES:128
   DEC AX ;не учитываем незначащий пробел
   MOV COUNT , AL
; перерезапись
   MOV CL, AL
   MOV CH , 0
   PUSH CS

   POP  ES
   MOV DS , save_psp
   MOV SI , 130 ;Не копируем пробел
   LEA DI , BUF
   REP MOVSB
   PUSH CS
   POP DS
;;;;;;;; Распечатка параметров
   MOV BH , 0
   MOV BL , COUNT
   MOV BUF+[BX],'$'
   MOV AH, 09H
   LEA DX, BUF        ; ПРОПЕЧАТКА ПАРАМЕТРЫ
	INT 21h
   CALL LFCR

 ; CРАВНЕНИЕ
   CLD ;очистка флагов
   LEA SI, BUF
   LEA DI, PAR1
   MOV CX, 6 ;Ларкин
   REP CMPSB
   JNZ NotEqual

   ;равно
   MOV AL, ' '
   CMP [BUF+6], AL ;Если пробел => конец ПАР1
   JNE NotEqual

   MOV AH, 09H
   MOV DX , OFFSET MSG1CORRECT        ; правильно
   INT 21h
   JMP Par2Processing

NotEqual:
   MOV AH, 09H
   MOV DX , OFFSET MSG1WRONG        ; Ошибка
   INT 21h
   CALL LFCR

Par2Processing:
   MOV AL, ' '
   MOV CX, COUNT
   REP CMP [BUF+6+COUNT-CX], AL ;Если пробел => конец ПАР1
   MOV AH, 09H
   LEA DX, MSGPAR2        ; Параметр 2 есть
   INT 21h


   MOV AH, 09H
   MOV DX , OFFSET MSGPRINT        ; ПРОПЕЧАТКА слово
   INT 21h
;;;;;;;;;;;;;;;;;;;;;;;
   MOV AH,09
   MOV DX , OFFSET BUF
   INT 21h
; Проверка наличия параметров
; Ожидание завершения программы
MEND2:
   MOV AH, 01H
   INT 021H
; Выход из прораммы
   MOV AH, 4Ch
   MOV AL, 0
   INT 21H


; Продецуры программы
;;;;;;;;;;;;;;    cmpsb
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

save_psp dw 0
MSG1  DB 'Ошибка параметров!', 10,13, '$'
BUF   DB 127 DUP (0) 
   DB '$', 10,13, '$'
COUNT DB 0
MSGPRINT db 'ПРОПЕЧАТКА!',10,13,'$'
PAR1  DB 'Ларкин',10,13,'$'
MSG1CORRECT db 'Первый параметр верен = Ларкин',10,13,'$'
MSG1WRONG DB 'Первый параметр неправильный!',10,13,'$'
MSGPAR2 DB 'Второй параметр ЕСТЬ ! ',10,13,'$'
MYCODE ENDS
END START