.text
mov r1, #16
mov r2, #8
mov r5, #4
mov r3, r2, LSL #3
mov r4, r2, LSL r5
mov r3, r2, LSR #3
mov r4, r2, LSR r5
mov r3, r2, ASR #3
mov r4, r2, ASR r5
mov r3, r2, ROR #3
mov r4, r2, ROR r5


add r3, r1, r2
sub r3, r1, r2
eor r3, r1, r2
orr r3, r1, r2
bic r3, r1, r2
rsb r3, r2, r1
add r1, r1, #16
add r2, r2, #8
sub r1, r1, #16
rsb r2, r2, #32
cmp r1, #16
adc r1, r1, #16
sbc r2, r2, #8
tst r1, #16
teq r2, #8
mov r1, #16
mvn r2, #8
adds r2, r2, #8
subs r3, r1, r2
swi 0x11
