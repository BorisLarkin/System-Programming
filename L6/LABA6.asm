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
;;;;;;;; ��ᯥ�⪠ ��ࠬ��஢
   MOV BH , 0
   MOV BL , COUNT
   MOV BUF+[BX],'$'
   MOV AH, 09H
   LEA DX, BUF        ; ���������� ���������
	INT 21h
   CALL LFCR

 ; C��������
   CLD ;���⪠ 䫠���
   LEA SI, BUF
   LEA DI, PAR1
   MOV CX, 6 ;��ન�
   REP CMPSB
   JNZ NotEqual

   ;ࠢ��
   MOV AL, ' '
   CMP [BUF+6], AL ;�᫨ �஡�� => ����� ���1
   JNE NotEqual

   MOV AH, 09H
   MOV DX , OFFSET MSG1CORRECT        ; �ࠢ��쭮
   INT 21h
   JMP Par2Processing

NotEqual:
   MOV AH, 09H
   MOV DX , OFFSET MSG1WRONG        ; �訡��
   INT 21h
   CALL LFCR

Par2Processing:
   MOV AL, ' '
   MOV CX, COUNT
   REP CMP [BUF+6+COUNT-CX], AL ;�᫨ �஡�� => ����� ���1
   MOV AH, 09H
   LEA DX, MSGPAR2        ; ��ࠬ��� 2 ����
   INT 21h


   MOV AH, 09H
   MOV DX , OFFSET MSGPRINT        ; ���������� ᫮��
   INT 21h
;;;;;;;;;;;;;;;;;;;;;;;
   MOV AH,09
   MOV DX , OFFSET BUF
   INT 21h
; �஢�ઠ ������ ��ࠬ��஢
; �������� �����襭�� �ணࠬ��
MEND2:
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
MSG1  DB '�訡�� ��ࠬ��஢!', 10,13, '$'
BUF   DB 127 DUP (0) 
   DB '$', 10,13, '$'
COUNT DB 0
MSGPRINT db '����������!',10,13,'$'
PAR1  DB '��ન�',10,13,'$'
MSG1CORRECT db '���� ��ࠬ��� ��७ = ��ન�',10,13,'$'
MSG1WRONG DB '���� ��ࠬ��� ���ࠢ����!',10,13,'$'
MSGPAR2 DB '��ன ��ࠬ��� ���� ! ',10,13,'$'
MYCODE ENDS
END START