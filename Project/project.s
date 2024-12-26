    AREA    TermProject2024, CODE, READONLY
    
; Constants
IMG_WIDTH    EQU     20
IMG_HEIGHT   EQU     20
NEW_WIDTH    EQU     80
NEW_HEIGHT   EQU     80

    ENTRY
    
main        
    ; Load base addresses
    LDR r4, =source_data     ; Source image
    LDR r5, =ResultBuffer    ; Destination buffer
    
    ; Initialize loop counters
    MOV r6, #0              ; j counter
    MOV r7, #0              ; i counter

    ; YOUR CODE HERE
   B saveData_Height
   
saveData_Height
    CMP r7, #NEW_HEIGHT       ; Check if row counter >= NEW_HEIGHT
   BGE Start_interpol
    MOV r6, #0                ; Reset column counter for new row

saveData_Width
    CMP r6, #NEW_WIDTH        ; Check if column counter >= NEW_WIDTH
    BGE next_row              ; Move to the next row if done

    ; Load from source and store to destination
    LDR r0, [r4]          ; Load pixel data from source
   ADD r4, r4, #4
    STR r0, [r5], #16         ; The next address to be stored is the current address + 16 bytes
    ADD r6, r6, #4            ; Increment column counter
    B saveData_Width        ; Continue with next column

next_row
    ADD r7, r7, #4            ; Increment row counter
   ADD r5, r5, #960      ;Skip 3 rows
    B saveData_Height       ; Process next row

Start_interpol ;Initial Horizontal interpolation
    MOV r7, #0              ; i counter
   B Cal_horizontal_interpol
   
Cal_horizontal_interpol
   LDR r5, =ResultBuffer    ; Destination buffer
   CMP r7, #0;if i=0, Calculate values from current location
   MOVNE r2, #0x140; 140(hex)=320(dec)--> 320(bytes)=4*80
   ;Difference value between rows
   MULNE r3, r2, r7
   ADDNE r5, r5, r3
   ;Calculate the storage location by multiplying the location of the current r7 stored row by the address values of the 4 rows, plus r5
   MOV r6, #0;j counter
   CMP r7, #NEW_HEIGHT
   BGE Start_verticality_interpol
   
Horizontal_interpol;Performed by skipping 3 rows at a time
   LDR r2, [r5, r6];j
   ADD r6, r6, #16
   LDR r3, [r5, r6];j+16(bytes)
   SUB r6, r6, #8;r6=j+8

   BL add_floats
   LDR r4, result_addr
   LDR r0, [r4];r0 is result value
   STR r0, [r5, r6];save j+8
   ;j+8={j+(j+16)}/2
   ;---current r6=j+8---
   
   SUB r6, r6, #8;r6=j
   LDR r2, [r5, r6];j
   ADD r6, r6, #8;r6=j+8
   LDR r3, [r5, r6];j+8
   SUB r6, r6, #4;r6=j+4
   
   BL add_floats
   LDR r4, result_addr
   LDR r0, [r4];r0 is result value
   STR r0, [r5, r6];save j+4
   ;j+4={j+(j+8)}/2
   ;---current r6=j+4---
   
   ADD r6, r6, #4;r6=j+8
   LDR r2, [r5, r6];j+8
   ADD r6, r6, #8;r6=j+16
   LDR r3, [r5, r6];j+16
   
   BL add_floats
   LDR r4, result_addr
   LDR r0, [r4];r0 is result value
   SUB r6, r6, #4;r6=j+12
   STR r0, [r5, r6]
   SUB r6, r6, #12;r6=j
   ;j+12={(j+8)+(j+16)}/2
   ;---current r6=j---
   
   CMP r6, #288;288=72*4
   BEQ padding_and_next_row
   ADD r6, r6, #16
   B Horizontal_interpol
   
padding_and_next_row
   ADD r6, r6, #16;r6=j+304 (76*4)bytes
   
   LDR r0, [r5, r6]
   ADD r6, r6, #4
   STR r0, [r5, r6];j[77]=j[76]
   
   LDR r0, [r5, r6]
   ADD r6, r6, #4
   STR r0, [r5, r6];j[78]=j[77]
   
   LDR r0, [r5, r6]
   ADD r6, r6, #4
   STR r0, [r5, r6];j[79]=j[78]
   ;Completion of value calculation in one row
   
   ADD r7, r7, #4;Move from the current row to back the fourth row
   
   B Cal_horizontal_interpol
;IEEE 754 ADD
add_floats
    PUSH    {R4-R11, lr}

    ; YOUR CODE HERE
    LSR r4, r2, #31;sign of r2
   LSL r5, r2, #1
   LSR r5, r5, #24;EXP of r2
   LSL r2, r2, #8;M of r2
   
   LSR r7, r3, #31;sign of r3
   LSL r8, r3, #1
   LSR r8, r8, #24;EXP of r3
   LSL r3, r3, #8;M of r3
   
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
   
ADD_mantissa
   MOV r0, r4;r0 is sign bit
   ADDS r10, r2, r3;Check carry & ADD mantissa
   ADDCS r11, r5, #1;if exist carry, exp+1
   MOVCC r11, r5;else
   BLCC not_carry;Carry mean is MSB of sum of Mantissa is 1
   B set_result
   
   
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
   CMP r11, #0
   SUBNE r11, r11, #1;if exp isn't 0, exp-1 == result/2
   ORR r12, r12, r11;Add exp
   LSL r12, r12, #23;to add mantissa
   LSR r10, r10, #9;Shift mantissa
   ORR r12, r12, r10;Add mantissa
   LDR r4, result_addr
   STR r12, [r4];result save
   pop{r4-r11, pc}
   
not_carry;Check MSB of Mantiss
   AND r1, r10, #0x80000000
   CMP r1, #0
   LSLNE r10, r10, #1;if MSB is 1, delete MSB
   BXNE lr

Start_verticality_interpol ;Initial Verticality interpol
   MOV r6, #0;j counter
   
Cal_verticality_interpol
   LDR r5, =ResultBuffer    ; Destination buffer
   CMP r6, #0
   MOVNE r2, #4;Difference value between columns
   MULNE r3, r2, r6
   ADDNE r5, r5, r3
   MOV r7, #0;i counter
   CMP r6, #NEW_WIDTH
   BGE end_program
   
Verticality_interpol
   LDR r2, [r5, r7];r7=i(row)
   ADD r7, r7, #0x500
   LDR r3, [r5, r7];r7=i+4(row)
   SUB r7, r7, #0x280;r7=i+2(row)
   
   BL add_floats
   LDR r4, result_addr
   LDR r0, [r4];r0 is result value
   STR r0, [r5, r7];save i+2
   ;i+2={i+(i+4)}/2
   ;---current r7=i+2---
   
   LDR r3, [r5, r7];r7=i+2
   SUB r7, r7, #0x280
   LDR r2, [r5, r7];r7=i
   ADD r7, r7, #0x140;r7=i+1
   
   BL add_floats
   LDR r4, result_addr
   LDR r0, [r4];r0 is result value
   STR r0, [r5, r7];save i+1
   ;i+1={i+(i+2)}/2
   ;---current r7=i+1
   
   ADD r7, r7, #0x140;r7=i+2
   LDR r2, [r5, r7]
   ADD r7, r7, #0x280;r7=i+4
   LDR r3, [r5, r7]
   SUB r7, r7, #0x140;r7=i+3
   
   BL add_floats
   LDR r4, result_addr
   LDR r0, [r4];r0 is result value
   STR r0, [r5, r7];save i+3
   SUB r7, r7, #0x3C0;r7=i
   ;i+3={(i+2)+(i+4)}/2
   ;---current r7=i---
   CMP r7, #0x5A00;5A00(hex)=23040(dec)=72*320(bytes)
   BEQ padding_and_next_column
   ADD r7, r7, #0x500
   B Verticality_interpol
   
padding_and_next_column
   ADD r7, r7, #0x500;r7=i+76
   
   LDR r0, [r5, r7]
   ADD r7, r7, #0x140
   STR r0, [r5, r7];i[77]=i[76]
   
   LDR r0, [r5, r7]
   ADD r7, r7, #0x140
   STR r0, [r5, r7];i[78]=i[77]
   
   LDR r0, [r5, r7]
   ADD r7, r7, #0x140
   STR r0, [r5, r7];i[79]=i[78]
   
   ADD r6, r6, #1;move from the current column to next column
   B Cal_verticality_interpol

; #########################
; DO NOT MODIFY end_program
; #########################
end_program
    MOV     R0, #0             ; Return 0
    MOV     R7, #0x11          ; SWI exit
    SWI     0                   ; Exit program and return 0
; #########################
; DO NOT MODIFY end_program
; #########################

; YOUR CODE HERE
    AREA    ROData, DATA, READONLY
mantissa_mask   DCD     0x007FFFFF          ; Store the large constant here
infinity_const    DCD      0x7F800000
implied_one     DCD     0x800000
result_addr   & &11000000;save memory of interpolation value


source_data
    INCLUDE data\downsampled\3.txt   ; Include the image data

    AREA    RWData, DATA, READWRITE
ResultBuffer
    SPACE   NEW_WIDTH * NEW_HEIGHT * 4   ; Space for 80x80 result
    
    END
