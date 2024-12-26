	AREA ARMex, Code, READONLY
	ENTRY
Start
	MOV r0, #10
	LDR r2, TEMPADDR1
	BL recursion;branch to recursion label
	B stop

recursion
	CMP r0, #0
	BEQ base;if r0==0
	
	PUSH {LR, r0};link regisrt, r0 push to stack
	SUB r0, r0, #1;r0-=1
	BL recursion;if ro !=0, recursion
	POP{LR, r1};state of register stored in the stack
	
	MUL r3, r0, r1
	MOV r0, r3;r0=r0*r1
	BX LR;;go to return address
base
	MOV r0, #1;0!==1
	BX LR;go to return address
	
TEMPADDR1	& &40000000

stop
	STR r0, [r2]
	MOV r7, #1
	MOV r0, #0
	SVC 0
	END