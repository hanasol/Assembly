	AREA ARMex, CODE, READONLY
	ENTRY
Start
	LDR sp, TEMPADDR1
	MOV r0, #1
	MOV r1, #2
	MOV r2, #3
	MOV r3, #4
	MOV r4, #5
	MOV r5, #6
	MOV r6, #7
	MOV r7, #8
	
	STMEA sp, {r0-r7}
	ADD sp, sp, #8;sp=0x40000008
	LDMFD sp, {r0}
	SUB sp, sp, #8;sp=0x40000000
	LDMFD sp, {r1}
	ADD sp, sp, #12;sp=0x4000000C
	LDMFD sp, {r2}
	ADD sp, sp, #8;sp=0x40000014
	LDMFD sp!, {r3};sp=0x40000018
	LDMFD sp!, {r4};sp=0x4000001C
	LDMFD sp!, {r5};sp=0x40000020
	SUB sp, sp, #28;sp=0x40000004
	LDMFD sp, {r6}
	ADD sp, sp, #12;sp=0x40000010
	LDMFD sp, {r7}
	
TEMPADDR1	& &40000000	
	mov r7, #1
	mov r0, #0
	svc 0
	END