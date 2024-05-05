CODEPR  SEGMENT PARA 
ASSUME CS:CODEPR , DS:CODEPR   
   ORG  100H         ; Область PSP 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
; Резидентная часть 
BEGIN:    JMP   INIT              ; Переход к части инициализации 
;        Данные резидента 
OLD_INT9H DD  ?                 ; Сохранение старого обработчика 
F1_FLAG DB 1
F2_FLAG DB 1
F3_FLAG DB 1
;F9_MSG      DB 'Ларкин Б. В., ИУ5-41, Вар. 11', 10,13,'$' 
F9_MSG      DB "sth cool$"

;   Новый обработчик прерывания 09Н 
NEWINT9: 
   PUSH   AX             ; Сохранение используемых регистров 
   PUSH   CX    
   PUSH   BX 
;     Запрос сканкода из клавиатуры 
   IN     AL, 60H        ; Взять из порта 60 Н на регистр AL 
   CMP   AL, 1           ; Проверка сканкода ESC он равен 1 
   JE ESC_pressed
   CMP AL, 2
   JE F9_pressed
   JMP    EXIT           ;   Переход если не ESC 

ESC_pressed:
;      Вывод на экран 10-ти символов ’В’ с помощью BIOS функции 0AH – 010H  
   IN  AL, 61H 
   OR AL, 10000000b     ; установим бит 7 порта В 
   OUT 61H, AL 
   AND AL, 01111111b 
   OUT  61H, AL         ;  сбросим бит 7 порта  В (символ прочитан) 
 ;   Вывод цепочки 10 символов         
   MOV AH , 0AH 
   MOV AL, 'B' 
   MOV BH , 0 
   MOV CX, 10             ;Число символов 
   INT 010H               ; INT BIOS DOS 
   POP BX                 ;  восстановление регистров
   POP CX
;    Сигнал контроллеру прерываний через порт 20Н сигнал (EOI = 20H)              
   MOV AL,20H 
   OUT  20H , AL         ;  в порт ведущего контроллера 8259A 
   POP AX 
   IRET

F9_pressed:
    MOV AH , 09H 
    MOV DX, OFFSET F9_MSG 
    INT 21H
    POP     BX 
    POP     CX 
    POP     AX 
    IRET
EXIT:  
;  Восстановление регистров и вызов старого обработчика без возврата    
   POP     BX 
   POP     CX 
   POP     AX 
   JMP  CS:OLD_INT9H      ; Вызов старого обработчика 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
; Часть инициализации 
INIT:    CLI                ; Запрет прерываний 
; Установка DS 
         PUSH CS 
         POP DS 
; Получение адреса старого обработчика 
         MOV  AH, 35H     
         MOV  AL, 09H    ; Номер прерывания 
         INT 21H 
;  Сохранение адреса старого обработчика 
         MOV     WORD  PTR  OLD_INT9H , BX    
         MOV     WORD  PTR  OLD_INT9H+2 , ES    
;  Установка нового обработчика в вектор прерывания 
         MOV     AH,25H   
         MOV     AL, 09H   ; Номер прерывания    
         MOV     DX, OFFSET   NEWINT9 
         INT     21H 
; Вывод сообщения о загрузке резидента 
         MOV AH , 09H 
         MOV DX, OFFSET MSG 
         INT    21H 
; Завершить и оставить резидентной (TSR) 
         MOV     AX, 3100H 
         MOV     DX, (init - begin +10FH)/16   ; Размер резидента  
         STI                 ; Разрешение прерываний 
         INT       21H 
;  Данные части инициализации 
MSG      DB 'Start TSR', 10,13,'$' 
CODEPR   ENDS 
END     BEGIN         