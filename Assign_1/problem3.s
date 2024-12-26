	AREA ARMex, Code, READONLY
	ENTRY
Start
	MOV r1, #17
	MOV r2, #3
	MUL r3, r1, r2;3*17
	MUL r4, r2, r1;17*3
	
	MOV r7, #1
	MOV r0, #0
	SVC 0
	END
		