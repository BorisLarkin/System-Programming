STSEG SEGMENT STACK 'STACK'
   DW 256 DUP(0)
STSEG ENDS

MYCODE SEGMENT 'CODE'
   ASSUME CS:MYCODE, DS:MYCODE, SS:STSEG
START:
; ����㧪� ॣ���஢
   PUSH CS
   POP DS
   PUSH DS
   POP ES
   MOV AH , 51H ;����祭�� ID ⥪�饣� ����� (PSP ����)
   int 21H
   MOV ES , BX
   mov save_psp , ES
; ����祭�� ���稪�  ES
   MOV AL , ES:128
   DEC AX ;�� ���뢠�� ������騩 �஡��
   MOV COUNT , AL
; ���१�����
   MOV CL, AL
   MOV CH , 0
   PUSH CS

   POP  ES
   MOV DS , save_psp
   MOV SI , 130 ;�� �����㥬 �஡��
   LEA DI , BUF
   REP MOVSB
   PUSH CS
   POP DS
;;;;;;;;���������� ����
   MOV BH , 0
   MOV BL , COUNT
   MOV BUF+[BX],'$'
   MOV AH, 09H
   LEA DX, BUF
	INT 21h
   CALL LFCR

 ; C��������
   CLD ;���⪠ 䫠���
   MOV AL, ' '
   MOV CX, BX ;� BX ����� COUNT
   MOV BX, 0
   find_space:
      CMP [BUF+BX], AL ;�᫨ �஡�� => ����� ���1
      JE space_found
      INC BX
   loop find_space
   MOV space_index, 255 ;���祭��, �� ����饥 ��᫠
   JMP COMPARELEN

   space_found:
      MOV space_index, BL

COMPARELEN:
   ;�ࠢ����� �����
   MOV CL, 6 ;��ન� 
   CMP CL, space_index ;if 6: len=6
   JNE NotEqual

COMPARE:
   ;����� ��ୠ, �ࠢ������ �����⮢�
   CLD
   LEA SI, BUF
   LEA DI, PAR1
   REPE CMPSB
   JNZ NotEqual

   MOV AH, 09H
   MOV DX , OFFSET MSG1CORRECT        ; �ࠢ��쭮
   INT 21h
   JMP Par2Processing

NotEqual:
   CMP COUNT, CL
   JE COMPARE
   MOV AH, 09H
   MOV DX , OFFSET MSG1WRONG        ; �訡��
   INT 21h

Par2Processing:
   CMP space_index, 255
   JE NPAR2
   MOV AL, ' '
   MOV CX, COUNT-space_index
   MOV BH, 0
   MOV BL, space_index
   find_par2:
      CMP [BUF+BX], AL ;�᫨ �� �஡�� => ���� ���2
      JNZ YPAR2
      INC BX
   loop find_par2
NPAR2:
   MOV AH, 09H
   LEA DX, MSGNPAR2        ; ��ࠬ��� 2 ���
   INT 21h
   JMP PARPRINT

YPAR2:
   MOV AH, 09H
   LEA DX, MSGYPAR2        ; ��ࠬ��� 2 ����
   INT 21h

PARPRINT: ;������ ����������
   CALL LFCR
   MOV AH, 09H
   MOV DX , OFFSET MSGPRINT        ; ���������� ᫮��
   INT 21h
;;;;;;;;;;;;;;;;;;;;;;;
   MOV AH,09
   MOV DX , OFFSET BUF
   INT 21h

; �������� �����襭�� �ணࠬ��
   MOV AH, 01H
   INT 021H
; ��室 �� ��ࠬ��
   MOV AH, 4Ch
   MOV AL, 0
   INT 21H


; �த����� �ணࠬ��
;;;;;;;;;;;;;;    cmpsb
; ��楤�� �뢮�� ᨬ���� �� DL
PUTCH PROC
   MOV AH , 2
   INT 21H
   RET
PUTCH ENDP
; ��楤�� ��ॢ��� ��ப�
LFCR PROC
   MOV DL, 10
   CALL PUTCH
   MOV DL, 13
   CALL PUTCH
   RET
LFCR ENDP

save_psp dw 0
space_index db 0
MSG1  DB '�訡�� ��ࠬ��஢!', 10,13, '$'
BUF   DB 127 DUP (0) 
   DB '$', 10,13, '$'
COUNT DB 0
MSGPRINT db '����������!',10,13,'$'
PAR1  DB '��ન�',10,13,'$'
MSG1CORRECT db '���� ��ࠬ��� ��७ = ��ન�',10,13,'$'
MSG1WRONG DB '���� ��ࠬ��� ���ࠢ����!',10,13,'$'
MSGYPAR2 DB '��ன ��ࠬ��� ���� ! ',10,13,'$'
MSGNPAR2 DB '��ண� ��ࠬ��� ��� ! ',10,13,'$'
MYCODE ENDS
END START