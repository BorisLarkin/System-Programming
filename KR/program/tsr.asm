;          Символы по нажатию ESC 
 
CODEPR  SEGMENT PARA 
         ASSUME CS:CODEPR , DS:CODEPR   
       ORG  100H         ; Область PSP 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
; Резидентная часть 
BEGIN:    JMP   INIT              ; Переход к части инициализации 
;        Данные резидента 
SAVEINT9 DD  ?                 ; Сохранение старого обработчика 
;   Новый обработчик прерывания 09Н 
NEWINT9: PUSH   AX             ; Сохранение используемых регистров 
   PUSH   CX    
   PUSH   BX 
;     Запрос сканкода из клавиатуры 
        IN     AL, 60H        ; Взять из порта 60 Н на регистр AL 
        CMP   AL, 1           ; Проверка сканкода ESC он равен 1 
        JNE    EXIT           ;   Переход если не ESC 
;      Вывод на экран 10-ти символов ’В’ с помощью BIOS функции 0AH – 010H  
   PUSH   AX    
   PUSH   BX 
   PUSH   CX 
   MOV AH , 0AH 
        MOV AL, 'B' 
        MOV BH , 0 
        MOV CX, 10             ; Число символов 
        INT 010H   
        POP     CX 
        POP     BX 
        POP     AX 
;  Восстановление регистров и вызов старого обработчика без возврата                   
EXIT:   POP     BX 
        POP     CX 
        POP     AX 
        JMP  CS:SAVEINT9      ; Вызов старого обработчика 
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
        MOV     WORD  PTR  SAVEINT9 , BX    
        MOV     WORD  PTR  SAVEINT9+2 , ES    
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