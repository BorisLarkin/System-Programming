;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; tsr.asm - ���������
;
; ���ઠ:
;  tasm.exe /l tsr.asm
;  tlink /t /x tsr.obj
;
; �ਬ�砭��:
;  1) �������ਨ, ��稭��騥�� � ᨬ���� @ - ����, ��� ��� ������ �� ��ਠ��
;
; �����:
;  ���� ��. �.�. ��㬠��, ��5-44, 2013 �.
;   �����쥢 �.�.
;   ��⪨� �.�.
;   ����஢ �.�.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; �������⭠� ����
code segment	'code'
	assume	CS:code, DS:code
	org	100h
	_start:
	
	jmp _initTSR ; �� ��砫� �ணࠬ��
	
	; ����� १�����
 ; �����஢����

	ignoredChars 					DB	'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'	;ᯨ᮪ ������㥬�� ᨬ�����
	ignoredLength 				equ	$-ignoredChars				; ����� ��ப� ignoredChars
	ignoreEnabled 				DB	0							; 䫠� �㭪樨 �����஢���� �����
	translateFrom 				DB	'KVYJG'						;@ ᨬ���� ��� ������ (����� �� ����. �᪫����)
	translateTo 				DB	'�����'						;@ ᨬ���� �� ����� �㤥� ��� ������
	translateLength				equ	$-translateTo					; ����� ��ப� trasnlateFrom
	translateEnabled				DB	0							; 䫠� �㭪樨 ��ॢ���
	
	signaturePrintingEnabled 		DB	0							; 䫠� �㭪樨 �뢮�� ���ଠ樨 �� ����
	cursiveEnabled 				DB	0							; 䫠� ��ॢ��� ᨬ���� � ���ᨢ
	cursiveSymbol 				DB 00000000b          ;@ ᨬ��� �, ��⠢����� �� �����祪 (��� ���ᨢ�� ��ਠ��)
								DB 00000000b
								DB 01100011b
								DB 01100111b
								DB 01100111b
								DB 01101011b
								DB 01101011b
								DB 11001110b
								DB 11010110b
								DB 11010110b
								DB 11100110b
								DB 11100110b
								DB 11000110b
								DB 00000000b
								DB 00000000b
								DB 00000000b
	
	charToCursiveIndex 			DB '�'							;@ ᨬ��� ��� ������
	savedSymbol 					DB 16 dup(0FFh)
; ��६����� ��� �࠭���� ��ண� ᨬ����
	
	true 						equ	0FFh							; ����⠭� ��⨭����
	old_int9hOffset 				DW	?							; ���� ��ண� ��ࠡ��稪� int 9h
	old_int9hSegment 				DW	?							; ᥣ���� ��ண� ��ࠡ��稪� int 9h
	old_int1ChOffset 				DW	?							; ���� ��ண� ��ࠡ��稪� int 1Ch
	old_int1ChSegment 			DW	?							; ᥣ���� ��ண� ��ࠡ��稪� int 1Ch
	old_int2FhOffset 				DW	?							; ���� ��ண� ��ࠡ��稪� int 2Fh
	old_int2FhSegment 			DW	?							; ᥣ���� ��ண� ��ࠡ��稪� int 2Fh
	
	unloadTSR					DB	0 							; 1 - ���㧨�� १�����
	notLoadTSR					DB	0							; 1 - �� ����㦠��
	counter	  					DW	0
	printDelay					equ	7 							;@ ����প� ��। �뢮��� "������" � ᥪ㭤��
	printPos						DW	1 							;@ ��������� ������ �� �࠭�. 0 - ����, 1 - 業��, 2 - ���
	
	;@ �������� �� ᮡ�⢥��� �����. �ନ஢���� ⠡���� ���� �� ��ப� ����襩 ����� (1� ��ப�).
	signatureLine1				DB	179, '��ન� ����', 179

	Line1_length 					equ	$-signatureLine1
	signatureLine2				DB	179, '��5-41      ', 179
	Line2_length 					equ	$-signatureLine2
	signatureLine3				DB	179, '��ਠ�� #11 ', 179
	Line3_length 					equ	$-signatureLine3
; ��ࠢ��
	helpMsg DB '>tsr.com [/?]', 10, 13
			DB ' [/?] - �뢮� ������ �ࠢ��', 10, 13
			
			DB '  F1  - ����祭�� � �⪫�祭�� ���ᨢ���� �뢮�� ���᪮�� ᨬ���� �', 10, 13
			DB '  F2  - ����祭�� � �⪫�祭�� ���筮� ���䨪�樨 ����������(KVYJG -> �����)', 10, 13
			DB '  F3  - ����祭�� � �⪫�祭�� ०��� �����஢�� ����� ��⨭᪨� �㪢', 10, 13
			DB '  F9  - �뢮� ��� � ��㯯� �� ⠩���� � 業�� �࠭�', 10, 13
			
	helpMsg_length				equ  $-helpMsg
	errorParamMsg					DB	'�訡�� ��ࠬ��஢ ���������� ��ப�', 10, 13
	errorParamMsg_length			equ	$-errorParamMsg
	
	tableTop						DB	218, Line1_length-2 dup (196), 191
	tableTop_length 				equ	$-tableTop
	tableBottom					DB	192, Line1_length-2 dup (196), 217
	tableBottom_length 			equ  $-tableBottom
	
	; ᮮ�饭��		
	installedMsg					DB  '�������� ����㦥�!$'
	alreadyInstalledMsg			DB  '�������� 㦥 ����㦥�$'
	noMemMsg						DB  '�������筮 �����$'
	notInstalledMsg				DB  '�� 㤠���� ����㧨�� १�����$'
	
	removedMsg					DB  '�������� ���㦥�'
	removedMsg_length				equ	$-removedMsg
	
	noRemoveMsg					DB  '�� 㤠���� ���㧨�� १�����'
	noRemoveMsg_length			equ	$-noRemoveMsg
	
	f1_txt						DB	'F1'
	f2_txt						DB	'F2'
	f3_txt						DB	'F3'
	f9_txt						DB	'F9'
	fx_length					equ	$-f9_txt
	; �஢�ઠ ������
	changeFx proc
		push AX
		push BX
		push CX
		push DX
		push BP
		push ES
		xor BX, BX
		
		mov AH, 03h
		int 10h
		push DX
		
		push CS
		pop ES
		
	_checkF1:
		lea BP, f1_txt
		mov CX, fx_length
		mov BH, 0
		mov DH, 0
		mov DL, 78
		mov AX, 1301h
		
		cmp cursiveEnabled, true
		je _greenF1
		
		_redF1:
			mov BL, 01001111b ; red
			int 10h
			jmp _checkF2
		
		_greenF1:
			lea BP, f1_txt
			mov BL, 00101111b ; green
			int 10h
			
	_checkF2:
		lea BP, f2_txt
		mov CX, fx_length
		mov BH, 0
		mov DH, 1
		mov DL, 78
		mov AX, 1301h
		
		cmp translateEnabled, true
		je _greenF2
		
		_redF2:
			mov BL, 01001111b ; red
			int 10h
			jmp _checkF3
		
		_greenF2:
			mov BL, 00101111b ; green
			int 10h
		
	_checkF3:
		lea BP, f3_txt
		mov CX, fx_length
		mov BH, 0
		mov DH, 2
		mov DL, 78
		mov AX, 1301h
		
		cmp ignoreEnabled, true
		je _greenF3
		
		_redF3:
			mov BL, 01001111b ; red
			int 10h
			jmp _checkf9
		
		_greenF3:
			mov BL, 00101111b ; green
			int 10h
			
	_checkf9:
		lea BP, f9_txt
		mov CX, fx_length
		mov BH, 0
		mov DH, 3
		mov DL, 78
		mov AX, 1301h
		
		cmp signaturePrintingEnabled, true
		je _greenf9
		
		_redf9:
			mov BL, 01001111b ; red
			int 10h
			jmp _outFx
		
		_greenf9:
			mov BL, 00101111b ; green
			int 10h
			
	_outFx:
		pop DX
		mov AH, 02h
		int 10h
		
		pop ES
		pop BP
		pop DX
		pop CX
		pop BX
		pop AX
		ret
	changeFx endp
		; ���� ��ࠡ��稪  new_int9h

    ;���� ��ࠡ��稪
    new_int9h proc far
		; ��࠭塞 ���祭�� ���, �����塞�� ॣ���஢ � ���
		push SI
		push AX
		push BX
		push CX
		push DX
		push ES
		push DS
		; ᨭ�஭����㥬 CS � DS
		push CS
		pop	DS

		mov	AX, 40h ; 40h-ᥣ����,��� �࠭���� 䫠�� ���-� ����������, �����. ���� ����� 
		mov	ES, AX
		in	AL, 60h	; �����뢠�� � AL ᪠�-��� ����⮩ ������
		
		;@ �஢�ઠ �� Ctrl+U, ⮫쪮 ��� ��5-41
		cmp	AL, 22	; �뫠 ����� ������ U?
		jne	_test_Fx
		mov	AH, ES:[17h]     ; 䫠�� ����������
		and	AH, 00001111b
		cmp	AH, 00000100b	; �� �� ����� ctrl?
		jne	_test_Fx
		; ���㧪�
			mov AH, 0FFh
			mov AL, 01h
			int 2Fh
			; �����蠥� ��ࠡ��� ������
			; ����� � ���⮬ �/�

			in	AL, 61h	;����஫��� ���ﭨ� ����������
			or	AL, 10000000b	;����⨬, �� ������� ������
			out	61h, AL
			and	AL, 01111111b	;����⨬, �� ������� ����⨫�
			out	61h, AL
			mov	AL, 20h
			out	20h, AL	;��ࠢ�� � ����஫��� ���뢠��� �ਧ��� ���� ���뢠���
			
			; ��室��
			jmp _quit
		
		
		;�஢�ઠ F1-f9
		_test_Fx:
		sub AL, 58 ; � AL ⥯��� ����� �㭪樮���쭮� ������
		_F9: ;signaturePrint
			cmp AL, 9 ; F9
			jne _F1
			not signaturePrintingEnabled
			call changeFx
			jmp _translate_or_ignore
		_F1: ;Cursive
			cmp AL, 1 ; F1
			jne _F2
			not cursiveEnabled
			call changeFx
			call setCursive ; ��ॢ�� ᨬ���� � ���ᨢ � ���⭮ � ����ᨬ��� �� 䫠�� cursiveEnabled
			jmp _translate_or_ignore
		_F2: ;translate
			cmp AL, 2 ; F2
			jne _F3
			not translateEnabled
			call changeFx
			jmp _translate_or_ignore
		_F3: ;ignore
			cmp AL, 3 ; F3
			jne _translate_or_ignore
			not ignoreEnabled
			call changeFx
			jmp _translate_or_ignore
						
		;�����஢���� � ��ॢ��
		_translate_or_ignore:
	
; �맮� ��ண� ��ࠡ��稪�  old_int9hOffset	

		Pushf

		call dword ptr CS:[old_int9hOffset] ; ��뢠�� �⠭����� ��ࠡ��稪 ���뢠���
		mov	AX, 40h 	; 40h-ᥣ����,��� �࠭���� 䫠�� ���-� �����,�����. ���� ����� 
; ����� � ��������ன

		mov	ES, AX
		mov	BX, ES:[1Ch]	; ���� 墮��
		dec	BX	; ᬥ�⨬�� ����� � ��᫥�����
		dec	BX	; ����񭭮�� ᨬ����
		cmp	BX, 1Eh	; �� ��諨 �� �� �� �।��� ����?
		jae	_go
		mov	BX, 3Ch	; 墮�� ��襫 �� �।��� ����, ����� ��᫥���� ������ ᨬ���
				    ; ��室����	� ���� ����

	_go:		
		mov DX, ES:[BX] ; � DX 0 ������ ᨬ���
		;����祭 �� ०�� �����஢�� �����?
		cmp ignoreEnabled, true
		jne _check_translate
		; �����஢�� ����� ᨬ�����

		; ��, ����祭
		mov SI, 0
		mov CX, ignoredLength ;���-�� ������㥬�� ᨬ�����
		
		; �஢��塞, ��������� �� ⥪�騩 ᨬ��� � ᯨ᪥ ������㥬��
	_check_ignored:
		cmp DL,ignoredChars[SI]
		je _block
		inc SI
	loop _check_ignored
		jmp _check_translate
		
	; ������㥬
	_block:
		mov ES:[1Ch], BX ;�����஢�� ����� ᨬ����
		jmp _quit
			; ������ ᨬ�����

	_check_translate:
		; ����祭 �� ०�� ��ॢ���?
		cmp translateEnabled, true
		jne _quit
		
		; ��, ����祭
		mov SI, 0
		mov CX, translateLength ; ���-�� ᨬ����� ��� ��ॢ���
		; �஢��塞, ��������� �� ⥪�騩 ᨬ��� � ᯨ᪥ ��� ��ॢ���
		_check_translate_loop:
			cmp DL, translateFrom[SI]
			je _translate
			inc SI
		loop _check_translate_loop
		jmp _quit
		
		; ��ॢ����
		_translate:		
			xor AX, AX
			mov AL, translateTo[SI]
			mov ES:[BX], AX	; ������ ᨬ����
			
	_quit:
		; ����⠭�������� �� ॣ�����
		pop	DS
		pop	ES
		pop DX
		pop CX
		pop	BX
		pop	AX
		pop SI
		iret
new_int9h endp  

;=== ��ࠡ��稪 ���뢠��� int 1Ch ===;
;=== ��뢠���� ����� 55 �� ===;
; ���� ��ࠡ��稪  new_int1Ch

new_int1Ch proc far
	push AX
	push CS
	pop DS
; �맮� ��ண� ��ࠡ��稪�  old_int1ChOffset	

	pushf
	call dword ptr CS:[old_int1ChOffset]
	
	cmp signaturePrintingEnabled, true ; �᫨ ����� �ࠢ����� ������ (� ������ ��砥 F1)
	jne _notToPrint		
	
; ����஫� ���稪� 横���

		cmp counter, printDelay*1000/55 + 1 ; �᫨ ���-�� "⠪⮢" �������⭮ %printDelay% ᥪ㭤��
		je _letsPrint
		
		jmp _dontPrint
		
		_letsPrint:
			not signaturePrintingEnabled
			mov counter, 0
			call printSignature
		
		_dontPrint:
			add counter, 1
		
	_notToPrint:
	
	pop AX
	
	iret
new_int1Ch endp

;=== ��ࠡ��稪 ���뢠��� int 2Fh ===;
;=== ��㦨� ���:
;===  1) �஢�ન 䠪� ������⢨� TSR � ����� (�� AH=0FFh, AL=0)
;===     �㤥� ������� AH='i' � ��砥, �᫨ TSR 㦥 ����㦥�
;===  2) ���㧪� TSR �� ����� (�� AH=0FFh, AL=1)
;=== 
 ; ���� ��ࠡ��稪  new_int2Fh

new_int2Fh proc
	cmp	AH, 0FFh	;��� �㭪��?
	jne	_2Fh_std	;��� - �� ���� ��ࠡ��稪
	cmp	AL, 0	;����㭪�� �஢�ન, ����㦥� �� १����� � ������?
	je	_already_installed
	cmp	AL, 1	;����㭪�� ���㧪� �� �����?
	je	_uninstall	
	jmp	_2Fh_std	;��� - �� ���� ��ࠡ��稪
	
_2Fh_std:
; �맮� ��ண� ��ࠡ��稪�  old_int2FhOffset	

	jmp	dword ptr CS:[old_int2FhOffset]	;�맮� ��ண� ��ࠡ��稪�
	
_already_installed:
		mov	AH, 'i'	;���� 'i', �᫨ १����� ����㦥�	� ������
		iret
	
_uninstall:
	push	DS
	push	ES
	push	DX
	push	BX
	
	xor BX, BX
	
	; CS = ES, ��� ����㯠 � ��६����
	push CS
	pop ES
; ���㧪� १�����	

	mov	AX, 2509h
	mov DX, ES:old_int9hOffset         ; �����頥� ����� ���뢠���
    mov DS, ES:old_int9hSegment        ; �� ����
	int	21h
	
	mov	AX, 251Ch
	mov DX, ES:old_int1ChOffset         ; �����頥� ����� ���뢠���
    mov DS, ES:old_int1ChSegment        ; �� ����
	int	21h

	mov	AX, 252Fh
	mov DX, ES:old_int2FhOffset         ; �����頥� ����� ���뢠���
    mov DS, ES:old_int2FhSegment        ; �� ����
	int	21h

	mov	ES, CS:2Ch	; ����㧨� � ES ���� ���㦥���			
	mov	AH, 49h		; ���㧨� �� ����� ���㦥���
	int	21h
	jc _notRemove
	
	push	CS
	pop	ES	;� ES - ���� १����⭮� �ணࠬ��
	mov	AH, 49h  ;���㧨� �� ����� १�����
	int	21h
	jc _notRemove
	jmp _unloaded
	
_notRemove: ; �� 㤠���� �믮����� ���㧪�
    ; �뢮� ᮮ�饭�� � ��㤠筮� ���㧪�
	mov AH, 03h					; ����砥� ������ �����
	int 10h
	lea BP, noRemoveMsg
	mov CX, noRemoveMsg_length
	mov BL, 0111b
	mov AX, 1301h
	int 10h
	jmp _2Fh_exit
	
_unloaded: ; ���㧪� ��諠 �ᯥ譮
    ; �뢮� ᮮ�饭�� �� 㤠筮� ���㧪�
	mov AH, 03h					; ����砥� ������ �����
	int 10h
	lea BP, removedMsg
	mov CX, removedMsg_length
	mov BL, 0111b
	mov AX, 1301h
	int 10h
	
_2Fh_exit:
	pop BX
	pop	DX
	pop	ES
	pop	DS
	iret
new_int2Fh endp

;=== ��楤�� �뢮�� ������ (���, ��㯯�)
;=== ����ࠨ������ ���祭�ﬨ ��६����� � ��砫� ��室����
;===
; �뢮� ������	

printSignature proc
	push AX
	push DX
	push CX
	push BX
	push ES
	push SP
	push BP
	push SI
	push DI

	xor AX, AX
	xor BX, BX
	xor DX, DX
	
	mov AH, 03h						;�⥭�� ⥪�饩 ����樨 �����
	int 10h
	push DX							;����頥� ���ଠ�� � ��������� ����� � �⥪
	
	cmp printPos, 0
	je _printTop
	
	cmp printPos, 1
	je _printCenter
	
	cmp printPos, 2
	je _printBottom
	
	;�� �᫠ �����࠭� �� ����...
	_printTop:
		mov DH, 0
		mov DL, 15
		jmp _actualPrint
	
	_printCenter:
		mov DH, 9
		mov DL, 30
		jmp _actualPrint
		
	_printBottom:
		mov DH, 19
		mov DL, 15
		jmp _actualPrint
		
	_actualPrint:	
		mov AH, 0Fh					;�⥭�� ⥪�饣� �����०���. � BH - ⥪��� ��࠭��
		int 10h

		push CS						
		pop ES						;㪠�뢠�� ES �� CS
		
		;�뢮� '�����誨' ⠡����
		push DX
		lea BP, tableTop				;����頥� � BP 㪠��⥫� �� �뢮����� ��ப�
		mov CX, tableTop_length		;� CX - ����� ��ப�
		mov BL, 0111b 				;梥� �뢮������ ⥪�� ref: http://en.wikipedia.org/wiki/BIOS_color_attributes
		mov AX, 1301h					;AH=13h - ����� �-��, AL=01h - ����� ��६�頥��� �� �뢮�� ������� �� ᨬ����� ��ப�
		int 10h
		pop DX
		inc DH
		
		
		;�뢮� ��ࢮ� �����
		push DX
		lea BP, signatureLine1
		mov CX, Line1_length
		mov BL, 0111b
		mov AX, 1301h
		int 10h
		pop DX
		inc DH
		
		;�뢮� ��ன �����
		push DX
		lea BP, signatureLine2
		mov CX, Line2_length
		mov BL, 0111b
		mov AX, 1301h
		int 10h
		pop DX
		inc DH
		
		;�뢮� ���쥩 �����
		push DX
		lea BP, signatureLine3
		mov CX, Line3_length
		mov BL, 0111b
		mov AX, 1301h
		int 10h
		pop DX
		inc DH
		
		;�뢮� '����' ⠡����
		push DX
		lea BP, tableBottom
		mov CX, tableBottom_length
		mov BL, 0111b
		mov AX, 1301h
		int 10h
		pop DX
		inc DH
		
		xor BX, BX
		pop DX						;����⠭�������� �� �⥪� �०��� ��������� �����
		mov AH, 02h					;���塞 ��������� ����� �� ��ࢮ��砫쭮�
		int 10h
		call changeFx
		
	pop DI
	pop SI
	pop BP
	pop SP
	pop ES
	pop BX
	pop CX
	pop DX
	pop AX
	
	ret
printSignature endp
; �����  ����	

;=== �㭪��, ����� � ����ᨬ��� �� 䫠�� cursiveEnabled ����� ����⠭�� ᨬ���� � ���ᨢ� �� ���筮� � ������
;=== ���� ᬥ�� �ந�室�� � ��楤�� changeFont, � ����� �����⠢�������� �����
setCursive proc
	push ES ; ��࠭塞 ॣ�����
	push AX
	push CS
	pop ES

	cmp cursiveEnabled, true
	jne _restoreSymbol
	; �᫨ 䫠� ࠢ�� true, �믮��塞 ������ ᨬ���� �� ���ᨢ�� ��ਠ��,
	; �।���⥫쭮 ��࠭�� ���� ᨬ��� � savedSymbol
	
	call saveFont
	mov CL, charToCursiveIndex
_shifTtable:
	; �� ����砥� � BP ⠡���� ��� ᨬ�����. ���� 㪠�뢠�� �� ᨬ��� 0
	; ���⮬� ��� ᮢ����� ᤢ�� 16*X - ��� X - ��� ᨬ����
	add BP, 16
	loop _shiftTable
	
	; �p� savefont ᬥ頥��� p�����p ES
	; ���⮬y �p�室���� ������ ⠪�� ��娭�樨, �⮡� 
	; ������� ���y祭�� ����� � savedSymbol
	; swap(ES, DS) � ��࠭���� ��ண� ���祭�� DS
	push DS
	pop AX
	push ES
	pop DS
	push AX
	pop ES
	push AX

	mov SI, BP
	lea DI, savedSymbol
	; ��p��塞 � ��p�����y� savedSymbol
	; ⠡���y �y����� ᨬ����
	mov CX, 16
	; movsb �� DS:SI � ES:DI
	rep movsb
	; ��室�� ����樨 ᥣ���⮢ ����p�饭�	
	pop DS ; ����⠭������� DS

	; ������� ����ᠭ�� ᨬ���� �� �ypᨢ
	mov CX, 1
	mov DH, 0
	mov DL, charToCursiveIndex
	lea BP, cursiveSymbol
	call changeFont
	jmp _exitSetCursive
; ����⠭�������  ����	
	
_restoreSymbol:	
	; �᫨ 䫠� ࠢ�� 0, �믮��塞 ������ ���ᨢ���� ᨬ���� �� ���� ��ਠ��

	mov CX, 1
	mov DH, 0
	mov DL, charToCursiveIndex
	lea bp, savedSymbol
	call changeFont
	
_exitSetCursive:
	pop AX
	pop ES
	ret
setCursive endp	
	
;=== �㭪�� ᬥ�� ����⠭�� ᨬ���� (���ᨢ/��ଠ�쭮�)
;===
; *** �室�� �����
; DL = ����� ᨬ���� ��� ������
; CX = ���-�� ᨬ����� �����塞�� ����ࠦ���� ᨬ�����
; (��稭�� � ᨬ���� 㪠������� � DX)
; ES:bp = ���� ⠡����
;
; *** ���ᠭ�� ࠡ��� ��楤���
; �ந�室�� �맮� int 10h (������ࢨ�)
; � �㭪樥� AH = 11h (�㭪樨 ������������)
; ��ࠬ��� AL = 0 ᮮ�頥�, �� �㤥� �������� ����ࠦ����
; ᨬ���� ��� ⥪�饣� ����
; � �����, ����� AL = 1 ��� 2, �㤥� �������� ����ࠦ����
; ⮫쪮 ��� ��।������� ���� (8x14 � 8x8 ᮮ⢥��⢥���)
; ��ࠬ��� BH = 0Eh ᮮ�頥�, �� �� ��।����� ������� ����ࠦ���� ᨬ����
; ��室���� �� 14 ���� (०�� 8x14 ��� ��� ࠧ 14 ����)
; ��ࠬ��� BL = 0 - ���� ���� ��� ����㧪� (�� 0 �� 4)
;
; *** १����
; ����ࠦ���� 㪠�������(��) ᨬ����(��) �㤥� ��������
; �� �।�������� ���짮��⥫��.
; ��������� �����࣭���� �� ᨬ����, ��室�騥�� �� �࠭�,
; � ���� �᫨ ����ࠦ���� ��������, ���� ��ਠ�� ����� 㦥 �� �����

changeFont proc
	push AX
	push BX
	mov AX, 1100h
	mov BX, 1000h
	int 10h
	pop AX
	pop BX
	ret
changeFont endp

;=== �㭪�� ��࠭���� ��ଠ�쭮�� ����⠭�� ᨬ����
;===
; *** �室�� �����
; BH - ⨯ �����頥��� ᨬ���쭮� ⠡����
;   0 - ⠡��� �� int 1fh
;   1 - ⠡��� �� int 44h
;   2-5 - ⠡��� �� 8x14, 8x8, 8x8 (top), 9x14
;   6 - 8x16
;
; *** ���ᠭ�� ࠡ��� ��楤���
; �ந�室�� �맮� int 10h (������ࢨ�)
; � �㭪樥� AH = 11h (�㭪樨 ������������)
; ��ࠬ��� AL = 30 - ����㭪�� ����祭�� ���ଠ樨 � EGA
;
; *** १����
; � ES:BP ��室���� ⠡��� ᨬ����� (������)
; � CX ��室���� ���� �� ᨬ���
; � DL ������⢮ �࠭��� ��ப
; �����! �ந�室�� ᤢ�� ॣ���� ES
; ( ES �⠭������ ࠢ�� C000h )

saveFont proc
	push AX
	push BX
	mov AX, 1130h
	mov BX, 0600h
	int 10h
	pop AX
	pop BX
	ret
saveFont endp


;=== ��� ��稭����� �믮������ �᭮���� ��� �ணࠬ�� ===;
;===
; ����� ���樠����樨

_initTSR:                         	; ���� १�����
	mov AH, 03h
	int 10h
	push DX
	mov AH,00h					; ��⠭���� �����०��� (83h  ⥪��  80x25  16/8  CGA,EGA  b800  Comp,RGB,Enhanced), ��� ���⪨ �࠭�
	mov AL,83h
	int 10h
	pop DX
	mov AH, 02h
	int 10h
	
; ���� ����� ���樠����樨
	
    call commandParamsParser    
	mov AX,3509h                    ; ������� � ES:BX ����� 09
    int 21h                         ; ���뢠���
	
	;@ === �������� १����� �� ����� ===
	cmp unloadTSR, true
	je _removingOnParameter
	jmp _notRemovingNow
; �஢�ઠ ����㧪�

	_removingOnParameter:
		mov AH, 0FFh
		mov AL, 0
		int 2Fh
		cmp AH, 'i'  ; �஢�ઠ ⮣�, ����㦥�� �� 㦥 �ணࠬ��
		je _remove 
		mov AH, 09h				
		lea DX, notInstalledMsg	
		int 21h					
		int 20h					
	 
	_notRemovingNow:
	
	cmp notLoadTSR, true			; �᫨ �뫠 �뢥���� �ࠢ��
	je _exit_tmp						; ���� ��室��


	;@ �᫨ ����室��� ���㦠�� �� ��ࠬ���� ���������� ��ப�, � ��⠢�塞 ��
	mov AH, 0FFh
	mov AL, 0
	int 2Fh
	cmp AH, 'i'  ; �஢�ઠ ⮣�, ����㦥�� �� 㦥 �ணࠬ��
	je _alreadyInstalled
    
	jmp _tmp
	
	_exit_tmp:
		jmp _exit
	
	_tmp:
	push ES
; �஢�ઠ ������ �����

    mov AX, DS:[2Ch]                ; psp
    mov ES, AX
    mov AH, 49h                     ; 墠�� ����� �⮡ �������
    int 21h                         ; १����⮬?
    pop ES
    jc _notMem                      ; �� 墠⨫� ? ��室��
; ���࠭���� ����� ����஢ � ��⠭���� ����� 

	
	;== int 09h ==;

	mov	word ptr CS:old_int9hOffset, BX
	mov	word ptr CS:old_int9hSegment, ES
    mov AX, 2509h                   ; ��⠭���� ����� �� 09
    mov DX, offset new_int9h            ; ���뢠���
    int 21h
	
	;== int 1Ch ==;
	mov AX,351Ch                    ; ������� � ES:BX ����� 1C
    int 21h                         ; ���뢠���
	mov	word ptr CS:old_int1ChOffset, BX
	mov	word ptr CS:old_int1ChSegment, ES
	mov AX, 251Ch                   ; ��⠭���� ����� �� 1C
	mov DX, offset new_int1Ch            ; ���뢠���
	int 21h
	
	;== int 2Fh ==;
	mov AX,352Fh                    ; ������� � ES:BX ����� 1C
    int 21h                         ; ���뢠���
	mov	word ptr CS:old_int2FhOffset, BX
	mov	word ptr CS:old_int2FhSegment, ES
	mov AX, 252Fh                   ; ��⠭���� ����� �� 2F
	mov DX, offset new_int2Fh            ; ���뢠���
	int 21h

	call changeFx
    mov DX, offset installedMsg         ; �뢮��� �� �� ��
    mov AH, 9
    int 21h
; ��⠢��� � �� १����⮬ (027H)

    mov DX, offset _initTSR       ; ��⠥��� � ����� १����⮬
    int 27h                         ; � ��室��
    ; ����� �᭮���� �ணࠬ��  
; ���㧪� १����� (ᨣ��� � TSR)

_remove: ; ���㧪� �ணࠬ�� �� �����
	mov AH, 0FFh
	mov AL, 1
	int 2Fh
	jmp _exit
_alreadyInstalled:
	mov AH, 09h
	lea DX, alreadyInstalledMsg
	int 21h
	jmp _exit
_notMem:                            ; �� 墠⠥� �����, �⮡� ������� १����⮬
    mov DX, offset noMemMsg
    mov AH, 9
    int 21h
_exit:                               ; ��室
    int 20h

;=== ��楤�� �஢�ન ��ࠬ��஢ ���. ��ப� ===;
;===
; �஢�ઠ � ࠧ��� ��ࠬ��஢

commandParamsParser proc
	push CS
	pop ES
	mov unloadTSR, 0
	mov notLoadTSR, 0
	
	mov SI, 80h   				;SI=ᬥ饭�� ��������� ��ப�.
	lodsb        					;����稬 ���-�� ᨬ�����.
	or AL, AL     				;�᫨ 0 ᨬ����� �������, 
	jz _exitHelp   				;� �� � ���浪�. 

	_nextChar:
	
	inc SI       					;������ SI 㪠�뢠�� �� ���� ᨬ��� ��ப�.
	
	cmp [SI], BYTE ptr 13
	je _exitHelp
	
	
		lodsw       				;����砥� ��� ᨬ����
		cmp AX, '?/' 				;�� '/?' (����� �ᯮ������ � ���⭮� ���浪, �.�. AL:AH ����� AH:AL)
		je _question
		cmp AX, 'u/'
		je _finishTSR
		jmp _exitHelp
; �뢮� �ࠢ��
   

	_question:
		; �뢮� ��ப� �����
			mov AH,03
			int 10h	
			lea BP, helpMsg
			mov CX, helpMsg_length
			mov BL, 0111b
			mov AX, 1301h
			int 10h
		; ����� �뢮�� ��ப� �����
		not notLoadTSR	        ;䫠� ⮣�, �� ����室��� �� ����㦠�� १�����
		jmp _nextChar
	
	;@ === �������� १����� �� ����� ===
	;@ �᫨ �� ��ਠ��� ����室��� ���㦠�� १����� �� ��ࠬ���� '/u' ���������� ��ப�, 
	;@ �㦭� �ᯮ�짮���� ᫥���騩 ���, � ��⠫��� ����� ����室��� ����������஢��� 
	;@ ��� ���, �஬� �������� ��⪨! (�� ������� ����� ���������� � �� ��⪨, �� �����⭮ ��ᬮ���� �ᯮ�짮�����)
	_finishTSR:
		;not unloadTSR		      ;䫠� ⮣�, �� ����室��� ��㧨�� १�����
		;jmp _nextChar

	jmp _exitHelp

	_errorParam:
		;�뢮� ��ப�
			mov AH,03
			int 10h	
			lea BP, CS:errorParamMsg
			mov CX, errorParamMsg_length
			mov BL, 0111b
			mov AX, 1301h
			int 10h
		;����� �뢮�� ��ப�
	_exitHelp:
	ret
commandParamsParser endp

code ends

end _start
; �����  ��� ���樠����樨

