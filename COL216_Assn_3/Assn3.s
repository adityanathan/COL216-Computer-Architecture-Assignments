.extern expression, itoa
.equ SWI_Exit, 0x11
.equ SWI_Open, 0x66
.equ SWI_Rdstr, 0x6a
.equ SWI_Close, 0x68
.text

ldr r0, =asciz
mov r1, #0
swi SWI_Open
bcs FileError

mov r11, r0

LOOP: mov r0, r11
ldr r1, =buf
mov r2, #400
swi SWI_Rdstr
bcs L2

ldrb r6, [r1]

mov r0, r1
bl expression
mov r0, r3

cmp r0, #0
bgt L
sub r0, r0, #1


L:ldr r1, =buf
bl itoa

swi 0x02


ldr r0, =newline
swi 0x02


b LOOP

L2:mov r0, r11
swi SWI_Close
b exit

FileError: ldr r0, =error
swi 0x02
b exit

exit: swi SWI_Exit

.data
buf: .space 400
asciz: .asciz "assn3_input.txt"
newline: .asciz "\n"
error: .asciz "Failed to open input file." 
.end
