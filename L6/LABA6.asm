STSEG SEGMENT STACK 'STACK'
 DW 256 DUP(0)
STSEG ENDS

MYCODE SEGMENT 'CODE'
    ASSUME CS:MYCODE, DS:MYCODE, SS:STSEG
START:
; ����㧪� ᥣ���⭮�� ॣ���� ������ DS
    PUSH CS
    POP DS
mov save_psp , ES
; ���
   MOV AH , 51H
   int 21H
   MOV ES , BX
   mov save_psp , ES
; ����祭�� ���稪�  ES -  ���� PSP

    MOV AL , ES:128
    MOV COUNT , AL
; ���१�����
   MOV CL, Al
   MOV CH , 0
;;   PUSH ES
;;   POP DS

   PUSH CS
   POP  ES

   MOV DS , save_psp
   MOV SI , 129
   LEA DI , BUF
REP MOVSB
   PUSH CS
   POP DS
;;;;;;;; ��ᯥ�⪠ ��ࠬ��஢
   MOV BH , 0
   MOV BL , PAR11END - PAR11
   MOV BL , 10
   MOV BUF+[BX],'$'
   MOV AH, 09H
   LEA DX, BUF        ; ���������� ���������
													   INT 21h
   CALL LFCR
 ; C��������
   PUSH DS
   POP  ES
   MOV CH ,0
   MOV CL , COUNT
   MOV AL,PAR11END - PAR11
   CMP CL  , AL
   JBE  M5             ; ���� ����� ��ࠬ��஢ ����� ��ࢮ��!

M4:
   MOV AH, 09H
   LEA DX, MSGPAR2        ; ��ࠬ��� 2 ����
   INT 21h

M5:
   MOV CL , COUNT
   CLD
   CMP BUF , ' '
   JNE M11
   LEA DI , BUF+1
;   INC CL
   JMP M12
M11:
LEA DI , BUF
M12:
   LEA SI , PAR11
    MOV CX , 9
REP CMPSB
    JNE NOVALPAR

   MOV AH, 09H
   MOV DX , OFFSET MSG18        ; �ࠢ��쭮
   INT 21h
   CALL LFCR
   JMP M1

NOVALPAR:
   MOV AH, 09H
   MOV DX , OFFSET MSG181        ; �訡��
   INT 21h
   CALL LFCR
M1:

;;  INT 21h
;;;
   MOV AH, 09H
   MOV DX , OFFSET MSG17        ; ���������� ᫮��
   INT 21h
   CALL LFCR
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
; Procedyra vivoda simvola
save_psp dw 0
MSG1  DB '�訡�� ��ࠬ��஢!', 10,13, '$'
LET   DB 'A'
BUF   DB 127 DUP (0)
      DB '$',     10,13, '$'
COUNT DB 0
WORK  DB 127 DUP (0)
WCOUNT DW 0
TMPPAR1 DB '/c=y',0     ;;; c
TMPPAR12 DB '/c=n',0
TMPPAR2 DB '/H',0
TMPPAR22 DB '/?',0
TMPPAR3 DB '/K=<111>',0
CURRCOUNT DW 0
PAR1  DB  0
PAR2  DB  0
PAR3  DB  0
MSG0 DB '���祭�� ��ࠬ��஢:',10,13,'$'
MSGP1 DB '1-� ��ࠬ��� ����祭 /c=y ',10,13,'$'
MSGP12 DB '1-� ��ࠬ��� �몫�祭 /c=n ',10,13,'$'
MSGP2 DB '2-� ��ࠬ��� ����祭 /H ��� /? ',10,13,'$'
MSGP3 DB '3-� ��ࠬ��� ���� /K=<*****> ',10,13,'$'
MSGP31 DB '�騡�� ����㯠 ������ �ࠢ��쭮 ���! ',10,13,'$'
MSG17 db '����������!',10,13,'$'
;;PAR11  DB '����蠪��',00h
PAR11  DB '����蠪��'
par11END db 00h,'==='
MSG18 db '��ࠬ��� ��७ =  ����蠪��!',10,13,'$'
MSG181 DB '�訡�� ��ࠬ��� ! ',10,13,'$'
MSGPAR2 DB '��ࠬ��� 2 ���� ! ',10,13,'$'
MYCODE ENDS
       END START



