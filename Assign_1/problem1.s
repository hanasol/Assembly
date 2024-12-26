	AREA ARMex, CODE, READONLY
	ENTRY
	
start
	LDR r0, TEMPADDR1
	MOV r1, #1
	MOV r1, r1, LSL #1;r1*2
	ADD r1, r1, r1, LSL #1;r1*3
	MOV r1, r1, LSL #2;r1*4
	ADD r1, r1, r1, LSL #2;r1*5
	MOV r2, r1, LSL #1;r2=r1*2
	ADD r1, r2, r1, LSL #2;r2+r1*4=r1*6
	RSB r1, r1, r1, LSL #3;r1*8-r1=r1*7
	MOV r1, r1, LSL #3;r1*8
	ADD r1, r1, LSL #3;r1*9
	MOV r2, r1, LSL #1;r2=r1*2
	ADD r1, r2, r1, LSL #3;r2+r1*8=r1*10
	STR r1, [r0]
	
TEMPADDR1	& &40000000
	
exit
	MOV r7, #1
	MOV r0, #0
	SVC 0
	END
	
