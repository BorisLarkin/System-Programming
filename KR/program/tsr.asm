CODEPR  SEGMENT PARA 
ASSUME CS:CODEPR , DS:CODEPR   
   ORG  100H         ; ������� PSP 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
; �������⭠� ���� 
BEGIN:    JMP   INIT              ; ���室 � ��� ���樠����樨 
;        ����� १����� 
OLD_INT9H DD  ?                 ; ���࠭���� ��ண� ��ࠡ��稪� 
F1_FLAG DB 1
F2_FLAG DB 1
F3_FLAG DB 1
F9_MSG      DB 'Larkin �. �., ��5-41, ���. 11', 10,13,'$' 
F2_RUS_ARR DB "�����"
F2_latin_ARR DB "LMNOP"

;   ���� ��ࠡ��稪 ���뢠��� 09� 
NEWINT9: 
   PUSH   AX             ; ���࠭���� �ᯮ��㥬�� ॣ���஢ 
   PUSH   CX    
   PUSH   BX 
   PUSH DX
;     ����� ᪠����� �� ���������� 
   IN     AL, 60H        ; ����� �� ���� 60 � �� ॣ���� AL 
   CMP   AL, 1           ; �஢�ઠ ᪠����� ESC �� ࠢ�� 1 
   JE ESC_pressed
   CMP AL, 43h
   JE F9_pressed
   CMP AL, 3Bh
   JE F1_pressed
   CMP AL, 3Ch
   JE F2_pressed
   CMP AL, 3Dh
   JE F3_pressed
   JMP    PROCESS           ;   ���室 �� ��ࠡ��� ᨬ����� 

ESC_pressed:
;      �뢮� �� �࠭ 10-� ᨬ����� ?�? � ������� BIOS �㭪樨 0AH ? 010H  
   IN  AL, 61H 
   OR AL, 10000000b     ; ��⠭���� ��� 7 ���� � 
   OUT 61H, AL 
   AND AL, 01111111b 
   OUT  61H, AL         ;  ��ᨬ ��� 7 ����  � (ᨬ��� ���⠭) 
 ;   �뢮� 楯�窨 10 ᨬ�����         
   MOV AH , 0AH 
   MOV AL, 'B' 
   MOV BH , 0 
   MOV CX, 10             ;��᫮ ᨬ����� 
   INT 10H               ; INT BIOS DOS 
   JMP Override_return

F9_pressed:
   MOV AL, 1
   MOV BH, 0
   MOV BL, 3
   MOV CX, 30 ;����� ��ப�
   MOV DH, 10
   MOV DL, 30
   PUSH DS ;���ᥣ���� � ES
   POP ES
   MOV BP, OFFSET F9_MSG ;����� ���ᥣ���� �� ��砫� ��ப�
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
   ;    ������ ����஫���� ���뢠��� �१ ���� 20� ᨣ��� (EOI = 20H)  
   POP DX
   POP     BX 
   POP     CX             
   MOV AL,20H 
   OUT  20H , AL         ;  � ���� ����饣� ����஫��� 8259A 
   POP AX 
   IRET
PROCESS:
   CLD
   CHECK_F3: ;��⨭��
      CMP F3_FLAG, 1
      JNE CHECK_F2
      PROCESS_F3:
         cmp AL,'A'  
         jb not_latin ;����� A
         cmp AL,'Z'
         jna latin ;�� ����� Z
         cmp AL,'a'  
         jb not_latin ;����� a
         cmp AL,'z'
         ja not_latin ;����� z
         latin:
            IRET ;�������� ��ࠡ���
         not_latin:
            JMP CHECK_F1 ;�� ����� ������� � F2
   CHECK_F2: ;��������� � ���ᨢ
      MOV DI, OFFSET F2_latin_ARR ;� AL ����� ⥪�騩 ᨬ���
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
         MOV AL, byte [F2_RUS_ARR + DL] ;ᮮ⢥�����騩 ᨬ��� �� ���ᨢ�
         POP DX

   CHECK_F1: ;���ᮢ�� �㪢� '�'
      CMP AL, '�'
      JZ found_f1
      JMP final_processing
      found_f1:
         ;���ᮢ��
         IRET
   
   final_processing:
      ;  ����⠭������� ॣ���஢ � �맮� ��ண� ��ࠡ��稪� ��� ������    
      POP DX
      POP     BX 
      POP     CX 
      POP     AX 
      JMP  CS:OLD_INT9H      ; �맮� ��ண� ��ࠡ��稪� 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
; ����� ���樠����樨 
INIT:    CLI                ; ����� ���뢠��� 
; ��⠭���� DS 
         PUSH CS 
         POP DS 
; ����祭�� ���� ��ண� ��ࠡ��稪� 
         MOV  AH, 35H     
         MOV  AL, 09H    ; ����� ���뢠��� 
         INT 21H 
;  ���࠭���� ���� ��ண� ��ࠡ��稪� 
         MOV     WORD  PTR  OLD_INT9H , BX    
         MOV     WORD  PTR  OLD_INT9H+2 , ES    
;  ��⠭���� ������ ��ࠡ��稪� � ����� ���뢠��� 
         MOV     AH,25H   
         MOV     AL, 09H   ; ����� ���뢠���    
         MOV     DX, OFFSET   NEWINT9 
         INT     21H 
; �뢮� ᮮ�饭�� � ����㧪� १����� 
         MOV AH , 09H 
         MOV DX, OFFSET MSG 
         INT    21H 
; �������� � ��⠢��� १����⭮� (TSR) 
         MOV     AX, 3100H 
         MOV     DX, (init - begin +10FH)/16   ; ������ १�����  
         STI                 ; ����襭�� ���뢠��� 
         INT       21H 
;  ����� ��� ���樠����樨 
MSG      DB 'Start TSR', 10,13,'$' 
CODEPR   ENDS 
END     BEGIN         