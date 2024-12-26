	AREA FloatLoad, CODE, READONLY
		ENTRY

Start
	LDR r13, TEMPADDR1
	LDR r1, TEMPADDR2
	
	LDR r2, Value1
	LDR r3, Value2
	STR r2, [r1], #4
	STR r3, [r1]
	
	LSR r4, r2, #31;sign of r2
	LSL r5, r2, #1
	LSR r5, r5, #24;EXP of r2
	LSL r2, r2, #8;M of r2
	CMP r5, 0xFF
	BEQ exception_1;Value 1 is Nan or infinity 
	
	LSR r7, r3, #31;sign of r3
	LSL r8, r3, #1
	LSR r8, r8, #24;EXP of r3
	LSL r3, r3, #8;M of r3
	CMP r8, 0xFF
	BEQ exception_2;Value 2 is Nan or infinity
	
	ORR r2, r2, #0x80000000;MSB of Mantissa make 1
	ORR r3, r3, #0x80000000;MSB of Mantissa make 1
	
Set_exp
	CMP r5, r8;compare exp, r9 is Difference of two exp
	SUBHI r9, r5, r8;r2 exp > r3 exp
	LSRHI r3, r3, r9
	ADDHI r8, r8, r9;exp of r3 + value of r9
	SUBLO r9, r8, r5;r3 exp > r2 exp
	LSRLO r2, r2, r9
	ADDLO r5, r5, r9;exp of r2 + value of r9
	BNE Set_exp
	;EXP setting
	
	CMP r4, r7;Compare sign bit
	BEQ ADD_mantissa
	BNE SUB_mantissa
	
ADD_mantissa
	MOV r0, r4;r0 is sign bit
	ADDS r10, r2, r3;Check carry & ADD mantissa
	ADDCS r11, r5, #1;if exist carry, exp+1
	MOVCC r11, r5;else
	BLCC not_carry;Carry mean is MSB of sum of Mantissa is 1
	B set_result
	
SUB_mantissa
	CMP r2, r3;Compare Mantissa
	SUBHI r10, r2, r3;sign bit of result is r4
	MOVHI r0, r4
	SUBLO r10, r3, r2;sign bit of result is r7
	MOVLO r0, r7
	MOVEQ r11, #0;Two number's absolute value are same
	MOVEQ r0, #0;Sign bit is 0
	BEQ set_result
	MOV r11, r5;Save exp
	AND r1, r10, #0x80000000;result mantissa of sub
	CMP r1, #0
	LSLEQ r10, r10, #1
	BLEQ normal_M;MSB of r10 is 0
	LSLNE r10, r10, #1;delete MSB(1)
	BNE set_result
	
normal_M
	LSL r10, r10, #1
	SUB r11, r11, #1;EXP-1
	AND r1, r10, #0x80000000
	CMP r1, #0x80000000
	BNE normal_M;if MSB is 0
	BEQ set_result;if MSB is 1
	
set_result
	;result sign bit: MSB of r0, exp:r11, Mantissa:r10
	MOV r12, r0;Add sign bit
	LSL r12, r12, #8;to add exp
	ORR r12, r12, r11;Add exp
	LSL r12, r12, #23;to add mantissa
	LSR r10, r10, #9;Shift mantissa
	ORR r12, r12, r10;Add mantissa
	STR r12, [r13];save value to memory
	B stop
	
exception_1
	LSL r2, r2, #1;MSB of mantissa delete
	MOV r12, r4
	LSL r12, r12, #8
	ORR r12, r12, r5
	LSL r12, r12, #23
	LSR r2, r2, #9
	ORR r12, r12, r2
	STR r12, [r13];r12 is Value2 
	B stop
	
exception_2
	LSL r3, r3, #1;MSB of mantissa delete
	MOV r12, r7
	LSL r12, r12, #8
	ORR r12, r12, r8
	LSL r12, r12, #23
	LSR r3, r3, #9
	ORR r12, r12, r3
	STR r12, [r13];r12 is Value 2
	B stop
	
not_carry;Check MSB of Mantiss
	AND r1, r10, #0x80000000
	CMP r1, #0
	LSLNE r10, r10, #1;if MSB is 1, delete MSB
	BXNE lr
	

TEMPADDR1	& &40000000
TEMPADDR2	& &40000
Value1 DCI 0x7f800000
Value2 DCI 0x3e000000

stop
	mov r7, #1
	mov r0, #0
	svc 0
	END