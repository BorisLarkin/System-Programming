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
F9_MSG      DB 'Larkin Б. В., ИУ5-41, Вар. 11', 10,13,'$' 
F2_RUS_ARR DB "ЛМНОП"
F2_latin_ARR DB "LMNOP"

;   Новый обработчик прерывания 09Н 
NEWINT9: 
   PUSH   AX             ; Сохранение используемых регистров 
   PUSH   CX    
   PUSH   BX 
   PUSH DX
;     Запрос сканкода из клавиатуры 
   IN     AL, 60H        ; Взять из порта 60 Н на регистр AL 
   CMP   AL, 1           ; Проверка сканкода ESC он равен 1 
   JE ESC_pressed
   CMP AL, 43h
   JE F9_pressed
   CMP AL, 3Bh
   JE F1_pressed
   CMP AL, 3Ch
   JE F2_pressed
   CMP AL, 3Dh
   JE F3_pressed
   JMP    PROCESS           ;   Переход на обработку символов 

ESC_pressed:
;      Вывод на экран 10-ти символов ?В? с помощью BIOS функции 0AH ? 010H  
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
   INT 10H               ; INT BIOS DOS 
   JMP Override_return

F9_pressed:
   MOV AL, 1
   MOV BH, 0
   MOV BL, 3
   MOV CX, 30 ;Длина строки
   MOV DH, 10
   MOV DL, 30
   PUSH DS ;Датасегмент в ES
   POP ES
   MOV BP, OFFSET F9_MSG ;Оффсет датасегмента до начала строки
   MOV AH, 13h
   INT 10h
   JMP Override_return

F1_pressed:
   XOR F1_FLAG, 1
   JMP Override_return
F2_pressed:
   XOR F2_FLAG, 1
   JMP Override_return
F3_pressed:
   XOR F3_FLAG, 1
   JMP Override_return

Override_return:
   ;    Сигнал контроллеру прерываний через порт 20Н сигнал (EOI = 20H)  
   POP DX
   POP     BX 
   POP     CX             
   MOV AL,20H 
   OUT  20H , AL         ;  в порт ведущего контроллера 8259A 
   POP AX 
   IRET
PROCESS:
   CLD
   CHECK_F3: ;Латиница
      CMP F3_FLAG, 1
      JNE CHECK_F2
      PROCESS_F3:
         cmp AL,'A'  
         jb not_latin ;меньше A
         cmp AL,'Z'
         jna latin ;Не больше Z
         cmp AL,'a'  
         jb not_latin ;меньше a
         cmp AL,'z'
         ja not_latin ;больше z
         latin:
            IRET ;Закончить обработку
         not_latin:
            JMP CHECK_F1 ;Не можем попасть в F2
   CHECK_F2: ;Попадание в массив
      MOV DI, OFFSET F2_latin_ARR ;В AL лежит текущий символ
      MOV SI, DI
      MOV CX, 5
      REPNE SCASB
      JZ found_f2
      not_found_f2:
         JMP CHECK_F1
      found_f2:
         PUSH DX
         MOV DL, 5
         DEC DL, CX
         MOV AL, byte [F2_RUS_ARR + DL] ;соответствующий символ из массива
         POP DX

   CHECK_F1: ;Отрисовка буквы 'И'
      CMP AL, 'И'
      JZ found_f1
      JMP final_processing
      found_f1:
         ;Отрисовка
         IRET
   
   final_processing:
      ;  Восстановление регистров и вызов старого обработчика без возврата    
      POP DX
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