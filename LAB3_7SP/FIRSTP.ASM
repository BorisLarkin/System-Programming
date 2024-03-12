mycode SEGMENT 'code'
 assume cs:mycode, ds:mycode
 assume ss:stseg
;; declaration
SUM  DW 0
COUNT DB 0
;;
main proc
;
 PUSH CS
 POP DS
;;
 MOV AX, 0AFh
 MOV BL, 10h
 MOV AX, SUM
 ADD AX, 5
 MOV SUM, AX
;;
 MOV  COUNT,15
 MOV AX , SUM
 XOR BX , BX
 MOV BL , COUNT
 ADD AX , BX
 MOV SUM , AX

;;;

mov dl, 'A'
 call displ
 call crlf
; выход с ожиданием
 call kbin
 mov al, 0
 mov ah, 4ch
 int 21h
main endp
;---------
; Вывод символа
;---------
displ proc
 mov ah, 2
 int 21h
 ret
displ endp
;---------
;Ожидание
;---------
kbin proc
 mov ah, 08h
 int 21h
 mov ah, 2
 mov dl, al
 int 21h
 ret
kbin endp
;---------
; Перевод строки
;---------
crlf proc
 mov dl, 0Ah
 call displ
 mov dl, 0Dh
 call displ
 ret
crlf endp
;---------
; Очистка экрана
;---------
kmove proc
;---------
mov ah, 08h
int 21h
ret
kmove endp
;-------------------
mycode ends
;-------
stseg segment stack 'stack'
 dw 256 dup(0)
stseg ends
;-------
end main



