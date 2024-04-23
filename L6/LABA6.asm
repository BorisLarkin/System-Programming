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
;;;;;;;;Заполнение буфера
   MOV BH , 0
   MOV BL , COUNT
   MOV BUF+[BX],'$'
   MOV AH, 09H
   LEA DX, BUF
	INT 21h
   CALL LFCR

 ; CРАВНЕНИЕ
   CLD ;очистка флагов
   MOV AL, ' '
   MOV CX, BX ;в BX лежит COUNT
   MOV BX, 0
   find_space:
      CMP [BUF+BX], AL ;Если пробел => конец ПАР1
      JE space_found
      INC BX
   loop find_space
   MOV space_index, 255 ;Значение, не имеющее смысла
   JMP COMPARELEN

   space_found:
      MOV space_index, BL

COMPARELEN:
   ;Сравнение длины
   MOV CL, 6 ;Ларкин 
   CMP CL, space_index ;if 6: len=6
   JNE NotEqual

COMPARE:
   ;Длина верна, сравниваем побайтово
   CLD
   LEA SI, BUF
   LEA DI, PAR1
   REPE CMPSB
   JNZ NotEqual

   MOV AH, 09H
   MOV DX , OFFSET MSG1CORRECT        ; правильно
   INT 21h
   JMP Par2Processing

NotEqual:
   CMP COUNT, CL
   JE COMPARE
   MOV AH, 09H
   MOV DX , OFFSET MSG1WRONG        ; Ошибка
   INT 21h

Par2Processing:
   CMP space_index, 255
   JE NPAR2
   MOV AL, ' '
   MOV CX, COUNT-space_index
   MOV BH, 0
   MOV BL, space_index
   find_par2:
      CMP [BUF+BX], AL ;Если не пробел => есть ПАР2
      JNZ YPAR2
      INC BX
   loop find_par2
NPAR2:
   MOV AH, 09H
   LEA DX, MSGNPAR2        ; Параметра 2 нет
   INT 21h
   JMP PARPRINT

YPAR2:
   MOV AH, 09H
   LEA DX, MSGYPAR2        ; Параметр 2 есть
   INT 21h

PARPRINT: ;ПЕЧАТЬ АРГУМЕНТОВ
   CALL LFCR
   MOV AH, 09H
   MOV DX , OFFSET MSGPRINT        ; ПРОПЕЧАТКА слово
   INT 21h
;;;;;;;;;;;;;;;;;;;;;;;
   MOV AH,09
   MOV DX , OFFSET BUF
   INT 21h

; Ожидание завершения программы
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
space_index db 0
MSG1  DB 'Ошибка параметров!', 10,13, '$'
BUF   DB 127 DUP (0) 
   DB '$', 10,13, '$'
COUNT DB 0
MSGPRINT db 'ПРОПЕЧАТКА!',10,13,'$'
PAR1  DB 'Ларкин',10,13,'$'
MSG1CORRECT db 'Первый параметр верен = Ларкин',10,13,'$'
MSG1WRONG DB 'Первый параметр неправильный!',10,13,'$'
MSGYPAR2 DB 'Второй параметр ЕСТЬ ! ',10,13,'$'
MSGNPAR2 DB 'Второго параметра НЕТ ! ',10,13,'$'
MYCODE ENDS
END START