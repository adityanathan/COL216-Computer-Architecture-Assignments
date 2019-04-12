.global expression
.equ SWI_Exit, 0x11
.text

consTail: str lr, [sp], #-4 @need to pass input variable x to consTail
mov r7, r1			@ x=r1 has been saved in r7
ldrb r8,[r0,#0]			@ch1=r8
sub r8, r8, #0x30
cmp r8,#0
blt L2
cmp r8,#9
bgt L2
mov r5,#10
mla r6,r7,r5,r8
mov r1,r6
add r0,r0,#1
bl consTail
L2: ldr pc, [sp,#4]! 		@consTail returns value x=r2

constant: str lr, [sp], #-4
ldrb r8,[r0,#0]			@ch2=r8
sub r8, r8, #0x30
mov r1, r8
add r0,r0,#1
bl consTail
ldr pc, [sp,#4]! 		@output of constant and consTail is in x=r1

term: str lr, [sp], #-4
ldrb r8,[r0,#0]
cmp r8, #0x28			@ch3=r8
bne L3
add r0,r0,#1
bl expression 			@ store result in var y
mov r1,r3			@return y=r3=r1
add r0,r0,#1
ldr pc, [sp,#4]! 
L3: bl constant
ldr pc, [sp,#4]! 		@ return y=x=r1

expTail: str lr, [sp], #-4 	@Need to pass int z to expTail
ldrb r8,[r0,#0]
cmp r8, #0x2A
beq MULTIPLY
cmp r8,#0x2B
beq ADD
cmp r8, #0x2D
beq SUBTRACT

ldr pc, [sp,#4]! @ return r3

ADD: str lr, [sp, #-4]
add r0,r0,#1
str r3, [sp], #-4
bl term
ldr r3, [sp,#4]!
add r3,r3,r1			@z=r3
bl expTail
ldr pc, [sp,#4]! @return r3

SUBTRACT: str lr, [sp], #-4
add r0,r0,#1
str r3, [sp], #-4
bl term
ldr r3, [sp,#4]!
sub r3,r3,r1
bl expTail
ldr pc, [sp,#4]! @return r3

MULTIPLY: str lr, [sp], #-4
add r0,r0,#1
str r3, [sp], #-4
bl term
ldr r3, [sp,#4]!
mul r6,r3,r1
mov r3, r6
bl expTail
ldr pc, [sp,#4]! @return r3

expression: str lr, [sp], #-4
bl term
mov r3,r1
bl expTail			@z=r3
ldr pc, [sp,#4]! 		@return z=r3

exit: swi SWI_Exit

.data
asciz: .asciz "+(21*(2*(52-(25*2))-3))"
.end