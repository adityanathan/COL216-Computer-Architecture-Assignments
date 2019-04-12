.equ SWI_Exit, 0x11
.text
add r1, r2, r3, LSR r0
mov r2, #0x00
mov r7, #10
ldr r0, =MyExp
ldrb r1, [r0, #0]
cmp r1, #0x00
beq s
cmp r1, #0x30
blt s
cmp r1, #0x39
bgt s
sub r1, r1, #0x30
mov r5, r1

LOOP:add r0, r0, #1
ldrb r1, [r0, #0]
cmp r1, #0x00
bne D
cmp r2, #0x00
beq s
cmp r2, #0x2b
bne B
add r5, r5, r3
b s
B:cmp r2, #0x2d
bne C
sub r5, r5, r3
b s
C:cmp r2, #0x2a
mov r9, r5
mul r5, r9, r3
b s

D:cmp r1, #0x2b
beq OPERATOR
H:cmp r1, #0x2d
beq OPERATOR
I:cmp r1, #0x2a
bne NUMBER

OPERATOR:cmp r2, #0x2b
bne E
add r5, r5, r3
E:cmp r2, #0x2d
bne F
sub r5, r5, r3
F:cmp r2, #0x2a
bne G
mov r9, r5
mul r5, r9, r3
G:mov r2, r1
mov r3, #0x0
b NEXT

NUMBER:cmp r1, #0x30
blt s
cmp r1, #0x39
bgt s

sub r6, r1, #0x30
cmp r2, #0x00
bne SECOND
FIRST: mov r9, r5
mul r5, r9, r7
add r5, r5, r6
b NEXT
SECOND: mov r9, r3
mul r3, r9, r7
add r3, r3, r6

NEXT:b LOOP

s:swi SWI_Exit
.data
MyExp: .asciz "21-31"
.end
