TITLE  ����蠪�� ��5-00
DATASG SEGMENT 'DATA'
TABLHEX DB '0123456789ABCDEF'
MSG DB '������ �⭠����筮� �᫮(HHHH, * - ����� �ணࠬ��):$'
BUF    DB  100 DUP( 0 )
DECW   DW  0
DATASG ENDS

STSEG SEGMENT STACK 'STACK'
 DW 256 DUP(0)
STSEG ENDS

MYCODE SEGMENT 'CODE'
    ASSUME CS:MYCODE, DS:DATASG, SS:STSEG
START:
; ����㧪� ᥣ���⭮�� ॣ���� ������ DS
    MOV AX, DATASG
    MOV DS, AX
;; ���� �஢�ન ����� *
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
; ���� ����� ��ப�
    CALL GETSIMB
    CMP AL, '*'
    JE MEND
; ���� ��. �᫠ � ����������� � BUF
     CALL HEXADR
;
     MOV DL, ' '
     CALL PUTCH
     MOV DL, '='
     CALL PUTCH
     MOV DL, ' '
     CALL PUTCH
; �뢮� ��⭠����筮�� �᫠
     CALL PRINTHEX
     MOV DL, ' '
     CALL PUTCH
     MOV DL, ' '
     CALL PUTCH
; ��ॢ�� � �����筮� � �����
     CALL DECPRINT
; ���� �뢮�� �⭠����筮� ��ப�
    CALL LFCR
LOOP METLOOP

MEND:
; �������� �����襭�� �ணࠬ��
;    MOV AH, 01H
;    INT 021H
; ���⪠ �࠭�
    MOV AH, 00H
    MOV AL, 03H
    INT  10H

; ��室 �� ��ࠬ��
    MOV AH, 4Ch
    MOV AL, 0
    INT 21H
; �த����� �ணࠬ��
HEXADR PROC
; �����⮢�� 横�� �����
     MOV SI , OFFSET BUF
     MOV CX , 4
; ����
MVVOD:
MCICL:
     CMP CX , 4
     JE MC1
     CALL GETSIMB
    CMP AL, '*'
    JE MEND
MC1:
; �஢�ઠ ᨬ���� �� �ࠢ��쭮���
     CMP AL , 30H
     JL MCICL
     CMP AL , 39H
     JLE MBUF
     CMP AL , 65
     JL MCICL
     CMP AL , 70
     JG MCICL
; ������ � ���� � �����
MBUF:
     MOV [SI], AL
     INC SI
; ����� ᨬ����
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
; ��ࢮ� � ��設��� �।�⠢�����
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
; ��ॢ�� � �����筮� �।�⠢�����
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
GETSIMB PROC
; enter simbol
    MOV AH, 08H
    INT 21H
    RET
GETSIMB ENDP
;
MYCODE ENDS

   END START



