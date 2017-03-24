*-----------------------------------------------------------
* Title      : Disassembler test.
* Written by : Samuel Meyerding, Conor Van Achte, Abhi Trivedi
* Date       : January 22nd, 2017
* Description: Disassembler prototype.
*              
*              
*-----------------------------------------------------------

NOP_CODE    EQU     %0100111001110001     
RTS_CODE    EQU     %0100111001110101
TRAP_CODE   EQU     %0100111001000000   *The left 12 bits do not vary.
PAGE_SIZE   EQU     30   
    ORG     $1000
START:                  ; first instruction of program
            MOVEA.L  A7,A5
            MOVEA.L  #0,A6
INPUT        
             LEA MESSAGE0,A1
             MOVE.B  #14, D0
             TRAP    #15
GO_AGAIN
             MOVEA.L  #0,A6
             CLR.L   D3
             CLR.L   D4
             LEA MESSAGE1,A1
             MOVE.B  #14, D0
             TRAP    #15
             MOVEA.L #$500,A1          ;This is where the string from the MESSAGE1 is stored
             MOVE.B  #2,D0            ;This picks the trap task for input of a string
             TRAP    #15
             JSR    HEXINPUT
             BTST   #0,D3
             BNE    OUTPUT_ERRORMESSAGE2
             MOVE.L  D3,D4
             CLR.L   D3
             LEA MESSAGE2,A1
             MOVE.B  #14,D0
             TRAP    #15
             MOVEA.L #$500,A1          ;This is where the string from the MESSAGE1 is stored
             MOVE.B  #2,D0            ;This picks the trap task for input of a string
             TRAP    #15
             JSR    HEXINPUT
             BTST   #0,D3
             BNE    OUTPUT_ERRORMESSAGE2
CHECKADDRESS 
             
             CMP.L       D4,D3
             BLT         OUTPUT_ERRORMESSAGE1
             MOVEA.L     D4,A2
             MOVEA.L     D3,A3
             BRA    RELOOP
             
ENDMESSAGE  
            LEA     ENDOFPROGRAM,A1
            MOVE.B  #14,D0
            TRAP    #15
            MOVE.B  #5,D0
            TRAP    #15
            LEA     NEWLINE,A1
            MOVE.B  #14,D0
            TRAP    #15
            CMP.B   #'y',D1
            BEQ     GO_AGAIN
            CMP.B   #'n',D1
            BEQ     QUIT
            BRA     ENDMESSAGE

CALL_ONE_PAGE_PRINTED
    JSR     ONE_PAGE_PRINTED             
RELOOP
    CLR.L   D1
    CLR.L   D2
    CLR.L   D3
    CLR.L   D4
    CLR.L   D5
    CLR.L   D6
    CLR.L   D7
    MOVEA.L A5, A7
    CMPA.W  #PAGE_SIZE,A6
    BEQ     CALL_ONE_PAGE_PRINTED
    ADD    #1,A6
    CMPA.L  A2,A3
    BLT     ENDMESSAGE
    LEA     NEXT_LINE,A1 
    MOVE.B  #14,D0      
    TRAP    #15
    JSR     PRINT_ADDRESS   *Prints the address at this instruction.
    JSR     PRINT_SPACE     *Separates the address from the next output.    
    MOVE.W  (A2)+,D1        *Moves the value at address A2 into D1.
    CMP.W   #NOP_CODE,D1    *NOP has a static value, so a direct comparison will find if the OPCode is NOP
    BEQ     NOP_SECT        *Output 'NOP' if the OPCode == #NOP_CODE
    CMP.W   #RTS_CODE,D1    *RTS has a static value, so a direct comparison will find if the OPCode is RTS
    BEQ     RTS_SECT        *Output 'RTS' if the OPCode == #RTS_CODE
FIRST_BIT
    BTST    #15,D1          *Test the first bit of the OPCODE to eliminate possibilites that start with a different value in the first bit.
    BNE     BIN_1_SECOND    *Any OPCode that starts with 1 will Branch to this.
BIN_0_SECOND    *Possibilites are MOVE, MOVEA, ADDI, MOVEQ, MOVEM, ADDQ, LEA, CLR, Bcc, and JSR
    BTST    #14,D1          *The first bit at this point is not set. Testing the second will allow elimination of possibilities.
    BNE     BIN_01_THIRD    *If this branch is taken, only pssibilities beginning with 01 are valid. Else, continue to 00.    
BIN_00_THIRD    *Possibilites are MOVE, MOVEA, and ADDI.
    MOVE.W  D1,D2                   *Create a copy of D1 in D2 in order to mask some of its bits and keep original.
    AND.W   #%0011000000000000,D2   *These bits are required to immediately tell if this OPCode is ADDI. 
    CMP.W   #%0000000000000000,D2   *Compare with value that would be true if Code is ADDI or BTST.
    BEQ     BIN_0000_FOURTH               *Go to output ADDI_MESS.
    MOVE.W  D1,D2                   *Create a copy of D1 in D2 in order to mask some of its bits and keep original.
    AND.W   #%0000111000000,D2           *These bits are required to differentiate between MOVE and MOVEA. 
    CMP.W   #%0000001000000,D2           *Compare with value that would be true if Code is MOVEA.
    BEQ     MOVEA_SECT              *Go to output MOVEA_MESS. Else, continue to MOVE_SECT.
MOVE_SECT                           *Outputs the message 'MOVE.'.
    MOVE.B  #%11111111,D7           *Valid modes for this OPCode (SourceEA).
    JSR     SRC_EFF_ADDR_MODE_REG   *Check value in mode for validity.
    BTST    #0,D3                   *Checking result of subroutine's check for valid final 6 bits.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.
    MOVE.B  #%11110101,D7           *Valid modes for this OPCode (SourceEA).
    JSR     DEST_EFF_ADDR_MODE_REG   *Check value in mode for validity.
    BTST    #0,D3                   *Checking result of subroutine's check for valid final 6 bits.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.
    MOVE.B  #%11101101,D3           *Shift count of 13 for VALIDATE_SIZE and any size accepted.
    JSR     VALIDATE_SIZE_MOVELIKE  *Subroutine for validating size portion of OPCode.
    BTST    #0,D3                   *Checking result of subroutine's check for valid SIZE bits.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.
    LEA     MOVE_MESS,A1 
    MOVE.B  #14,D0      
    TRAP    #15
    JSR     PRINT_ADDR_MODE_SIZE_BIT_13

    BTST    #5,D1
    BNE     MOVE_VALID_MODE_1_JSR
    JSR     VALID_MODE_0
    
    JMP     MOVE_PRINT_DESTINATION
VALID_MODE_SOURCE_DEST_1_JSR
    JSR     VALID_MODE_SOURCE_DEST_1
    JMP     RELOOP
    
MOVE_VALID_MODE_1_JSR
    JSR     VALID_MODE_1
    *BTST    #5,D1
    *BNE     MOVE_PRINT_IMMED_ADDR_11
    JMP     MOVE_PRINT_DESTINATION

MOVE_PRINT_DESTINATION
    JSR     PRINT_COMMA         *Prints a comma to the output window.

    BTST    #8,D1                           *Test the destination mode
    BNE     VALID_MODE_SOURCE_DEST_1_JSR    
    JSR     VALID_MODE_SOURCE_DEST_0
    JMP     RELOOP

MOVE_PRINT_IMMED_ADDR_11
    BTST    #4,D1
    BNE     MOVE_PRINT_IMMED_ADDR_MODE_111
    JMP     RELOOP

MOVE_PRINT_IMMED_ADDR_MODE_111
    JSR     MOVE_PRINT_IMMED_ADDR
    JMP     MOVE_PRINT_DESTINATION
MOVE_PRINT_IMMED_ADDR
    BTST    #5,D1                           *Test to make sure the mode is 111, if it is then we need to pop from the address.
    BEQ     MOVE_RTS
    BTST    #4,D1
    BEQ     MOVE_RTS
    BTST    #3,D1
    BEQ     MOVE_RTS
    BTST    #2,D1
    BEQ     MOVE_RTS
    BTST    #12,D1                          *Test if it is a long, if so pop one more word
    BEQ   MOVE_PRINT_IMMED_ADDR_LONG
    
    RTS
MOVE_PRINT_IMMED_ADDR_LONG
    BTST    #5,D1
    BEQ     MOVE_RTS
    BTST    #4,D1
    BEQ     MOVE_RTS
    BTST    #3,D1
    BEQ     MOVE_RTS
    BTST    #2,D1
    BEQ     MOVE_RTS
    
    *MOVE.L  D6,D1
    *MOVE.B  #15,D0        *Sets the trap task to print out in hexadecimal
    *MOVE.B  #16,D2        *Set the base to 16
    *TRAP    #15
    MOVE.L  D6,D2
    JSR OUTPUT_HEXADECIMAL

    RTS

MOVE_RTS
    RTS
PRINT_ADDR_MODE_SIZE_BIT_13    
    MOVE.L  D1,D4
    BTST    #13,D1
    BEQ     PRINT_BYTE_OPERATION
        
    BTST    #12,D1
    BEQ     PRINT_LONG_OPERATION
    
    *If we get here, the addressing mode is the word operation (.W).
    
    JSR     PRINT_W                  *Prints a W to the output window.
    JMP     PRINT_SPACE_RTS

PRINT_BYTE_OPERATION
    JSR     PRINT_B                  *Prints a B to the output window.
    JMP     PRINT_SPACE_RTS
    
PRINT_LONG_OPERATION
    JSR     PRINT_L                  *Prints a L to the output window.
    JMP     PRINT_SPACE_RTS  

PRINT_SPACE_RTS
    JSR     PRINT_SPACE         *Prints a space to the output window.
    MOVE.L  D4,D1
    RTS
    
BIN_0000_FOURTH  *Possibilities are ADDI and BTST.
    BTST    #11,D1
    BNE     BTST_STATIC_SECT
    BTST    #8,D1
    BNE     BTST_DYNAMIC_SECT    
    
ADDI_SECT                   *Outputs the message 'ADDI.'.
    MOVE.W  D1,D3                   *Copy OPCode into D3 in order to allow for isolation of bits.
    AND.W   #%1111111100000000,D3
    CMP.W   #%0000011000000000,D3
    BNE     PRINT_INVALID_OPCODE
    MOVE.B  #%11110101,D7           *Valid modes for this OPCode.
    JSR     SRC_EFF_ADDR_MODE_REG   *Check value in mode for validity.
    BTST    #0,D3                   *Checking result of subroutine's check for valid final 6 bits.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.
    MOVE.B  #%11100111,D3           *Shift count of 7 for VALIDATE_SIZE, and any size accepted.
    JSR     VALIDATE_SIZE_CLRLIKE   *Subroutine for validating size portion of OPCode.
    BTST    #0,D3                   *Checking result of subroutine's check for valid SIZE bits.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.
    LEA     ADDI_MESS,A1 
    MOVE.B  #14,D0      
    TRAP    #15
    
    JSR     ADD_SIZE  
    JSR     PRINT_SPACE         *Prints a space to the output window.
    JSR     PRINT_POUND         *Prints a # to the output window.  
    JSR     PRINT_$
    MOVE.L  D1,D4

    MOVE.L  D6,D2
    JSR     OUTPUT_HEXADECIMAL

    JSR     PRINT_COMMA         *Prints a comma to the output window.
    MOVE.L  D4,D1
    BTST    #5,D1
    BNE     VALID_MODE_1_JSR
    JSR     VALID_MODE_0
    
    JMP     RELOOP
VALID_MODE_1_JSR
    JSR     VALID_MODE_1
    JMP     RELOOP    
ADD_SIZE
    BTST    #7,D1
    BNE     ADD_SIZE_LONG
    BTST    #6,D1
    BNE     ADD_SIZE_WORD
    
    MOVE.L  D1,D4
    JSR     PRINT_B                  *Prints a B to the output window.
    MOVE.W  (A2)+,D6
    
    
    RTS
    
    
ADD_SIZE_WORD
    MOVE.L  D1,D4
    JSR     PRINT_W                  *Prints a W to the output window.
    MOVE.W  (A2)+,D6


    RTS    
    
ADD_SIZE_LONG
    JSR     PRINT_L                  *Prints a L to the output window.
    MOVE.L  (A2)+,D6
    RTS
    
BIN_01_THIRD    *Possibilities are MOVEQ, MOVEM, ADDQ, LEA, CLR, Bcc, and JSR.
    MOVE.W  D1,D2
    AND.W   #%1111111111110000,D2
    CMP.W   #TRAP_CODE,D2
    BEQ     TRAP_SECT
    BTST    #13,D1                  *If this bit is set, then the OPCode is either Bcc or MOVEQ.
    BNE     BIN_011_FOURTH          *Eliminates Bcc and MOVEQ as possibilities if code reaches past this.
BIN_010_FOURTH  *Possibilities are MOVEM, ADDQ, LEA, CLR, JSR.
    BTST    #12,D1
    BNE     ADDQ_SECT
BIN_0100_FIFTH  *Possibilities are MOVEM, LEA, CLR, JSR, JMP.
    MOVE.W  D1,D2                   *Create a copy of D1 in D2 in order to mask some of its bits and keep original.
    AND.W   #%0000101100000000,D2   *These bits will tell me if this is MOVEM.
    CMP.W   #%0000100000000000,D2   *Compare with the values that would be set for MOVEM
    BEQ     MOVEM_SECT              *Possibilities are now LEA, CLR, JSR, and JMP.
    MOVE.W  D1,D2                   *Create a copy of D1 in D2 in order to mask some of its bits and keep original.
    AND.W   #%1111111111000000,D2   *These bits will tell me if this is JMP.
    CMP.W   #%0100111011000000,D2   *Compare with the values that would be set for JMP
    BEQ     JMP_SECT                *Possibilities are now LEA, CLR, and JSR.
    BTST    #8,D1                   *If this bit is set, then the instruction can only be LEA.
    BNE     LEA_SECT                *Possibilities are now CLR and JSR.
    BTST    #11,D1                  *If this bit is set, then the instruction can only be JSR.
    BNE     JSR_SECT                *Only possibility is now CLR.
CLR_SECT
    MOVE.B  #%11110101,D7       *Valid modes for this OPCode.
    JSR     SRC_EFF_ADDR_MODE_REG   *Check value in mode for validity.
    BTST    #0,D3                   *Checking result of subroutine's check for valid final 6 bits.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.
    MOVE.B  #%11100111,D3           *Shift count of 7 for VALIDATE_SIZE, and any size accepted.
    JSR     VALIDATE_SIZE_CLRLIKE   *Subroutine for validating size portion of OPCode.
    BTST    #0,D3                   *Checking result of subroutine's check for valid final 6 bits.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.
    MOVE.W  D1,D2                   *Copying OPCode Word for isolation of static bits.
    AND.W   #%1111111100000000,D2   *Isolating bits for detrmining validity of OPCode.
    CMP.W   #%0100001000000000,D2   *Comparing with valid value.
    BNE     PRINT_INVALID_OPCODE    *If it's not the valid value, then print error message.
    LEA     CLR_MESS,A1
    MOVE.B  #14,D0      
    TRAP    #15
   
    
    JMP     CLR_PRINT
               
    
CLR_PRINT
    JSR     CLR_PRINT_ADDR_MODE
    
    BTST    #5,D1
    BEQ     VALID_MODE_0_JSR
    JSR     VALID_MODE_1   

    JMP     RELOOP

CLR_PRINT_ADDR_MODE
   
    BTST    #7,D1
    BNE     CLR_PRINT_LONG
    
    BTST    #6,D1
    BNE     CLR_PRINT_WORD
    
    *We pass both cases, it is a .B
    CLR.L   D4
    MOVE.L  D1,D4
    JSR     PRINT_B                  *Prints a B to the output window.
    JSR     PRINT_SPACE         *Prints a space to the output window.
    MOVE.L  D4,D1
    RTS

CLR_PRINT_LONG    
    JSR     PRINT_L                  *Prints a L to the output window.
    JSR     PRINT_SPACE         *Prints a space to the output window.
    RTS
    
CLR_PRINT_WORD    
    JSR     PRINT_W                  *Prints a W to the output window.
    JSR     PRINT_SPACE         *Prints a space to the output window.
    RTS
    
BIN_011_FOURTH  *Possibilities are Bcc and MOVEQ.
    BTST    #12,D1
    BNE     MOVEQ_SECT
*Condition Section.****************************************

B_COND_SECT     *It has been determined to be a Conditional Branch. Now to determine the condition.
    MOVE.W  D1,D2                   *Copying OPCode Word for isolation of static bits.
    AND.W   #%1111000000000000,D2   *Isolating bits for detrmining validity of OPCode.
    CMP.W   #%0110000000000000,D2   *Comparing with valid value.
    BNE     PRINT_INVALID_OPCODE    *If it's not the valid value, then print error message.
    BTST    #11,D1          
    BNE     Bcc_1_SECT
Bcc_0_SECT      *First bit of condition is 0.
    BTST    #10,D1
    BNE     Bcc_01_SECT
Bcc_00_SECT     *First bits of condition are 00.
    BTST    #9,D1
    BNE     Bcc_001_SECT
BRA_SECT        *First bits of condition are 0000. This means BRA.
    LEA     BRA_MESS,A1     *Outputs the message 'BRA'.
    MOVE.B  #14,D0      
    TRAP    #15
    JMP     Bcc_PRINT_DISPLACEMENT
Bcc_001_SECT    *First bits of condition are 001.
    BTST    #8,D1
    BNE     BLS_SECT
BHI_SECT        *First bits of condition are 0010. This means BHI.
    LEA     BHI_MESS,A1     *Outputs the message 'BHI'.
    MOVE.B  #14,D0      
    TRAP    #15
    JMP     Bcc_PRINT_DISPLACEMENT
Bcc_01_SECT     *First bits of condition are 01.
    BTST    #9,D1
    BNE     Bcc_011_SECT
Bcc_010_SECT    *First bits of condition are 010.
    BTST    #8,D1
    BNE     BCS_SECT
BCC_SECT        *First bits of condition are 0100. This means BCC.
    LEA     BCC_MESS,A1     *Outputs the message 'BCC'.
    MOVE.B  #14,D0      
    TRAP    #15
    JMP     Bcc_PRINT_DISPLACEMENT
Bcc_011_SECT    *First bits of condition are 011.
    BTST    #8,D1
    BNE     BEQ_SECT
BNE_SECT        *First bits of condition are 0110. This means BNE.
    LEA     BNE_MESS,A1     *Outputs the message 'BNE'.
    MOVE.B  #14,D0      
    TRAP    #15
    JMP     Bcc_PRINT_DISPLACEMENT
Bcc_1_SECT      *First bit of condition is 1.
    BTST    #10,D1
    BNE     Bcc_11_SECT
Bcc_10_SECT     *First bits of condition are 10.
    BTST    #9,D1
    BNE     Bcc_101_SECT
Bcc_100_SECT    *First bits of condition are 100.
    BTST    #8,D1
    BNE     BVS_SECT
BVC_SECT        *First bits of condition are 1000. This means BVC.
    LEA     BVC_MESS,A1     *Outputs the message 'BVC'.
    MOVE.B  #14,D0      
    TRAP    #15
    JMP     Bcc_PRINT_DISPLACEMENT
Bcc_101_SECT    *First bits of condition are 101.
    BTST    #8,D1
    BNE     BMI_SECT
BPL_SECT        *First bits of condition are 1010. This means BPL.
    LEA     BPL_MESS,A1     *Outputs the message 'BPL'.
    MOVE.B  #14,D0      
    TRAP    #15
    JMP     Bcc_PRINT_DISPLACEMENT
Bcc_11_SECT     *First bits of condition are 11.
    BTST    #9,D1
    BNE     Bcc_111_SECT
Bcc_110_SECT    *First bits of condition are 110.
    BTST    #8,D1
    BNE     BLT_SECT
BGE_SECT        *First bits of condition are 1100. This means BGE.
    LEA     BGE_MESS,A1     *Outputs the message 'BGE'.
    MOVE.B  #14,D0      
    TRAP    #15
    JMP     Bcc_PRINT_DISPLACEMENT
Bcc_111_SECT    *First bits of condition are 111.
    BTST    #8,D1
    BNE     BLE_SECT
BGT_SECT
    LEA     BGT_MESS,A1     *Outputs the message 'BGT'.
    MOVE.B  #14,D0      
    TRAP    #15
    JMP     Bcc_PRINT_DISPLACEMENT
BLS_SECT
    LEA     BLS_MESS,A1     *Outputs the message 'BLS'.
    MOVE.B  #14,D0      
    TRAP    #15
    JMP     Bcc_PRINT_DISPLACEMENT
BCS_SECT
    LEA     BCS_MESS,A1     *Outputs the message 'BCS'.
    MOVE.B  #14,D0      
    TRAP    #15
    JMP     Bcc_PRINT_DISPLACEMENT
BVS_SECT
    LEA     BVS_MESS,A1     *Outputs the message 'BVS'.
    MOVE.B  #14,D0      
    TRAP    #15
    JMP     Bcc_PRINT_DISPLACEMENT
BEQ_SECT
    LEA     BEQ_MESS,A1     *Outputs the message 'BEQ'.
    MOVE.B  #14,D0      
    TRAP    #15
    JMP     Bcc_PRINT_DISPLACEMENT
BLT_SECT
    LEA     BLT_MESS,A1     *Outputs the message 'BLT'.
    MOVE.B  #14,D0      
    TRAP    #15
    JMP     Bcc_PRINT_DISPLACEMENT
BLE_SECT
    LEA     BLE_MESS,A1     *Outputs the message 'BLE'.
    MOVE.B  #14,D0      
    TRAP    #15
    JMP     Bcc_PRINT_DISPLACEMENT
BMI_SECT
    LEA     BMI_MESS,A1     *Outputs the message 'BMI'.
    MOVE.B  #14,D0      
    TRAP    #15
    JMP     Bcc_PRINT_DISPLACEMENT

Bcc_PRINT_DISPLACEMENT
    
    MOVE.L  D1,D4
    JSR     PRINT_SPACE         *Prints a space to the output window.
    JSR     PRINT_$             *Prints a $ to the output window.
    MOVE.L  D4,D1
    
    MOVE.L  #24,D6
    LSL.L   D6,D1
    MOVE.L  #24,D6
    LSR.L   D6,D1
    MOVE.B  #$00,D7
    CMP     D7,D1
    BEQ     Bcc_PRINT_DISPLACEMENT_WORD
    MOVE.B  #$FF,D7
    CMP     D7,D1
    BEQ     Bcc_PRINT_DISPLACEMENT_LONG
    
    MOVE.L  D1,D2                    
    JSR     OUTPUT_HEXADECIMAL
    JMP     RELOOP
    
Bcc_PRINT_DISPLACEMENT_WORD
    MOVE.L  D4,D1
    MOVE.W  (A2)+,D6               *This gets the remaining word from the function
    CLR.L   D2
    MOVE.L  D1,D4                           *Copy the bits to D4, because we are going to print and need to use D1
    MOVE.L  D6,D1
    CLR.L   D2
    MOVE.L  D1,D2                    
    JSR     OUTPUT_HEXADECIMAL
    JMP     RELOOP
    
Bcc_PRINT_DISPLACEMENT_LONG
    MOVE.L  D4,D1
    MOVE.L  (A2)+,D6               *This gets the remaining word from the function
    CLR.L   D2
    MOVE.L  D1,D4                           *Copy the bits to D4, because we are going to print and need to use D1
    MOVE.L  D6,D1
    CLR.L   D2
    MOVE.L  D1,D2                    
    JSR     OUTPUT_HEXADECIMAL
    JMP     RELOOP
    
*End of Condition Section **********************************************

BIN_1_SECOND    *Possibilities are SUB, DIVU, OR, CMP ADD, ADDA, MULS, AND, LSL, LSR, ASR, ASL, ROL, and ROR.
    BTST    #14,D1
    BNE     BIN_11_THIRD 
BIN_10_THIRD    *Possibilities are SUB, DIVU, OR, and CMP.
    BTST    #13,D1          *If this bit is set, then the OPCode is CMP.
    BNE     CMP_SECT        *Go to output CMP_MESS. Else, continue to BIN_100_FOURTH    
BIN_100_FOURTH  *Possibilities are SUB, DIVU, and OR.
    BTST    #12,D1          *If this bit is set, then the OPCode is SUB
    BNE     SUB_SECT        *Go to output SUB.
    MOVE.B  D1,D2           *Create a copy of D1 in D2 in order to mask some of its bits and keep original.
    AND.W   #%0000000111000000,D2    *These bits are required to tell the difference between OR and DIVU.
    CMP.W   #%0000000011000000,D2    *Compare with value that would be true if Code is DIVU.
    BEQ     DIVU_SECT       *Go to output DIVU_MESS. Else, continue to OR_SECT.
OR_SECT         *Output the message 'OR.'.
    MOVE.W  D1,D2                   *Copying OPCode Word for isolation of static bits.
    AND.W   #%1111000000000000,D2   *Isolating bits for detrmining validity of OPCode.
    CMP.W   #%1000000000000000,D2   *Comparing with valid value.
    BNE     PRINT_INVALID_OPCODE    *If it's not the valid value, then print error message.
    JSR     VALIDATE_OPMODE_FIELD   *Subroutine validates OPMode field of subroutine.
    BTST    #0,D3                   *Checking result of subroutine's check for valid OPMode.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.
    LEA     OR_MESS,A1
    MOVE.B  #14,D0      
    TRAP    #15
    
    BTST    #8,D1
    BNE     OR_DN_EA
OR_EA_DN                        *This is OR with the OPMode bieng <ea> -> Dn
    MOVE.B  #%11111111,D7       *Valid modes for this OPCode.
    JSR     SRC_EFF_ADDR_MODE_REG   *Check value in mode for validity
    BTST    #0,D3                   *Checking result of subroutine's check for valid final 6 bits.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.
    JSR     PRINT_OPMODE_ADD_EA_DN
    JMP     RELOOP 
OR_DN_EA                        *This is OR with the OPMode bieng Dn -> <ea>
    MOVE.B  #%11110100,D7       *Valid modes for this OPCode.
    JSR     SRC_EFF_ADDR_MODE_REG   *Check value in mode for validity
    BTST    #0,D3                   *Checking result of subroutine's check for valid final 6 bits.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.
    JSR     PRINT_OPMODE_ADD_DN_EA
    JMP     RELOOP
    
BIN_11_THIRD    *Possibilities are ADD, ADDA, MULS, AND, LSL, LSR, ASR, ASL, ROL, and ROR.
    BTST    #13,D1
    BNE     BIN_111_FOURTH
BIN_110_FOURTH  *Possibilities are ADD, ADDA, MULS, and AND.
    BTST    #12,D1
    BNE     BIN_1101_FOURTH
BIN_1100_FOURTH *Possibilities are MULS and AND.
    MOVE.B  D1,D2           *Create a copy of D1 in D2 in order to mask some of its bits and keep original.
    AND.B   #%11000000,D2   *These bits are required to tell the difference between MULS and AND.
    CMP.B   #%11000000,D2   *Compare to values for MULS.
    BEQ     MULS_SECT       *If equal to values for MULS, go to MULS_SECT. Else, Continue to AND_SECT.
AND_SECT        *Output the message 'AND.'.
    MOVE.W  D1,D2                   *Copying OPCode Word for isolation of static bits.
    AND.W   #%1111000000000000,D2   *Isolating bits for detrmining validity of OPCode.
    CMP.W   #%1100000000000000,D2   *Comparing with valid value.
    BNE     PRINT_INVALID_OPCODE    *If it's not the valid value, then print error message.
    JSR     VALIDATE_OPMODE_FIELD   *Subroutine validates OPMode field of subroutine.
    BTST    #0,D3                   *Checking result of subroutine's check for valid OPMode.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.
    LEA     AND_MESS,A1
    MOVE.B  #14,D0      
    TRAP    #15
   
    BTST    #8,D1
    BNE     AND_DN_EA
AND_EA_DN                   *This is ADD with the OPMode bieng <ea> -> Dn
    MOVE.B  #%11111101,D7       *Valid modes for this OPCode.
    JSR     SRC_EFF_ADDR_MODE_REG   *Check value in mode for validity
    BTST    #0,D3                   *Checking result of subroutine's check for valid final 6 bits.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.
    JSR     PRINT_OPMODE_ADD_EA_DN
    JMP     RELOOP
AND_DN_EA                   *This is ADD with the OPMode bieng Dn -> <ea>
    MOVE.B  #%11110100,D7       *Valid modes for this OPCode.
    JSR     SRC_EFF_ADDR_MODE_REG   *Check value in mode for validity
    BTST    #0,D3                   *Checking result of subroutine's check for valid final 6 bits.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.
    JSR     PRINT_OPMODE_ADD_DN_EA
    JMP     RELOOP
BIN_111_FOURTH  *Possibilities are LSL, LSR, ASR, ASL, ROL, and ROR. These can be register shifts or memory shifts.
BIN_1110_FIFTH
    MOVE.B  D1,D2
    AND.B   #%11000000,D2
    CMP.B   #%11000000,D2
    BEQ     MEM_SHIFTS
REG_SHIFTS      *This has been determined to be a register shift.
    MOVE.B  #%11100111,D3           *Shift count of 13 for VALIDATE_SIZE and any size accepted.
    JSR     VALIDATE_SIZE_CLRLIKE   *Subroutine for validating size portion of OPCode.
    BTST    #0,D3                   *Checking result of subroutine's check for valid final 6 bits.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.
    MOVE.B  D1,D2           *Create a copy of D1 in D2 in order to mask some of its bits and keep original.
    AND.B   #%00011000,D2   *Significant bits for determining what kind of shift.
    CMP.B   #%00001000,D2   *Compare with the shift with the middle value in the range.
    BGT     ROL_ROR_REG_SECT    *If greater than, it's a rotation.
    BEQ     LSL_LSR_REG_SECT    *If greater than, it's a Logical Shift. Else, Continue to Arithmetic shifts.
ASR_ASL_REG_SECT    *Arithmeitc shift. Determines direction.
    MOVE.W  D1,D2                   *Copying OPCode Word for isolation of static bits.
    AND.W   #%1111000000011000,D2   *Isolating bits for detrmining validity of OPCode.
    CMP.W   #%1110000000000000,D2   *Comparing with valid value.
    BNE     PRINT_INVALID_OPCODE    *If it's not the valid value, then print error message.
    BTST    #8,D1
    BNE     ASL_REG_SECT
ASR_REG_SECT        *Output the message 'ASR.'.
    LEA     ASR_MESS,A1
    MOVE.B  #14,D0      
    TRAP    #15
    JSR     LSL_LSR_PRINT
    JMP     RELOOP
LSL_LSR_REG_SECT    *Logical Shift. Determines direction.
    MOVE.W  D1,D2                   *Copying OPCode Word for isolation of static bits.
    AND.W   #%1111000000011000,D2   *Isolating bits for detrmining validity of OPCode.
    CMP.W   #%1110000000001000,D2   *Comparing with valid value.
    BNE     PRINT_INVALID_OPCODE    *If it's not the valid value, then print error message.
    BTST    #8,D1
    BNE     LSL_REG_SECT
LSR_REG_SECT        *Output the message 'LSR.'.
    LEA     LSR_MESS,A1
    MOVE.B  #14,D0      
    TRAP    #15
    JSR     LSL_LSR_PRINT
    JMP     RELOOP


LSL_LSR_PRINT
    BTST    #5,D1                       *If it is 01, iLSL_LSR_PRINT_LONGt is
    BEQ     LSL_LSR_PRINT_IMMED
    BTST    #7,D1                       *Check the size, if it is a 1, it is a long
    BNE     LSL_LSR_PRINT_LONG
    BTST    #6,D1                       *If it is 01, it is a word address
    BNE     LSL_LSR_PRINT_WORD
                                        *If it gets through both tests it is byte addressing
    JSR     PRINT_B                  *Prints a B to the output window.
    JMP     LSL_LSR_PRINT_Dx
    
LSL_LSR_PRINT_WORD
    JSR     PRINT_W                  *Prints a W to the output window.
    JMP     LSL_LSR_PRINT_Dx
    
LSL_LSR_PRINT_LONG
    JSR     PRINT_L                  *Prints a L to the output window.
    JMP     LSL_LSR_PRINT_Dx
    
LSL_LSR_PRINT_Dx
    JSR     PRINT_SPACE         *Prints a space to the output window.
    JSR     PRINT_D
     
    MOVE.L  D1,D4
    CLR.L   D6
    MOVE.B  #20,D6
    LSL.L   D6,D1
    CLR.L   D6
    MOVE.B  #29,D6
    LSR.L   D6,D1
    
    MOVE.B  #3,D0                   *Move trap task  #15 to convert to decimal and print  
    TRAP    #15
    JSR     PRINT_COMMA             *Prints a comma to the output window.
    JSR     PRINT_D
    
    MOVE.L  D4,D1
    CLR.L   D6
    MOVE.B  #29,D6
    LSL.L   D6,D1
    LSR.L   D6,D1
    
    MOVE.B  #3,D0                   *Move trap task  #15 to convert to decimal and print  
    TRAP    #15
    
    RTS
LSL_LSR_PRINT_IMMED_LONG
    JSR     PRINT_L                  *Prints a L to the output window.
    JSR     PRINT_SPACE         *Prints a space to the output window.
    JSR     PRINT_POUND         *Prints a # to the output window.

    MOVE.L  D4,D1
    CLR.L   D6
    MOVE.B  #20,D6
    LSL.L   D6,D1
    CLR.L   D6
    MOVE.B  #29,D6
    LSR.L   D6,D1
    
    CMP     #0,D1
    BEQ     LSL_LSR_PRINT_IMMED_8
    
    JSR     LSL_LSR_PRINT_Dy
    JMP     RELOOP
LSL_LSR_PRINT_IMMED_WORD
    JSR     PRINT_W                  *Prints a W to the output window.
    JSR     PRINT_SPACE         *Prints a space to the output window.
    JSR     PRINT_POUND         *Prints a # to the output window.

    MOVE.L  D4,D1
    CLR.L   D6
    MOVE.B  #20,D6
    LSL.L   D6,D1
    CLR.L   D6
    MOVE.B  #29,D6
    LSR.L   D6,D1
    
    CMP     #0,D1
    BEQ     LSL_LSR_PRINT_IMMED_8
    
    JSR     LSL_LSR_PRINT_Dy
    JMP     RELOOP
LSL_LSR_PRINT_IMMED
    MOVE.L  D1,D4
    BTST    #7,D1
    BNE     LSL_LSR_PRINT_IMMED_LONG
    BTST    #6,D1
    BNE     LSL_LSR_PRINT_IMMED_WORD
    JSR     PRINT_B                  *Prints a B to the output window.
    JSR     PRINT_SPACE         *Prints a space to the output window.
    JSR     PRINT_POUND         *Prints a # to the output window.

    MOVE.L  D4,D1
    
    CLR.L   D6
    MOVE.B  #20,D6
    LSL.L   D6,D1
    CLR.L   D6
    MOVE.B  #29,D6
    LSR.L   D6,D1
    
    CMP     #0,D1
    BEQ     LSL_LSR_PRINT_IMMED_8
    
    JSR     LSL_LSR_PRINT_Dy
    JMP     RELOOP
    
    
LSL_LSR_PRINT_IMMED_8
    MOVE.B  #'8',D1
    MOVE.B  #6,D0
    TRAP    #15
    BRA     LSL_LSR_AFTER_PRINT
    JMP     RELOOP
    
LSL_LSR_PRINT_Dy
    MOVE.L  D4,D1
    
    CLR.L   D6
    MOVE.B  #20,D6
    LSL.L   D6,D1
    CLR.L   D6
    MOVE.B  #29,D6
    LSR.L   D6,D1
    
    MOVE.B  #3,D0                   *Move trap task  #15 to convert to decimal and print  
    TRAP    #15 
LSL_LSR_AFTER_PRINT
    JSR     PRINT_COMMA         *Prints a comma to the output window.
    JSR     PRINT_D
    
    MOVE.L  D4,D1
    CLR.L   D6
    MOVE.B  #29,D6
    LSL.L   D6,D1
    LSR.L   D6,D1
    
    MOVE.B  #3,D0                   *Move trap task  #15 to convert to decimal and print  
    TRAP    #15
    MOVE.L  D4,D1


    RTS
ROL_ROR_REG_SECT    *Rotation. Determines direction.
    MOVE.W  D1,D2                   *Copying OPCode Word for isolation of static bits.
    AND.W   #%1111000000011000,D2   *Isolating bits for detrmining validity of OPCode.
    CMP.W   #%1110000000011000,D2   *Comparing with valid value.
    BNE     PRINT_INVALID_OPCODE    *If it's not the valid value, then print error message.
    BTST    #8,D1
    BNE     ROL_REG_SECT
ROR_REG_SECT        *Output the message 'ROR.'.
    LEA     ROR_MESS,A1
    MOVE.B  #14,D0      
    TRAP    #15
    JSR     LSL_LSR_PRINT
    JMP     RELOOP
ASR_ASL_MEM_SECT    *Arithmeitc shift. Determines direction.
    MOVE.W  D1,D2                   *Copying OPCode Word for isolation of static bits.
    AND.W   #%1111111011000000,D2   *Isolating bits for detrmining validity of OPCode.
    CMP.W   #%1110000011000000,D2   *Comparing with valid value.
    BNE     PRINT_INVALID_OPCODE    *If it's not the valid value, then print error message.
    BTST    #8,D1
    BNE     ASL_MEM_SECT
ASR_MEM_SECT        *Output the message 'ASR.'.
    LEA     ASR_MESS,A1
    MOVE.B  #14,D0      
    TRAP    #15
    
    JSR     PRINT_W                  *Prints a W to the output window.
    JSR     PRINT_SPACE         *Prints a space to the output window.
    BTST    #5,D1
    BEQ     VALID_MODE_0_JSR
    
    JSR     VALID_MODE_1
    JMP     RELOOP
LSL_LSR_MEM_SECT    *Logical Shift. Determines direction.
    MOVE.W  D1,D2                   *Copying OPCode Word for isolation of static bits.
    AND.W   #%1111111011000000,D2   *Isolating bits for detrmining validity of OPCode.
    CMP.W   #%1110001011000000,D2   *Comparing with valid value.
    BNE     PRINT_INVALID_OPCODE    *If it's not the valid value, then print error message.
    BTST    #8,D1
    BNE     LSL_MEM_SECT
LSR_MEM_SECT        *Output the message 'LSR.'.
    LEA     LSR_MESS,A1
    MOVE.B  #14,D0      
    TRAP    #15
    JSR     PRINT_W                  *Prints a W to the output window.
    JSR     PRINT_SPACE         *Prints a space to the output window.
    
    BTST    #5,D1
    BEQ     VALID_MODE_0_JSR
    
    JSR     VALID_MODE_1
    JMP     RELOOP    
ROL_ROR_MEM_SECT    *Rotation. Determines direction.
    MOVE.W  D1,D2                   *Copying OPCode Word for isolation of static bits.
    AND.W   #%1111111011000000,D2   *Isolating bits for detrmining validity of OPCode.
    CMP.W   #%1110011011000000,D2   *Comparing with valid value.
    BNE     PRINT_INVALID_OPCODE    *If it's not the valid value, then print error message.
    BTST    #8,D1
    BNE     ROL_MEM_SECT
ROR_MEM_SECT        *Output the message 'ROR.'.
    LEA     ROR_MESS,A1
    MOVE.B  #14,D0      
    TRAP    #15
    
    JSR     PRINT_W                  *Prints a W to the output window.
    JSR     PRINT_SPACE         *Prints a space to the output window.
    BTST    #5,D1
    BEQ     VALID_MODE_0_JSR
    
    JSR     VALID_MODE_1 
    JMP     RELOOP
MEM_SHIFTS      *This is a memory shift.
    MOVE.B  #%11110100,D7       *Valid modes for this OPCode.
    JSR     SRC_EFF_ADDR_MODE_REG   *Check value in mode for validity
    BTST    #0,D3                   *Checking result of subroutine's check for valid final 6 bits.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.
    MOVE.W  D1,D2                  *Create a copy of D1 in D2 in order to mask some of its bits and keep original.
    AND.W   #%0000011000000000,D2   *Significant bits for determining what kind of shift.
    CMP.W   #%0000001000000000,D2   *Compare with the shift with the middle value in the range.
    BGT     ROL_ROR_MEM_SECT
    BEQ     LSL_LSR_MEM_SECT
    BRA     ASR_ASL_MEM_SECT
    
BIN_1101_FOURTH *Possibilities are ADD and ADDA.
    MOVE.W  D1,D2           *Create a copy of D1 in D2 in order to mask some of its bits and keep original.
    AND.W   #%0000000011000000,D2   *These bits are required to tell the difference between ADDA and ADD.
    CMP.W   #%0000000011000000,D2
    BEQ     ADDA_SECT
ADD_SECT
    MOVE.W  D1,D2                   *Copying OPCode Word for isolation of static bits.
    AND.W   #%1111000000000000,D2   *Isolating bits for detrmining validity of OPCode.
    CMP.W   #%1101000000000000,D2   *Comparing with valid value.
    BNE     PRINT_INVALID_OPCODE    *If it's not the valid value, then print error message.
    JSR     VALIDATE_OPMODE_FIELD   *Subroutine validates OPMode field of subroutine.
    BTST    #0,D3                   *Checking result of subroutine's check for valid OPMode.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.
    LEA     ADD_MESS,A1     *Outputs the message 'ADD.'.
    MOVE.B  #14,D0      
    TRAP    #15
    
    BTST    #8,D1
    BNE     ADD_DN_EA
ADD_EA_DN                   *This is ADD with the OPMode bieng <ea> -> Dn
    MOVE.B  #%11111111,D7       *Valid modes for this OPCode.
    JSR     SRC_EFF_ADDR_MODE_REG   *Check value in mode for validity
    BTST    #0,D3                   *Checking result of subroutine's check for valid final 6 bits.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.
    JSR     PRINT_OPMODE_ADD_EA_DN
    
    JMP     RELOOP
ADD_DN_EA                   *This is ADD with the OPMode bieng Dn -> <ea>
    MOVE.B  #%11110100,D7       *Valid modes for this OPCode.
    JSR     SRC_EFF_ADDR_MODE_REG   *Check value in mode for validity
    BTST    #0,D3                   *Checking result of subroutine's check for valid final 6 bits.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.
    JSR     PRINT_OPMODE_ADD_DN_EA
    JMP     RELOOP

ADDA_SECT
    MOVE.W  D1,D2                   *Copying OPCode Word for isolation of static bits.
    AND.W   #%1111000000000000,D2   *Isolating bits for detrmining validity of OPCode.
    CMP.W   #%1101000000000000,D2   *Comparing with valid value.
    BNE     PRINT_INVALID_OPCODE    *If it's not the valid value, then print error message.
    MOVE.B  #%11111111,D7       *Valid modes for this OPCode.
    JSR     SRC_EFF_ADDR_MODE_REG   *Check value in mode for validity
    BTST    #0,D3                  *Checking result of subroutine's check for valid final 6 bits.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.
    MOVE.W  D1,D2
    AND.W   #%0000000111000000,D2
    CMP.W   #%0000000111000000,D2
    BEQ     ADDA_VALID_SECT
    CMP.W   #%0000000011000000,D2
    BNE     PRINT_INVALID_OPCODE
    
ADDA_VALID_SECT
    LEA     ADDA_MESS,A1    *Outputs the message 'ADDA.'.
    MOVE.B  #14,D0      
    TRAP    #15
    JSR     ADDA_PRINT_OPMODE               *Print the opmode
    JSR     ADDA_IMMEDIATE_ADDR_TEST        *Test to see if its immediate addressing, signaled with a #, if it is we need a different case
    JMP     RELOOP
    
    
ADDA_IMMEDIATE_ADDR_TEST
    MOVE.L  D1,D4
    BTST    #5,D1                           *Test if the first digit is 1
    BEQ     ADDA_RETURN
    BTST    #4,D1                           *Test if the second digit is 1
    BEQ     ADDA_RETURN
    BTST    #3,D1                           *Test if the third digit is 1 
    BEQ     ADDA_RETURN  

    BTST    #2,D1
    BEQ     ADDA_PRINT_ADDRESS                 
    
    *If test cases pass, then the mode = 111 and we need to pop a word or long based on the opcode
    
    JSR     PRINT_POUND         *Prints a # to the output window.
    JSR     PRINT_$             *Prints a $ to the output window.
    
    BTST    #8,D1                           *Test the 8th bit to see if it is word addressed or long addressed
    BEQ     ADDA_IMMEDIATE_WORD
    
    MOVE.L  (A2)+,D6                        *This gets the remaining word from the function
    
    CLR.L   D2
    MOVE.L  D1,D4                           *Copy the bits to D4, because we are going to print and need to use D1
    MOVE.L  D6,D1
    MOVE.L  D1,D2                    
    JSR     OUTPUT_HEXADECIMAL
    MOVE.L  D4,D1
    
    JMP     ADDA_PRINT_An   

ADDA_PRINT_ADDRESS
    JSR     PRINT_$
    BTST    #0,D1
    BNE     ADDA_PRINT_LONG_ADDRESS
ADDA_PRINT_WORD_ADDRESS
    MOVE.W  (A2)+,D2               *This gets the remaining word from the function
    JSR     OUTPUT_HEXADECIMAL
    BRA     ADDA_PRINT_AN
ADDA_PRINT_LONG_ADDRESS
    MOVE.L  (A2)+,D2               *This gets the remaining Long from the function
    JSR     OUTPUT_HEXADECIMAL
    BRA     ADDA_PRINT_AN
    
ADDA_IMMEDIATE_WORD
    MOVE.W  (A2)+,D6               *This gets the remaining word from the function
    CLR.L   D2
    MOVE.L  D1,D4                           *Copy the bits to D4, because we are going to print and need to use D1
    MOVE.L  D6,D1
    CLR.L   D2
    MOVE.L  D1,D2  
    MOVE.L  D4,D1                  
    JSR     OUTPUT_HEXADECIMAL

ADDA_PRINT_An
    JSR     PRINT_COMMA                     *Prints a comma to the output window.
    JSR     PRINT_A                         *Prints an A to the output window.
    MOVE.L  D1,D4
    
    CLR.L   D6
    MOVE.B  #20,D6
    LSL.L   D6,D1
    CLR.L   D6
    MOVE.B  #29,D6
    LSR.L   D6,D1
    
    MOVE.B  #3,D0                   *Move trap task  #15 to convert to decimal and print  
    TRAP    #15
    MOVE.L  D4,D1
    RTS                                     *Return from sub-routine
 
ADDA_RETURN
    BTST    #5,D1    
    BEQ     ADDA_VALID_MODE_0_JSR
    JSR     VALID_MODE_1
    BRA     ADDA_PRINT_An
    
    RTS     
ADDA_VALID_MODE_0_JSR
    JSR     VALID_MODE_0
    JMP     ADDA_PRINT_An
    RTS
BTST    
    BTST    #5,D1
    BEQ     VALID_MODE_0_JSR
    
    JSR     VALID_MODE_1 
    JMP     RELOOP
    
ADDA_PRINT_OPMODE
    BTST    #8,D1
    BNE     ADDA_PRINT_LONG
    JSR     PRINT_W                  *Prints a W to the output window.
    JSR     PRINT_SPACE         *Prints a space to the output window.
    RTS
ADDA_PRINT_LONG
    JSR     PRINT_L                  *Prints a L to the output window.
    JSR     PRINT_SPACE         *Prints a space to the output window.
    RTS
NOP_SECT                    *Outputs the message 'NOP'.
    LEA     NOP_MESS,A1 
    MOVE.B  #14,D0      
    TRAP    #15
    JMP     RELOOP
RTS_SECT                    *Outputs the message 'RTS'.
    LEA     RTS_MESS,A1 
    MOVE.B  #14,D0      
    TRAP    #15
    JMP     RELOOP         
CMP_SECT                *Outputs the message 'CMP.'.
    MOVE.W  D1,D2                   *Copying OPCode Word for isolation of static bits.
    AND.W   #%1111000000000000,D2   *Isolating bits for detrmining validity of OPCode.
    CMP.W   #%1011000000000000,D2   *Comparing with valid value.
    BNE     PRINT_INVALID_OPCODE    *If it's not the valid value, then print error message.
    MOVE.B  #%11111111,D7           *Valid modes for this OPCode.
    JSR     SRC_EFF_ADDR_MODE_REG   *Check value in mode for validity
    BTST    #0,D3                   *Checking result of subroutine's check for valid final 6 bits.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.
    MOVE.W  D1,D2
    AND.W   #%0000000111000000,D2
    CMP.W   #%0000000010000000,D2
    BGT     CMPA_SECT
    LEA     CMP_MESS,A1 
    MOVE.B  #14,D0      
    TRAP    #15    
    JSR     PRINT_OPMODE_ADD_EA_DN
    JMP     RELOOP   
CMPA_SECT                *Outputs the message 'CMPA.'.
    BTST    #6,D1
    BEQ     PRINT_INVALID_OPCODE
    BTST    #7,D1
    BEQ     PRINT_INVALID_OPCODE
    LEA     CMPA_MESS,A1 
    MOVE.B  #14,D0      
    TRAP    #15  
    JSR     PRINT_OPMODE_ADD_EA_AN
    JMP     RELOOP
 
SUB_SECT                    *Outputs the message 'SUB.'.
    MOVE.W  D1,D2                   *Copying OPCode Word for isolation of static bits.
    AND.W   #%1111000000000000,D2   *Isolating bits for detrmining validity of OPCode.
    CMP.W   #%1001000000000000,D2   *Comparing with valid value.
    BNE     PRINT_INVALID_OPCODE    *If it's not the valid value, then print error message.
    JSR     VALIDATE_OPMODE_FIELD   *Subroutine validates OPMode field of subroutine.
    BTST    #0,D3                   *Checking result of subroutine's check for valid OPMode.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.
    LEA     SUB_MESS,A1 
    MOVE.B  #14,D0      
    TRAP    #15
    
    BTST    #8,D1
    BNE     SUB_DN_EA
SUB_EA_DN                   *This is ADD with the OPMode bieng <ea> -> Dn
    MOVE.B  #%11111111,D7       *Valid modes for this OPCode.
    JSR     SRC_EFF_ADDR_MODE_REG   *Check value in mode for validity
    BTST    #0,D3                   *Checking result of subroutine's check for valid final 6 bits.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.
    JSR     PRINT_OPMODE_ADD_EA_DN
    JMP     RELOOP  
SUB_DN_EA                   *This is ADD with the OPMode bieng Dn -> <ea>
    MOVE.B  #%11110100,D7       *Valid modes for this OPCode.
    JSR     SRC_EFF_ADDR_MODE_REG   *Check value in mode for validity
    BTST    #0,D3                   *Checking result of subroutine's check for valid final 6 bits.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.
    JSR     PRINT_OPMODE_ADD_DN_EA
    JMP     RELOOP
        
DIVU_SECT                   *Outputs the message 'DIVU.'.
    MOVE.W  D1,D2                   *Copying OPCode Word for isolation of static bits.
    AND.W   #%1111000111000000,D2   *Isolating bits for detrmining validity of OPCode.
    CMP.W   #%1000000011000000,D2   *Comparing with valid value.
    BNE     PRINT_INVALID_OPCODE    *If it's not the valid value, then print error message.
    MOVE.B  #%11111101,D7           *Valid modes for this OPCode.
    JSR     SRC_EFF_ADDR_MODE_REG   *Check value in mode for validity
    BTST    #0,D3                   *Checking result of subroutine's check for valid final 6 bits.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.
    LEA     DIVU_MESS,A1 
    MOVE.B  #14,D0      
    TRAP    #15
    
    JSR     PRINT_OPMODE_MULS_EA_DN
    JMP     RELOOP 
MOVEA_SECT
    MOVE.B  #%11111111,D7       *Valid modes for this OPCode(SourceEA).
    JSR     SRC_EFF_ADDR_MODE_REG   *Check value in mode for validity.
    BTST    #0,D3                   *Checking result of subroutine's check for valid final 6 bits.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.
    MOVE.B  #%11001101,D3           *Shift count of 13 for VALIDATE_SIZE, and any size but BYTE accepted.
    JSR     VALIDATE_SIZE_MOVELIKE  *Subroutine for validating size portion of OPCode.
    BTST    #0,D3                   *Checking result of subroutine's check for valid final 6 bits.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.
    LEA     MOVEA_MESS,A1   *Outputs the message 'MOVEA.'.
    MOVE.B  #14,D0      
    TRAP    #15
    
    *JMP     RELOOP 
MOVEA_VALID_SECT
    JSR     MOVEA_PRINT_OPMODE               *Print the opmode
    JSR     MOVEA_IMMEDIATE_ADDR_TEST        *Test to see if its immediate addressing, signaled with a #, if it is we need a different case 
    JMP     RELOOP
    
MOVEA_IMMEDIATE_ADDR_TEST
    BTST    #5,D1                           *Test if the first digit is 1
    BEQ     MOVEA_RETURN
    BTST    #4,D1                           *Test if the second digit is 1
    BEQ     MOVEA_RETURN
    BTST    #3,D1                           *Test if the third digit is 1 
    BEQ     MOVEA_RETURN    
    BTST    #2,D1                           *If set, #<data> is the case.
    BEQ     MOVEA_RETURN                 
    
    *If test cases pass, then the mode = 111 and we need to pop a word or long based on the opcode
    
    JSR     PRINT_POUND         *Prints a # to the output window.
    JSR     PRINT_$             *Prints a $ to the output window.
    
    BTST    #12,D1                           *Test the 8th bit to see if it is word addressed or long addressed
    BNE     MOVEA_IMMEDIATE_WORD
    
    MOVE.L  (A2)+,D6                        *This gets the remaining word from the function
    
    CLR.L   D2
    MOVE.L  D1,D4                           *Copy the bits to D4, because we are going to print and need to use D1
    MOVE.L  D6,D1
    
    MOVE.L  D1,D2                    
    JSR     OUTPUT_HEXADECIMAL
    MOVE.L  D4,D1
    
    JMP     MOVEA_PRINT_An   
    
    
MOVEA_IMMEDIATE_WORD
    MOVE.W  (A2)+,D6               *This gets the remaining word from the function
    CLR.L   D2
    MOVE.L  D1,D4                           *Copy the bits to D4, because we are going to print and need to use D1
    MOVE.L  D6,D1
    MOVE.L  D1,D2                    
    JSR     OUTPUT_HEXADECIMAL
    MOVE.L  D4,D1


MOVEA_PRINT_An
    JSR     PRINT_COMMA         *Prints a comma to the output window.
    JSR     PRINT_A                         *Prints an A to the output window.
    
    CLR.L   D6
    MOVE.B  #20,D6
    LSL.L   D6,D1
    CLR.L   D6
    MOVE.B  #29,D6
    LSR.L   D6,D1
    
    MOVE.B  #3,D0                   *Move trap task  #15 to convert to decimal and print  
    TRAP    #15
    
    RTS                                     *Return from sub-routine
 
MOVEA_RETURN
    BTST    #5,D1    
    BEQ     MOVEA_VALID_MODE_0_JSR
    JSR     VALID_MODE_1
    JMP     MOVEA_PRINT_An    
MOVEA_VALID_MODE_0_JSR
    JSR     VALID_MODE_0
    JMP     MOVEA_PRINT_An
    RTS
MOVEA_PRINT_OPMODE
    BTST    #12,D1
    BEQ     MOVEA_PRINT_LONG
    JSR     PRINT_W                  *Prints a W to the output window.
    JSR     PRINT_SPACE         *Prints a space to the output window.
    RTS
MOVEA_PRINT_LONG
    JSR     PRINT_L                  *Prints a L to the output window.
    JSR     PRINT_SPACE         *Prints a space to the output window.
    RTS
 
ADDQ_SECT  
    MOVE.B  #%11110111,D7           *Valid modes for this OPCode.
    JSR     SRC_EFF_ADDR_MODE_REG   *Check value in mode for validity.
    BTST    #0,D3                   *Checking result of subroutine's check for valid final 6 bits.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.
    MOVE.W  D1,D2                   *Copying OPCode Word for isolation of static bits.
    AND.W   #%1111000100000000,D2   *Isolating bits for detrmining validity of OPCode.
    CMP.W   #%0101000000000000,D2   *Comparing with valid value.
    BNE     PRINT_INVALID_OPCODE    *If it's not the valid value, then print error message.
    MOVE.B  #%11100111,D3           *Shift count of 7 for VALIDATE_SIZE and any size accepted.
    JSR     VALIDATE_SIZE_CLRLIKE   *Subroutine for validating size portion of OPCode.
    BTST    #0,D3                   *Checking result of subroutine's check for valid final 6 bits.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.   
    LEA     ADDQ_MESS,A1    *Outputs the message 'ADDQ.'.
    MOVE.B  #14,D0      
    TRAP    #15
    
    MOVE.W  D1,D4
    JSR     ADDQ_PRINT_ADDR_MODE
    
    MOVE.W  D1,D4
    JSR     PRINT_SPACE         *Prints a space to the output window.    
    
    JSR     PRINT_POUND         *Prints a # to the output window.
    MOVE.L  D4,D1
    
    JSR     ADDQ_PRINT_DATA
    
    JSR     PRINT_COMMA         *Prints a comma to the output window.
    MOVE.L  D4,D1
    
    BTST    #5,D1
    BEQ     VALID_MODE_0_JSR
    
    JSR     VALID_MODE_1 
    JMP     RELOOP

ADDQ_PRINT_DATA
    MOVE.L  #20,D7
    LSL.L   D7,D1
    MOVE.L  #29,D7
    LSR.L   D7,D1
    MOVE.L  #3,D0
    CMP.W   #0,D1
    BEQ     ADDQ_PRINT_8
    TRAP    #15
    
    RTS
ADDQ_PRINT_8
    MOVE.B  #8,D1
    TRAP    #15
    RTS 
ADDQ_PRINT_ADDR_MODE
    BTST    #7,D1
    BNE     ADDQ_PRINT_ADDR_MODE_LONG
    BTST    #6,D1
    BNE     ADDQ_PRINT_ADDR_MODE_WORD

    JSR     PRINT_B                  *Prints a B to the output window.
    MOVE.W  D4,D1                    *Move original unaltered bits back to D1
    RTS
    
    JMP     RELOOP
ADDQ_PRINT_ADDR_MODE_WORD
    JSR     PRINT_W                  *Prints a W to the output window.
    RTS

ADDQ_PRINT_ADDR_MODE_LONG
    JSR     PRINT_L                  *Prints a L to the output window.
    RTS
MOVEM_SECT       
    BTST    #10,D1
    BNE     MOVEM_MEM_REG
MOVEM_REG_MEM               *Direction of transfer is register to memory.
    MOVE.B  #%11100100,D7       *Valid modes for this OPCode.
    JSR     SRC_EFF_ADDR_MODE_REG   *Check value in mode for validity
    BTST    #0,D3                   *Checking result of subroutine's check for valid final 6 bits.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.
    MOVE.W  D1,D2                   *Copying OPCode Word for isolation of static bits.
    AND.W   #%1111101110000000,D2   *Isolating bits for detrmining validity of OPCode.
    CMP.W   #%0100100010000000,D2   *Comparing with valid value.
    BNE     PRINT_INVALID_OPCODE    *If it's not the valid value, then print error message.
    LEA     MOVEM_MESS,A1   *Outputs the message 'MOVEM.'.
    MOVE.B  #14,D0      
    TRAP    #15
    
    CLR.L   D6
    MOVE.W  (A2)+,D6                *Get the remaining word for this OPCode.
    
    JSR     TEST_LONG_WORD
    JSR     CHECK_ADDR_MODE
    MOVE.L  D1,D2
    AND.L   #%111000,D2
    CMP.L   #%100000,D2
    BEQ     MOVEM_PRINT_LIST_REVERSE
    JSR     MOVEM_PRINT_LIST
MOVEM_REG_PRINT_SECOND
    JSR     JSR_COMMA
    BTST    #5,D1
    BEQ     VALID_MODE_0_MOVEM_REG_MEM_JSR    
    JSR     VALID_MODE_1    
    JMP     RELOOP
    
MOVEM_PRINT_LIST_REVERSE
    MOVEM.L D0-D7,-(SP)
    MOVE.L  #16,D3
    JSR     PRINT_REGISTERS_REVERSE
    MOVEM.L (SP)+,D0-D7
    BRA     MOVEM_REG_PRINT_SECOND

MOVEM_PRINT_LIST
    MOVEM.L D0-D7,-(SP)
    MOVE.L  #16,D3
    JSR     PRINT_REGISTERS_FORWARDS
    MOVEM.L (SP)+,D0-D7
    RTS

PRINT_REGISTERS_FORWARDS
    JSR     FIND_SET_INDEX
    CMP.L   #0,D3
    BLT     PRINT_INVALID_OPCODE
    MOVE.L  D3,D7
    JSR     FIND_SET_INDEX_LIST
    ADD.L   #1,D3
    CMP.L   D7,D3
    BEQ     PRINT_SINGULAR_FORWARDS
    JSR     PRINT_RANGE_FORWARDS 
AFTER_START_FORWARDS
    JSR     FIND_SET_INDEX
    CMP.L   #0,D3
    BEQ     PRINT_SINGULAR_FORWARDS_END
    BLT     AFTER_END
    JSR     PRINT_SLASH
    MOVE.L  D3,D7
    JSR     FIND_SET_INDEX_LIST
    ADD.L   #1,D3
    CMP.L   D7,D3
    BEQ     PRINT_SINGULAR_FORWARDS
    JSR     PRINT_RANGE_FORWARDS
    CMP.L   #0,D3
    BGT     AFTER_START_FORWARDS
    BRA     AFTER_END 

PRINT_REGISTERS_REVERSE
    JSR     FIND_SET_INDEX
    CMP.L   #0,D3
    BLT     PRINT_INVALID_OPCODE
    MOVE.L  D3,D7
    JSR     FIND_SET_INDEX_LIST
    ADD.L   #1,D3
    CMP.L   D7,D3
    BEQ     PRINT_SINGULAR_REVERSE
    JSR     PRINT_RANGE_REVERSE 
AFTER_START_REVERSE
    JSR     FIND_SET_INDEX
    CMP.L   #0,D3
    BEQ     PRINT_SINGULAR_REVERSE_END
    BLT     AFTER_END
    JSR     PRINT_SLASH
    MOVE.L  D3,D7
    JSR     FIND_SET_INDEX_LIST
    ADD.L   #1,D3
    CMP.L   D7,D3
    BEQ     PRINT_SINGULAR_REVERSE
    JSR     PRINT_RANGE_REVERSE
    CMP.L   #0,D3
    BGT     AFTER_START_REVERSE
AFTER_END
    RTS
   
PRINT_RANGE_FORWARDS    *Prints registers in the format An-Am, Dn-Dm, or An-Dm.
    CMP.L   #8,D7
    BLT     D_RANGE_FORWARDS
A_RANGE_FORWARDS
    JSR     PRINT_A
    MOVE.L  D7,D2
    SUB.L   #8,D2
    JSR     OUTPUT_HEXADECIMAL
    JSR     PRINT_MINUS
    JSR     PRINT_SECOND_PART_FORWARD
    RTS
D_RANGE_FORWARDS
    JSR     PRINT_D
    MOVE.L  D7,D2
    JSR     OUTPUT_HEXADECIMAL
    JSR     PRINT_MINUS
    JSR     PRINT_D
    MOVE.L  D3,D2
    JSR     OUTPUT_HEXADECIMAL
    RTS
PRINT_SECOND_PART_FORWARD
    CMP.L   #8,D3
    BLT     D_RANGE_SECOND_FORWARD
A_RANGE_SECOND_FORWARD
    JSR     PRINT_A
    MOVE.L  D3,D2
    SUB.L   #8,D2
    JSR     OUTPUT_HEXADECIMAL
    RTS
D_RANGE_SECOND_FORWARD
    JSR     PRINT_D
    MOVE.L  D3,D2
    JSR     OUTPUT_HEXADECIMAL
    RTS
    
PRINT_RANGE_REVERSE    *Prints registers in the format An-Am, Dn-Dm, or An-Dm.
    CMP.L   #8,D7
    BGE     D_RANGE_REVERSE
A_RANGE_REVERSE
    JSR     PRINT_A
    MOVE.L  #7,D2
    SUB.L   D7,D2
    JSR     OUTPUT_HEXADECIMAL
    JSR     PRINT_MINUS
    JSR     PRINT_SECOND_PART_REVERSE
    RTS
D_RANGE_REVERSE
    JSR     PRINT_D
    MOVE.L  #15,D2
    SUB.L   D7,D2
    JSR     OUTPUT_HEXADECIMAL
    JSR     PRINT_MINUS
    JSR     PRINT_D
    MOVE.L  #15,D2
    SUB.L   D3,D2
    JSR     OUTPUT_HEXADECIMAL
    RTS
PRINT_SECOND_PART_REVERSE
    CMP.L   #8,D3
    BGE     D_RANGE_SECOND_REVERSE
A_RANGE_SECOND_REVERSE
    JSR     PRINT_A
    MOVE.L  #7,D2
    SUB.L   D3,D2
    JSR     OUTPUT_HEXADECIMAL
    RTS
D_RANGE_SECOND_REVERSE
    JSR     PRINT_D
    MOVE.L  #15,D2
    SUB.L   #8,D2
    JSR     OUTPUT_HEXADECIMAL
    RTS

PRINT_SINGULAR_REVERSE
    CMP.L   #8,D7
    BGE     PRINT_D_D7_REVERSE
    BRA     PRINT_A_D7_REVERSE
PRINT_SINGULAR_FORWARDS     *Prints the single register that was being moved.
    CMP.L   #8,D7
    BLT     PRINT_D_D7_FORWARDS
    BRA     PRINT_A_D7_FORWARDS

PRINT_D_D7_REVERSE
    JSR     PRINT_D
    MOVE.L  #15,D2
    SUB.L   D7,D2
    JSR     OUTPUT_HEXADECIMAL
    BRA     AFTER_START_REVERSE

PRINT_A_D7_REVERSE
    JSR     PRINT_A
    MOVE.L  #7,D2
    SUB.L   D7,D2
    JSR     OUTPUT_HEXADECIMAL
    BRA     AFTER_START_REVERSE
    
PRINT_D_D7_FORWARDS
    JSR     PRINT_D
    MOVE.L  D7,D2
    JSR     OUTPUT_HEXADECIMAL
    BRA     AFTER_START_FORWARDS

PRINT_A_D7_FORWARDS
    JSR     PRINT_A
    MOVE.L  D7,D2
    SUB.L   #8,D2
    JSR     OUTPUT_HEXADECIMAL
    BRA     AFTER_START_FORWARDS
    
PRINT_SINGULAR_FORWARDS_END     *Prints the single register that was being moved.
    JSR     PRINT_SLASH
    CMP.L   #8,D7
    BLT     PRINT_D_D7_END_FORWARDS
    BRA     PRINT_A_D7_FORWARDS

PRINT_D_D7_END_FORWARDS
    JSR     PRINT_D
    MOVE.L  D3,D2
    JSR     OUTPUT_HEXADECIMAL
    RTS

PRINT_A_D7_END_REVERSE
    JSR     PRINT_A
    MOVE.L  #7,D2
    SUB.L   D3,D2
    JSR     OUTPUT_HEXADECIMAL
    RTS
    
PRINT_SINGULAR_REVERSE_END     *Prints the single register that was being moved.
    JSR     PRINT_SLASH
    CMP.L   #8,D7
    BLT     PRINT_A_D7_END_REVERSE
    BRA     PRINT_D_D7_REVERSE
    
FIND_SET_INDEX  *Finds the next bit in the register list mask that is set. Sets the index in D3.
    SUB.L   #1,D3
    CMP.L   #0,D3
    BLT     FINISHED_FINDING
    BTST    D3,D6
    BEQ     FIND_SET_INDEX
FINISHED_FINDING    
    RTS
    
FIND_SET_INDEX_LIST *Finds the next bit in the register list mask that is not set. Sets the index in D3.
*The difference between D3 and D7 should give the number of contiguous registers.
    SUB.L   #1,D3
    CMP.L   #0,D3
    BLT     FINISHED_FINDING
    BTST    D3,D6
    BNE     FIND_SET_INDEX_LIST
    BRA     FINISHED_FINDING
*********

MOVEM_PRINT_An
    MOVE.L  D1,D4
    MOVE.L  D0,D7
    JSR     PRINT_A                         *Prints an A to the output window.

    SUB.L   #8,D5
    MOVE.L  D5,D1

    MOVE.B  #3,D0                   *Move trap task  #15 to convert to decimal and print  
    TRAP    #15
    JSR     PRINT_MINUS         *Prints a - to the output window.

    JSR     PRINT_A                         *Prints an A to the output window.
    MOVE.L  #3,D0                   *Move trap task  #15 to convert to decimal and print
    CLR.L   D1
    SUB.L   #8,D7
    MOVE.L  D7,D1
    TRAP    #15
    MOVE.L  D4,D1
    RTS
MOVEM_PRINT_Dn
    MOVEM.L D1-D2,-(SP)
    JSR     PRINT_D   
    MOVE.L  D7,D2                    
    JSR     OUTPUT_HEXADECIMAL    
    JSR     PRINT_MINUS         *Prints a - to the output window.
    JSR     PRINT_D 
    MOVE.L  D5,D1   
    MOVE.L  D1,D2                    
    JSR     OUTPUT_HEXADECIMAL
    MOVEM.L (SP)+,D1-D2
    RTS

********
MOVEM_PRINT_REVERSE_An
    MOVE.L  D1,D4
    CLR.L   D7
    MOVE.L  D0,D7
    CLR.L   D0
    JSR     PRINT_A                         *Prints an A to the output window.

    MOVE.L  #7,D1
    SUB.L   D5,D1

    MOVE.B  #3,D0                   *Move trap task  #15 to convert to decimal and print  
    TRAP    #15
    JSR     PRINT_MINUS         *Prints a - to the output window.

    JSR     PRINT_A                         *Prints an A to the output window.
    MOVE.L  #3,D0                   *Move trap task  #15 to convert to decimal and print
    CLR.L   D1
    MOVE.L  #7,D1
    SUB.L   D7,D1
    TRAP    #15
    MOVE.L  D4,D1
    RTS
MOVEM_PRINT_REVERSE_Dn
    MOVE.L  D1,D4
    CLR.L   D7
    MOVE.L  D0,D7
    CLR.L   D0
    JSR     PRINT_D

    MOVE.L  #15,D1
    SUB.L   D5,D1

    MOVE.B  #3,D0                   *Move trap task  #15 to convert to decimal and print  
    TRAP    #15
    JSR     PRINT_MINUS         *Prints a - to the output window.

    JSR     PRINT_D
    MOVE.L  #3,D0                   *Move trap task  #15 to convert to decimal and print
    CLR.L   D1
    MOVE.L  #15,D1
    SUB.L   D7,D1
    TRAP    #15
    MOVE.L  D4,D1
    RTS

TEST_LONG_WORD
    MOVE.L  D1,D4
    BTST    #6,D1
    BNE     MOVEM_PRINT_LONG_JSR
    JSR     MOVEM_PRINT_WORD
    
    RTS
MOVEM_PRINT_LONG_JSR
    JSR     MOVEM_PRINT_LONG
    RTS
    
MOVEM_PRINT_LONG_JSR_RELOOP
    JSR     MOVEM_PRINT_LONG
    JMP     MOVEM_MEM_PRINTED_SIZE
    
MOVEM_MEM_REG               *Direction of transfer is memory to register.
    LEA     MOVEM_MESS,A1   *Outputs the message 'MOVEM.'.
    MOVE.B  #14,D0      
    TRAP    #15
    MOVE.B  #%11010100,D7       *Valid modes for this OPCode.
    JSR     SRC_EFF_ADDR_MODE_REG   *Check value in mode for validity
    BTST    #0,D3                   *Checking result of subroutine's check for valid final 6 bits.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.
    CLR.L   D6
    MOVE.W  (A2)+,D6                *Get the remaining word for this OPCode.
    BTST    #6,D1
    BNE     MOVEM_PRINT_LONG_JSR_RELOOP    
    JSR     MOVEM_PRINT_WORD   
MOVEM_MEM_PRINTED_SIZE    
    BTST    #5,D1
    BEQ     VALID_MODE_0_MOVEM_MEM_REG_JSR
    JSR     VALID_MODE_1
MOVEM_MEM_PRINT_SECOND
    JSR     JSR_COMMA
    JSR     MOVEM_PRINT_LIST
    
    JMP     RELOOP
  
CHECK_ADDR_MODE
    BTST    #5,D1
    BNE     CHECK_ADDR_MODE_1
    
    RTS
    
CHECK_ADDR_MODE_1
    BTST    #3,D1
    BEQ     CHECK_ADDR_MODE_100
    RTS
    
CHECK_ADDR_MODE_100
    CLR.L   D7
    MOVE.L  #1,D7
    RTS

JSR_COMMA  
    MOVE.L  D1,D4
    JSR     PRINT_COMMA         *Prints a comma to the output window.
    MOVE.L  D4,D1
    RTS
    
VALID_MODE_0_MOVEM_MEM_REG_JSR 
    JSR     VALID_MODE_0
    JMP     MOVEM_MEM_PRINT_SECOND
    
VALID_MODE_0_MOVEM_REG_MEM_JSR 
    JSR     VALID_MODE_0
    JMP     RELOOP

MOVEM_PRINT_LONG    
    JSR     PRINT_L                  *Prints a L to the output window.
    JSR     PRINT_SPACE         *Prints a space to the output window.
    RTS
 
MOVEM_PRINT_WORD    
    MOVE.L  D1,-(SP)
    JSR     PRINT_W                  *Prints a W to the output window.
    JSR     PRINT_SPACE         *Prints a space to the output window.
    MOVE.L  (SP)+,D1
    RTS
   
JSR_SECT    
    MOVE.B  #%11000100,D7       *Valid modes for this OPCode.
    JSR     SRC_EFF_ADDR_MODE_REG   *Check value in mode for validity.
    BTST    #0,D3                   *Checking result of subroutine's check for valid final 6 bits.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.
    MOVE.W  D1,D2                   *Copying OPCode Word for isolation of static bits.
    AND.W   #%1111111111000000,D2   *Isolating bits for detrmining validity of OPCode.
    CMP.W   #%0100111010000000,D2   *Comparing with valid value.
    BNE     PRINT_INVALID_OPCODE    *If it's not the valid value, then print error message.
    LEA     JSR_MESS,A1     *Outputs the message 'JSR'.
    MOVE.B  #14,D0      
    TRAP    #15
              
    JSR     PRINT_SPACE         *Prints a space to the output window. 
    BTST    #5,D1
    BEQ     VALID_MODE_0_JSR
    JSR     VALID_MODE_1   
    JMP     RELOOP

LEA_SECT
    MOVE.B  #%11000100,D7       *Valid modes for this OPCode.
    JSR     SRC_EFF_ADDR_MODE_REG   *Check value in mode for validity.
    BTST    #0,D3                   *Checking result of subroutine's check for valid final 6 bits.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.
    MOVE.W  D1,D2                   *Copying OPCode Word for isolation of static bits.
    AND.W   #%1111000111000000,D2   *Isolating bits for detrmining validity of OPCode.
    CMP.W   #%0100000111000000,D2   *Comparing with valid value.
    BNE     PRINT_INVALID_OPCODE    *If it's not the valid value, then print error message.
    LEA     LEA_MESS,A1     *Outputs the message 'LEA'.
    MOVE.B  #14,D0      
    TRAP    #15
    
    
    JMP     LEA_PRINT
    JMP     RELOOP

LEA_PRINT_IMMED_ADDR_LONG
    MOVE.W  (A2)+,D6         *Get the remaining word
    CMP.W   #0,D6            *Compare to 0, if it is 0, print 0000
    
    MOVE.L  D6,D1
    MOVE.L  D1,D2                    
    JSR     OUTPUT_HEXADECIMAL

    RTS 
LEA_PRINT
    MOVE.L  D1,D4
    
    JSR     PRINT_SPACE         *Prints a space to the output window.
    
    MOVE.L  D4,D1
    BTST    #5,D1
    BEQ     VALID_MODE_0_LEA_JSR
    
    JSR     VALID_MODE_1     
    JMP     LEA_PRINT_An
VALID_MODE_0_LEA_JSR
    JSR     VALID_MODE_0
LEA_PRINT_An
   * JSR     LEA_PRINT_IMMED_ADDR_LONG
    JSR     PRINT_COMMA         *Prints a comma to the output window.
    JSR     PRINT_A                         *Prints an A to the output window.
    MOVE.L  D4,D1                           *Move orginial opcode back into D1
    
    CLR.L   D6
    MOVE.B  #20,D6
    LSL.L   D6,D1
    CLR.L   D6
    MOVE.B  #29,D6
    LSR.L   D6,D1
    
    MOVE.B  #3,D0                   *Move trap task  #15 to convert to decimal and print  
    TRAP    #15
    JMP     RELOOP
    
MOVEQ_SECT
    MOVE.W  D1,D2                   *Copying OPCode Word for isolation of static bits.
    AND.W   #%1111000100000000,D2   *Isolating bits for detrmining validity of OPCode.
    CMP.W   #%0111000000000000,D2   *Comparing with valid value.
    BNE     PRINT_INVALID_OPCODE    *If it's not the valid value, then print error message.
    LEA     MOVEQ_MESS,A1   *Output the message 'MOVEQ '.
    MOVE.B  #14,D0      
    TRAP    #15
    
MOVEQ_PRINT
    MOVE.L  D1,D4
    JSR     PRINT_SPACE
    JSR     PRINT_POUND         *Prints a # to the output window.
    JSR     PRINT_$             *Prints a $ to the output window.
    
    CLR.L   D6
    MOVE.B  #24,D6
    LSL.L   D6,D1
    CLR.L   D6
    MOVE.B  #24,D6
    LSR.L   D6,D1
    
    MOVE.L  D1,D2
    JSR     OUTPUT_HEXADECIMAL
    
    JSR     PRINT_COMMA         *Prints a comma to the output window.
    JSR     PRINT_D
    MOVE.L  D4,D1                           *Move orginial opcode back into D1
    
    CLR.L   D6
    MOVE.B  #20,D6
    LSL.L   D6,D1
    CLR.L   D6
    MOVE.B  #29,D6
    LSR.L   D6,D1
    
    
    MOVE.B  #3,D0                   *Move trap task  #15 to convert to decimal and print  
    TRAP    #15
    
    JMP     RELOOP

MULS_SECT
    MOVE.W  D1,D2                   *Copying OPCode Word for isolation of static bits.
    AND.W   #%1111000111000000,D2   *Isolating bits for detrmining validity of OPCode.
    CMP.W   #%1100000111000000,D2   *Comparing with valid value.
    BNE     PRINT_INVALID_OPCODE    *If it's not the valid value, then print error message.
    MOVE.B  #%11111101,D7       *Valid modes for this OPCode.
    JSR     SRC_EFF_ADDR_MODE_REG   *Check value in mode for validity
    BTST    #0,D3                   *Checking result of subroutine's check for valid final 6 bits.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.
    LEA     MULS_MESS,A1    *Output the message 'MULS.'.
    MOVE.B  #14,D0      
    TRAP    #15
   
    JSR     PRINT_OPMODE_MULS_EA_DN
    JMP     RELOOP
    
PRINT_OPMODE_MULS_EA_DN
    JSR     PRINT_W                  *Prints a W to the output window.
    JSR     PRINT_SPACE         *Prints a space to the output window.
    JSR     PRINT_EA_SOURCE
    
    JSR     PRINT_COMMA         *Prints a comma to the output window.
    JSR     PRINT_D
    JSR     DN_REGISTER
    RTS

PRINT_EA_SOURCE_OPMODE
    MOVE.W  D1,D2
    AND.W   #%111100,D2
    CMP.W   #%111100,D2
    BNE     PRINT_EA_SOURCE
PRINT_EA_SOURCE_OPMODE_IMMEDIATE
    MOVEM.L D1-D2/D6,-(SP)
    BTST    #7,D1
    BNE     PRINT_IMMEDIATE_DATA_LONG
    BRA     PRINT_IMMEDIATE_DATA_WORD
PRINT_EA_SOURCE
    MOVEM.L D1-D2/D6,-(SP)
    BTST    #5,D1
    BNE     PRINT_EA_SOURCE_1

PRINT_EA_SOURCE_0
    BTST    #4,D1
    BNE     PRINT_EA_SOURCE_01
    
PRINT_EA_SOURCE_00
    BTST    #3,D1
    BNE     PRINT_EA_SOURCE_001
PRINT_EA_SOURCE_000
PRINT_DN
    JSR     PRINT_D
    MOVE.L  #29,D6
    LSL.L   D6,D1
    LSR.L   D6,D1
    MOVE.L  D1,D2
    JSR     OUTPUT_HEXADECIMAL
    MOVEM.L (SP)+,D1-D2/D6
    RTS
PRINT_EA_SOURCE_001
PRINT_AN
    JSR     PRINT_A
    MOVE.L  #29,D6
    LSL.L   D6,D1
    LSR.L   D6,D1
    MOVE.L  D1,D2
    JSR     OUTPUT_HEXADECIMAL
    MOVEM.L (SP)+,D1-D2/D6
    RTS    
PRINT_EA_SOURCE_01
    BTST    #3,D1
    BNE     PRINT_EA_SOURCE_011
PRINT_EA_SOURCE_010
PRINT_AN_INDIRECT
    JSR     PRINT_OPEN_PAREN
    JSR     PRINT_A
    MOVE.L  #29,D6
    LSL.L   D6,D1
    LSR.L   D6,D1
    MOVE.L  D1,D2
    JSR     OUTPUT_HEXADECIMAL
    JSR     PRINT_CLOSE_PAREN
    MOVEM.L (SP)+,D1-D2/D6
    RTS
PRINT_EA_SOURCE_011
PRINT_AN_PLUS
    JSR     PRINT_OPEN_PAREN
    JSR     PRINT_A
    MOVE.L  #29,D6
    LSL.L   D6,D1
    LSR.L   D6,D1
    MOVE.L  D1,D2
    JSR     OUTPUT_HEXADECIMAL
    JSR     PRINT_CLOSE_PAREN
    JSR     PRINT_PLUS
    MOVEM.L (SP)+,D1-D2/D6
    RTS
PRINT_EA_SOURCE_1
    BTST    #4,D1
    BNE     PRINT_EA_SOURCE_11
PRINT_EA_SOURCE_10
    BTST    #3,D1
    BNE     PRINT_EA_SOURCE_INVALID
PRINT_EA_SOURCE_100
PRINT_MINUS_AN
    JSR     PRINT_MINUS
    JSR     PRINT_OPEN_PAREN
    JSR     PRINT_A
    MOVE.L  #29,D6
    LSL.L   D6,D1
    LSR.L   D6,D1
    MOVE.L  D1,D2
    JSR     OUTPUT_HEXADECIMAL
    JSR     PRINT_CLOSE_PAREN
    MOVEM.L (SP)+,D1-D2/D6
    RTS
PRINT_EA_SOURCE_11
PRINT_EA_SOURCE_111
    BTST    #2,D1
    BNE     PRINT_IMMEDIATE_DATA_WORD
    BTST    #0,D1
    BNE     PRINT_LONG_ADDRESS
PRINT_WORD_ADDRESS
    JSR     PRINT_$
    MOVE.W  (A2)+,D2
    JSR     OUTPUT_HEXADECIMAL
    MOVEM.L (SP)+,D1-D2/D6
    RTS
PRINT_LONG_ADDRESS
    JSR     PRINT_$
    MOVE.L  (A2)+,D2
    JSR     OUTPUT_HEXADECIMAL
    MOVEM.L (SP)+,D1-D2/D6
    RTS
PRINT_IMMEDIATE_DATA_WORD
    JSR     PRINT_POUND
    JSR     PRINT_$
    MOVE.W  (A2)+,D2
    JSR     OUTPUT_HEXADECIMAL
    MOVEM.L (SP)+,D1-D2/D6
    RTS
PRINT_IMMEDIATE_DATA_LONG
    JSR     PRINT_POUND
    JSR     PRINT_$
    MOVE.L  (A2)+,D2
    JSR     OUTPUT_HEXADECIMAL
    MOVEM.L (SP)+,D1-D2/D6
    RTS
PRINT_EA_SOURCE_INVALID
    JSR     PRINT_INVALID_OPCODE
    MOVEM.L (SP)+,D1-D2/D6
    RTS
   
LSL_REG_SECT                    *Output the message 'LSL.'.
    LEA     LSL_MESS,A1
    MOVE.B  #14,D0      
    TRAP    #15
    JSR     LSL_LSR_PRINT
    
*    MOVE.L  D1,D4
*    MOVE.B  #'',D1
*    MOVE.B  #6,D0
*    TRAP    #15
*    MOVE.B  #'',D1                         *Print the number in hexadecimal form, addressing is in base 16
*    MOVE.B  #6,D0
*    TRAP    #15
*    MOVE.L  D4,D1
*    BEQ     VALID_MODE_0_JSR
*    
*    JSR     VALID_MODE_1
    JMP     RELOOP
ASL_REG_SECT                    *Output the message 'ASL.'.
    LEA     ASL_MESS,A1
    MOVE.B  #14,D0      
    TRAP    #15
    JSR     LSL_LSR_PRINT
    JMP     RELOOP
ROL_REG_SECT                    *Output the message 'ROL.'.
    LEA     ROL_MESS,A1
    MOVE.B  #14,D0      
    TRAP    #15
    JSR     LSL_LSR_PRINT
    JMP     RELOOP
LSL_MEM_SECT                    *Output the message 'LSL.'.
    LEA     LSL_MESS,A1
    MOVE.B  #14,D0      
    TRAP    #15
    
    JSR     PRINT_W                  *Prints a W to the output window.
    JSR     PRINT_SPACE         *Prints a space to the output window.
    BTST    #5,D1
    BEQ     VALID_MODE_0_JSR
    
    JSR     VALID_MODE_1
    JMP     RELOOP
ASL_MEM_SECT                    *Output the message 'ASL.'.
    LEA     ASL_MESS,A1
    MOVE.B  #14,D0      
    TRAP    #15
    
    JSR     PRINT_W                  *Prints a W to the output window.
    JSR     PRINT_SPACE         *Prints a space to the output window.
    BTST    #5,D1
    BEQ     VALID_MODE_0_JSR
    
    JSR     VALID_MODE_1
    JMP     RELOOP
ROL_MEM_SECT                    *Output the message 'ROL.'.
    LEA     ROL_MESS,A1
    MOVE.B  #14,D0      
    TRAP    #15
    JSR     PRINT_W                  *Prints a W to the output window.
    JSR     PRINT_SPACE         *Prints a space to the output window.
    BTST    #5,D1
    BEQ     VALID_MODE_0_JSR
    
    JSR     VALID_MODE_1
    JMP     RELOOP
TRAP_SECT
    LEA     TRAP_MESS,A1    *Output the message 'TRAP'.
    MOVE.B  #14,D0
    TRAP    #15
    JSR     PRINT_SPACE
    JSR     PRINT_POUND
    AND.L   #$F,D1
    MOVE.B  #3,D0
    TRAP    #15
    JMP     RELOOP
BTST_STATIC_SECT
    BTST    #8,D1
    BNE     BTST_DYNAMIC_SECT
    MOVE.W  D1,D2                   *Copying OPCode Word for isolation of static bits.
    AND.W   #%1111111111000000,D2   *Isolating bits for detrmining validity of OPCode.
    CMP.W   #%0000100000000000,D2   *Comparing with valid value.
    BNE     PRINT_INVALID_OPCODE    *If it's not the valid value, then print error message.
    MOVE.W  (A2),D2                   *Copying OPCode Word for isolation of static bits.
    AND.W   #%1111111100000000,D2   *Isolating bits for detrmining validity of OPCode.
    CMP.W   #%0000000000000000,D2   *Comparing with valid value.
    BNE     PRINT_INVALID_OPCODE    *If it's not the valid value, then print error message.
    MOVE.B  #%11110101,D7       *Valid modes for this OPCode.
    JSR     SRC_EFF_ADDR_MODE_REG   *Check value in mode for validity.
    BTST    #0,D3                   *Checking result of subroutine's check for valid final 6 bits.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.

    BNE     PRINT_VALID_BTST_STATIC
    JMP     RELOOP              *Reiterate to beginning of disassembler.
BTST_DYNAMIC_SECT
    MOVE.B  #%11111101,D7       *Valid modes for this OPCode.
    JSR     SRC_EFF_ADDR_MODE_REG   *Check value in mode for validity.
    BTST    #0,D3                   *Checking result of subroutine's check for valid final 6 bits.
    BEQ     PRINT_INVALID_OPCODE    *If invalid, then print error message for invalid OPCode.
    MOVE.W  D1,D2                   *Copying OPCode Word for isolation of static bits.
    AND.W   #%1111000111000000,D2   *Isolating bits for detrmining validity of OPCode.
    CMP.W   #%0000000100000000,D2   *Comparing with valid value.
    BNE     PRINT_INVALID_OPCODE    *If it's not the valid value, then print error message.
    BRA     BTST_DYNAMIC_VALID
    
    JMP     RELOOP              *Reiterate to beginning of disassembler.
    
BTST_DYNAMIC_VALID
    LEA     BTST_MESS,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  #20,D2
    MOVE.B  D1,D4
    LSL.L   D2,D1
    MOVE.B  #29,D2
    LSR.L   D2,D1
    MOVE.W  D1,D5
    
    JSR     PRINT_SPACE         *Prints a space to the output window.
    JSR      PRINT_D
    
    MOVE.B   D5,D1
    MOVE.B   #3,D0
    TRAP     #15
    
    JSR     PRINT_COMMA         *Prints a comma to the output window.
    
    CLR.L   D5
    JMP     PRINT_VALID_BTST_DYNAMIC
    JMP     RELOOP

PRINT_OPMODE_ADD_EA_DN
    BTST    #7,D1
    BNE     OPMODE_ADD_EA_DN_TEST_LONG
    BTST    #6,D1
    BNE     OPMODE_ADD_EA_DN_TEST_WORD
    JMP     OPMODE_ADD_EA_DN_TEST_BYTE
    
PRINT_OPMODE_ADD_EA_AN
    BTST    #7,D1
    BNE     OPMODE_ADD_EA_AN_TEST_LONG
    BTST    #6,D1
    BNE     OPMODE_ADD_EA_AN_TEST_WORD
    JMP     OPMODE_ADD_EA_AN_TEST_BYTE

OPMODE_ADD_EA_DN_TEST_WORD
    MOVE.W  D1,D4                               *Copy to D4 because D1 will be manipulated
    JSR     PRINT_W                  *Prints a W to the output window.
    JSR     PRINT_SPACE         *Prints a space to the output window.
    MOVE.W  D4,D1
    BTST    #5,D1
    BRA     VALID_MODE_ADD_EA_DN
*    JSR     VALID_MODE_1
*    JSR     PRINT_COMMA         *Prints a comma to the output window.
*    MOVE.W  D4,D1
*    
*    MOVE.B  #20,D2
*    MOVE.B  D1,D4
*    LSL.L   D2,D1
*    MOVE.B  #29,D2
*    LSR.L   D2,D1
*    MOVE.W  D1,D5
*
*    JSR     PRINT_D
*    
*    MOVE.B   D5,D1
*    MOVE.B   #3,D0
*    TRAP     #15
*    MOVE.W  D4,D1
*    JMP     RELOOP
    
OPMODE_ADD_EA_AN_TEST_WORD
    MOVE.W  D1,D4                               *Copy to D4 because D1 will be manipulated
    JSR     PRINT_W                  *Prints a W to the output window.
    JSR     PRINT_SPACE         *Prints a space to the output window.
    MOVE.W  D4,D1
    BTST    #5,D1
    BRA     VALID_MODE_ADD_EA_DN
*    JSR     VALID_MODE_1
*    JSR     PRINT_COMMA         *Prints a comma to the output window.
*    MOVE.W  D4,D1
*    
*    MOVE.B  #20,D2
*    MOVE.B  D1,D4
*    LSL.L   D2,D1
*    MOVE.B  #29,D2
*    LSR.L   D2,D1
*    MOVE.W  D1,D5
*
*    JSR     PRINT_A
*    
*    MOVE.B   D5,D1
*    MOVE.B   #3,D0
*    TRAP     #15
*    MOVE.W  D4,D1
*    JMP     RELOOP


OPMODE_ADD_EA_DN_TEST_BYTE
    MOVE.W  D1,D4                               *Copy to D4 because D1 will be manipulated
    JSR     PRINT_B                  *Prints a B to the output window.
    
    JSR     PRINT_SPACE         *Prints a space to the output window.

    BTST    #5,D1
    
    BRA     VALID_MODE_ADD_EA_DN
*    JSR     VALID_MODE_1
*    
*    JSR     PRINT_COMMA         *Prints a comma to the output window.
*    MOVE.W  D4,D1
*    
*    MOVE.B  #20,D2
*    MOVE.B  D1,D4
*    LSL.L   D2,D1
*    MOVE.B  #29,D2
*    LSR.L   D2,D1
*    MOVE.W  D1,D5
*
*    JSR     PRINT_D
*    
*    MOVE.B   D5,D1
*    MOVE.B   #3,D0
*    TRAP     #15
*    MOVE.W  D4,D1
*    JMP     RELOOP
    
OPMODE_ADD_EA_AN_TEST_BYTE
    MOVE.W  D1,D4                               *Copy to D4 because D1 will be manipulated
    JSR     PRINT_B                  *Prints a B to the output window.
    
    JSR     PRINT_SPACE         *Prints a space to the output window.

    BTST    #5,D1
    
    BRA     VALID_MODE_ADD_EA_DN
*    JSR     VALID_MODE_1
*    
*    JSR     PRINT_COMMA         *Prints a comma to the output window.
*    MOVE.W  D4,D1
*    
*    MOVE.B  #20,D2
*    MOVE.B  D1,D4
*    LSL.L   D2,D1
*    MOVE.B  #29,D2
*    LSR.L   D2,D1
*    MOVE.W  D1,D5
*
*    JSR     PRINT_A
*    
*    MOVE.B   D5,D1
*    MOVE.B   #3,D0
*    TRAP     #15
*    MOVE.W  D4,D1
*    JMP     RELOOP
    
OPMODE_ADD_EA_DN_TEST_LONG
    MOVE.W  D1,D4                               *Copy to D4 because D1 will be manipulated
    JSR     PRINT_L                  *Prints a L to the output window.
    
    JSR     PRINT_SPACE         *Prints a space to the output window.
    MOVE.W  D4,D1

    BTST    #5,D1
    
    BRA     VALID_MODE_ADD_EA_DN
*    JSR     VALID_MODE_1
*    
*    JSR     PRINT_COMMA         *Prints a comma to the output window.
*    MOVE.W  D4,D1
*    
*    MOVE.B  #20,D2
*    MOVE.B  D1,D4
*    LSL.L   D2,D1
*    MOVE.B  #29,D2
*    LSR.L   D2,D1
*    MOVE.W  D1,D5
*    
*    JSR     PRINT_D
*    
*    MOVE.B   D5,D1
*    MOVE.B   #3,D0
*    TRAP     #15
*    MOVE.W  D4,D1
*    JMP     RELOOP
    
OPMODE_ADD_EA_AN_TEST_LONG
    MOVE.W  D1,D4                               *Copy to D4 because D1 will be manipulated
    JSR     PRINT_L                  *Prints a L to the output window.
    
    JSR     PRINT_SPACE         *Prints a space to the output window.
    MOVE.W  D4,D1

    BTST    #5,D1
    
    BRA     VALID_MODE_ADD_EA_DN
*    JSR     VALID_MODE_1
*    
*    JSR     PRINT_COMMA         *Prints a comma to the output window.
*    MOVE.W  D4,D1
*    
*    MOVE.B  #20,D2
*    MOVE.B  D1,D4
*    LSL.L   D2,D1
*    MOVE.B  #29,D2
*    LSR.L   D2,D1
*    MOVE.W  D1,D5
*    
*    JSR     PRINT_A
*    
*    MOVE.B   D5,D1
*    MOVE.B   #3,D0
*    TRAP     #15
*    MOVE.W  D4,D1
*    JMP     RELOOP

VALID_MODE_ADD_EA_DN
    CLR.L   D2
    MOVE.W  D1,D2
    AND.W   #%111000000,D2
    LSR.W   #6,D2
    CMP.B   #1,D2
    JSR     PRINT_EA_SOURCE_OPMODE
    JSR     PRINT_COMMA         *Prints a comma to the output window.
    JSR     PRINT_D
    MOVE.W  D4,D1
    JSR     DN_REGISTER
    JMP     RELOOP

PRINT_OPMODE_ADD_DN_EA
    BTST    #7,D1
    BNE     OPMODE_ADD_DN_EA_TEST_LONG
    BTST    #6,D1
    BNE     OPMODE_ADD_DN_EA_TEST_WORD
    JMP     OPMODE_ADD_DN_EA_TEST_BYTE
OPMODE_ADD_DN_EA_TEST_WORD
    JSR     PRINT_W                  *Prints a W to the output window.
    JSR     PRINT_SPACE         *Prints a space to the output window.
    
    MOVE.B  #20,D2
    MOVE.W  D1,D4
    LSL.L   D2,D1
    MOVE.B  #29,D2
    LSR.L   D2,D1
    MOVE.W  D1,D5

    JSR     PRINT_D
    
    MOVE.B   D5,D1
    MOVE.B   #3,D0
    TRAP     #15

    JSR     PRINT_COMMA         *Prints a comma to the output window.
    MOVE.W  D4,D1

    BTST    #5,D1
    
    BEQ     VALID_MODE_0_ADD_DN_EA
    JSR     VALID_MODE_1
    
    MOVE.W  D4,D1
    JMP     RELOOP

OPMODE_ADD_DN_EA_TEST_BYTE
    JSR     PRINT_B                  *Prints a B to the output window.
    JSR     PRINT_SPACE         *Prints a space to the output window.

    MOVE.B  #20,D2
    MOVE.W  D1,D4
    LSL.L   D2,D1
    MOVE.B  #29,D2
    LSR.L   D2,D1
    MOVE.W  D1,D5

    JSR     PRINT_D
    
    MOVE.B   D5,D1
    MOVE.B   #3,D0
    TRAP     #15

    JSR     PRINT_COMMA         *Prints a comma to the output window.
    MOVE.W  D4,D1

    BTST    #5,D1
    
    BEQ     VALID_MODE_0_ADD_DN_EA
    JSR     VALID_MODE_1
    JMP     RELOOP


    
OPMODE_ADD_DN_EA_TEST_LONG
    JSR     PRINT_L                  *Prints a L to the output window.
    JSR     PRINT_SPACE         *Prints a space to the output window.

    MOVE.B  #20,D2
    MOVE.W  D1,D4
    LSL.L   D2,D1
    MOVE.B  #29,D2
    LSR.L   D2,D1
    MOVE.W  D1,D5
    
    JSR     PRINT_D
    
    MOVE.B   D5,D1
    MOVE.B   #3,D0
    TRAP     #15

    JSR     PRINT_COMMA         *Prints a comma to the output window.
    MOVE.W  D4,D1

    BTST    #5,D1
    
    BEQ     VALID_MODE_0_ADD_DN_EA
    JSR     VALID_MODE_1
    
    MOVE.W  D4,D1
    JMP     RELOOP

VALID_MODE_0_ADD_DN_EA
    JSR     VALID_MODE_0
    JMP     RELOOP
 
DN_REGISTER
    BTST    #11,D1
    BNE     DN_REGISTER_1
    BTST    #10,D1
    BNE     DN_REGISTER_01
    BTST    #9,D1
    BNE     DN_REGISTER_001
       
    *If it passes all tests, it is D0
    MOVE.B  #'0',D1
    MOVE.B  #6,D0
    TRAP    #15

    MOVE.W  D4,D1
    RTS


DN_REGISTER_1
    BTST    #10,D1
    BEQ     DN_REGISTER_10
    BTST    #9,D1
    BEQ     DN_REGISTER_110
       
    *If it passes all tests, it is D7
    MOVE.B  #'7',D1
    MOVE.B  #6,D0
    TRAP    #15

    MOVE.W  D4,D1
    RTS
DN_REGISTER_10
       
       
    BTST   #9,D1
    BNE    DN_REGISTER_101
    
    *Register is D4
    MOVE.B  #'4',D1
    MOVE.B  #6,D0
    TRAP    #15

    MOVE.W  D4,D1
    RTS
    
DN_REGISTER_110
    *Register is D6

    MOVE.B  #'6',D1
    MOVE.B  #6,D0
    TRAP    #15

    MOVE.W  D4,D1
    RTS


 
DN_REGISTER_101
    *Register is D5
    MOVE.B  #'5',D1
    MOVE.B  #6,D0
    TRAP    #15

    MOVE.W  D4,D1
    RTS
   
DN_REGISTER_01 
    BTST   #9,D1
    BNE    DN_REGISTER_011
    
    *Register is D2
    MOVE.B  #'2',D1
    MOVE.B  #6,D0
    TRAP    #15

    MOVE.W  D4,D1
    RTS
    
DN_REGISTER_011                                  *Data register is D3      
    MOVE.B  #'3',D1
    MOVE.B  #6,D0
    TRAP    #15

    MOVE.W  D4,D1
    RTS
    
    
    
DN_REGISTER_001
    *If it passes all tests, it is D1
    MOVE.B  #'1',D1
    MOVE.B  #6,D0
    TRAP    #15

    MOVE.W  D4,D1
    RTS

VALIDATE_OPMODE_FIELD
    MOVE.W  D1,D2
    AND.W   #%0000000111000000,D2
    CMP.W   #%0000000010000000,D2
    BLE     VALID_MODE
    CMP.W   #%0000000100000000,D2
    BLT     INVALID_MODE
    CMP.W   #%0000000111000000,D2
    BEQ     INVALID_MODE
    BRA     VALID_MODE
*Bits stored in D7 represent the valid modes in the current opcode being disassembled.
                                                    *Bit set means valid for that mode.
                                                    
*Data Register Direct                               %00000001
*Address Register Direct                            %00000010
*Address Register Indirect                          %00000100
*Immediate Data                                     %00001000
*Address Register Indirect with Post incrementing   %00010000
*Address Register Indirect with Pre decrementing    %00100000
*Absolute Long Address                              %01000000
*Absolute Word Address                              %10000000
DEST_EFF_ADDR_MODE_REG      *Modifies D2 and D3. 
    BTST    #8,D1
    BNE     DEST_MODE_1
DEST_MODE_0  *Possibilities are Dn, An, (An), (AN)+
    BTST    #7,D1
    BNE     DEST_MODE_01
DEST_MODE_00     *Possibilities are Dn, An
    BTST    #6,D1
    BNE     MODE_ADDR_DIRECT
    BRA     MODE_DAT_DIRECT
DEST_MODE_01     *Possibilities are (An), (An)+
    BTST    #6,D1
    BNE     MODE_ADDR_INDIR_INCR
    BRA     MODE_ADDR_INDIR
DEST_MODE_1
    BTST    #7,D1
    BNE     DEST_MODE_11
DEST_MODE_10
    BTST    #6,D1
    BNE     INVALID_MODE
    BRA     MODE_ADDR_INDIR_DECR
DEST_MODE_11     *Possibilities are (xxx).W, (xxx).L, and #<data>
    BTST    #6,D1
    BEQ     INVALID_MODE  
DEST_MODE_111    *Possibilities are (xxx).W, (xxx).L, and #<data>
    MOVE.W  D1,D2                   *Creating a copy of D1 in order to isolate bits for mode differentiation.
    AND.W   #%0000111000000000,D2   *Relevant bits for diferrentiating the current possible modes.
    CMP.W   #%0000000000000000,D2   *If this comparison is true, then the mode is a word address.
    BEQ     MODE_WORD_ADDRESS       *Go to case for Word Address.
    CMP.W   #%0000001000000000,D2   *If this comparison is true, then the mode is a Long address.
    BEQ     MODE_LONG_ADDRESS       *Go to case for Long Address.
    CMP.W   #%0000100000000000,D2   *If this comparison is true, then the mode is immediate data.
    BEQ     MODE_IMMEDIATE_DATA     *Go to case for immediate data.
    BRA     INVALID_MODE            *Else, code must be invalid.    
    
SRC_EFF_ADDR_MODE_REG       *Modifies D2 and D3.   
    BTST    #5,D1
    BNE     SRC_MODE_1
SRC_MODE_0  *Possibilities are Dn, An, (An), (AN)+
    BTST    #4,D1
    BNE     SRC_MODE_01
SRC_MODE_00     *Possibilities are Dn, An
    BTST    #3,D1
    BNE     MODE_ADDR_DIRECT
MODE_DAT_DIRECT
    BTST    #0,D7                   *Test if this mode is valid for the current OPCode.
    BNE     VALID_MODE              *If bit was set, goto case for valid mode.
    BRA     INVALID_MODE            *Else, goto case for invalid mode.
SRC_MODE_01     *Possibilities are (An), (An)+
    BTST    #3,D1
    BNE     MODE_ADDR_INDIR_INCR
MODE_ADDR_INDIR
    BTST    #2,D7                   *Test if this mode is valid for the current OPCode.
    BNE     VALID_MODE              *If bit was set, goto case for valid mode.
    BRA     INVALID_MODE            *Else, goto case for invalid mode.
SRC_MODE_1
    BTST    #4,D1
    BNE     SRC_MODE_11
SRC_MODE_10
    BTST    #3,D1
    BNE     INVALID_MODE
MODE_ADDR_INDIR_DECR
    BTST    #5,D7                   *Test if this mode is valid for the current OPCode.
    BNE     VALID_MODE              *If bit was set, goto case for valid mode.
    BRA     INVALID_MODE            *Else, goto case for invalid mode.     
SRC_MODE_11     *Possibilities are (xxx).W, (xxx).L, and #<data>
    BTST    #3,D1
    BEQ     INVALID_MODE
SRC_MODE_111    *Possibilities are (xxx).W, (xxx).L, and #<data>
    MOVE.B  D1,D2                   *Creating a copy of D1 in order to isolate bits for mode differentiation.
    AND.B   #%00000111,D2           *Relevant bits for diferrentiating the current possible modes.
    CMP.B   #%00000000,D2           *If this comparison is true, then the mode is a word address.
    BEQ     MODE_WORD_ADDRESS       *Go to case for Word Address.
    CMP.B   #%00000001,D2           *If this comparison is true, then the mode is a Long address.
    BEQ     MODE_LONG_ADDRESS       *Go to case for Long Address.
    CMP.B   #%00000100,D2           *If this comparison is true, then the mode is immediate data.
    BEQ     MODE_IMMEDIATE_DATA     *Go to case for immediate data.
    BRA     INVALID_MODE            *Else, code must be invalid.
MODE_ADDR_DIRECT        
    BTST    #1,D7                   *Test if this mode is valid for the current OPCode.
    BNE     VALID_MODE              *If bit was set, goto case for valid mode.
    BRA     INVALID_MODE            *Else, goto case for invalid mode.          
MODE_IMMEDIATE_DATA     
    BTST    #3,D7                   *Test if this mode is valid for the current OPCode.
    BNE     VALID_MODE              *If bit was set, goto case for valid mode.
    BRA     INVALID_MODE            *Else, goto case for invalid mode.           
MODE_ADDR_INDIR_INCR
    BTST    #4,D7                   *Test if this mode is valid for the current OPCode.
    BNE     VALID_MODE              *If bit was set, goto case for valid mode.
    BRA     INVALID_MODE            *Else, goto case for invalid mode.           
MODE_LONG_ADDRESS
    BTST    #6,D7                   *Test if this mode is valid for the current OPCode.
    BNE     VALID_MODE              *If bit was set, goto case for valid mode.
    BRA     INVALID_MODE            *Else, goto case for invalid mode.            
MODE_WORD_ADDRESS
    BTST    #7,D7                   *Test if this mode is valid for the current OPCode.
    BNE     VALID_MODE              *If bit was set, goto case for valid mode.
    BRA     INVALID_MODE            *Else, goto case for invalid mode.            
INVALID_MODE
    MOVE.B  #0,D3
    RTS
VALID_MODE
    MOVE.B  #1,D3
    RTS
    
*D3 needs to contain the shift over that has to be done in order to get to size.
*D3.B should contain %***(5-bit  shift count). The first three bits determine which 
*sizes are valid. The 5-bit shift count should always be more than 0.
*Result will be stored in D3.B as #1 for valid size and #0 for invalid.
*%100***** is LONG
*%010***** is WORD
*%001***** is BYTE
VALIDATE_SIZE_MOVELIKE
    MOVE.L  D4,-(SP)                *Save current value of D4 into the stack.
    CLR.L   D4
    MOVE.B  D3,D4                   *Copy D3 into D4 in order to isolate shift count.
    AND.B   #%00011111,D4           *Isolate shift count in D4.         
    BTST    D4,D1                   *Test the left bit of size to determine size.
    BNE     MOVE_SIZE_1                  *Branch to case for if the bit was a 1.
MOVE_SIZE_0
    SUB     #1,D4                   *Adjust shift count to be the bit to the right of the previously tested bit.
    BTST    D4,D1                   *Test the second bit for the size.
    BNE     SIZE_BYTE_OPERATION     *If it's a 1, then it is a BYTE operation.
INVALID_SIZE
    MOVE.B  #0,D3                   *Sets the value in D3 to zero before returning.
    MOVE.L  (SP)+,D4                *Restore original value of D4.
    RTS                             
SIZE_BYTE_OPERATION *(01)
    BTST    #5,D3                   *If this bit is one, then a BYTE operation is defined for this OPCODE.
    BNE     VALID_SIZE              *Branch to valid case if it was a 1.
    BRA     INVALID_SIZE            *Else, branch to invalid case.
MOVE_SIZE_1
    SUB     #1,D4                   *Adjust shift count to be the bit to the right of the previously tested bit.
    BTST    D4,D1                   *Test the second bit for the size.
    BNE     SIZE_WORD_OPERATION     *If it's a 1, then it is a WORD operation.
SIZE_LONG_OPERATION *(10)
    BTST    #7,D3                   *If this bit is one, then a LONG operation is defined for this OPCODE.
    BNE     VALID_SIZE              *Branch to valid case if it was a 1.
    BRA     INVALID_SIZE            *Else, branch to invalid case.
SIZE_WORD_OPERATION *(11) 
    BTST    #6,D3                   *If this bit is one, then a WORD operation is defined for this OPCODE.
    BNE     VALID_SIZE              *Branch to valid case if it was a 1.
    BRA     INVALID_SIZE            *Else, branch to invalid case.
VALID_SIZE
    MOVE.B  #1,D3                   *A 1 in D3 signifies a valid SIZE was found for this OPCode.
    MOVE.L  (SP)+,D4                *Restore original value of D4.
    RTS  

*D3 needs to contain the shift over that has to be done in order to get to size.
*D3.B should contain %***(5-bit  shift count). The first three bits determine which 
*sizes are valid. The 5-bit shift count should always be more than 0.
*Result will be stored in D3.B as #1 for valid size and #0 for invalid.
*%100***** is LONG
*%010***** is WORD
*%001***** is BYTE
VALIDATE_SIZE_CLRLIKE
    MOVE.L  D4,-(SP)                *Save current value of D4 into the stack.
    CLR.L   D4
    MOVE.B  D3,D4                   *Copy D3 into D4 in order to isolate shift count.
    AND.B   #%00011111,D4           *Isolate shift count in D4.         
    BTST    D4,D1                   *Test the left bit of size to determine size.
    BNE     CLR_SIZE_1                  *Branch to case for if the bit was a 1.
CLR_SIZE_0
    SUB     #1,D4                   *Adjust shift count to be the bit to the right of the previously tested bit.
    BTST    D4,D1                   *Test the second bit for the size.
    BNE     SIZE_WORD_OPERATION     *If it's a 1, then it is a BYTE operation.
    BRA     SIZE_BYTE_OPERATION                    
CLR_SIZE_1
    SUB     #1,D4                   *Adjust shift count to be the bit to the right of the previously tested bit.
    BTST    D4,D1                   *Test the second bit for the size.
    BNE     INVALID_SIZE            *If it's a 1, then it is an invalid operation.
    BRA     SIZE_LONG_OPERATION

PRINT_VALID_BTST_DYNAMIC
    MOVE.W  D4,D1
    BTST    #5,D1
    BEQ     VALID_MODE_0_JSR
    
    JSR     VALID_MODE_1 
    JMP     RELOOP


*This label needs to be reavaluated, we want to be able to jump back to where we were previously
VALID_MODE_0_JSR
    JSR     VALID_MODE_0
    JMP     RELOOP
PRINT_VALID_BTST_STATIC
    LEA     BTST_MESS,A1
    MOVE.B  #14,D0
    TRAP    #15
    JSR     PRINT_SPACE
    JSR     PRINT_POUND
    
    MOVE.W  (A2)+,D6               *This gets the remaining word from the function
    
    
    MOVE.W  D1,D4                  *Copy the bits to D4, because we are going to print and need to use D1
    MOVE.W  D6,D1
    MOVE.B  #3,D0
    TRAP    #15
    MOVE.W  D4,D1
    
    JSR     PRINT_COMMA
    BTST    #5,D1
    BEQ     VALID_MODE_0_JSR
    
    JSR     VALID_MODE_1 
    JMP     RELOOP

VALID_MODE_1     *Options here are  
    MOVEM.L D0-D7,-(SP)  
    MOVE.W  D1,D4             
    BTST    #4,D1
    BNE     VALID_MODE_11
    
    *Bit mode here is 10, which means the full code is 100 or -(An)
    JSR     PRINT_MINUS         *Prints a - to the output window.
   
    JSR     PRINT_OPEN_PAREN             *Prints a ( to the output window.
    JSR     PRINT_A                         *Prints an A to the output window.
    
    MOVE.W  D4,D1                    *Copy original values back into D1
              
    MOVE.B  #29,D6                   *Set the bit shift to 29 so we can isolate the register number 
    LSL.L   D6,D1                    
    LSR.L   D6,D1
    MOVE.B  #3,D0                   *Move trap task  #15 to convert to decimal and print  
    TRAP    #15
    JSR     PRINT_CLOSE_PAREN             *Prints a ) to the output window.
    
    MOVEM.L (SP)+,D0-D7
    RTS
VALID_MODE_11    
    BTST    #2,D1
    BNE     VALID_MODE_111_POUND
    JSR     PRINT_$                 *Prints a $ to the output window.
    
    MOVE.W  D4,D1
    BTST    #0,D1
    BNE     VALID_MODE_111_LONG
    MOVE.W  (A2)+,D6               *This gets the remaining word from the function

    MOVE.W  D6,D1
    MOVE.L  D1,D2                    
    JSR     OUTPUT_HEXADECIMAL
    
    MOVE.W  D4,D1                    *Copy original values back into D1
    MOVEM.L (SP)+,D0-D7
    RTS
VALID_MODE_111_POUND
    JSR     PRINT_POUND         *Prints a # to the output window.
    JSR     PRINT_$             *Prints a $ to the output window.
    MOVE.W  D4,D1
    BTST    #12,D1
    BEQ     VALID_MODE_111_LONG
    MOVE.W  (A2)+,D6               *This gets the remaining word from the function
    
    CMP.W   #0,D6
    BEQ     RTS
    
    MOVE.L  D6,D1
    
    MOVE.L  D1,D2                    
    JSR     OUTPUT_HEXADECIMAL
    
    MOVE.W  D4,D1                    *Copy original values back into D1
    MOVEM.L (SP)+,D0-D7
    RTS
RTS
    MOVE.L  D6,D2
    JSR     OUTPUT_HEXADECIMAL
    MOVEM.L (SP)+,D0-D7
    RTS
VALID_MODE_111_LONG
    MOVE.L  (A2)+,D6
    
    MOVE.L  D6,D1
    MOVE.L  D1,D2                    
    JSR     OUTPUT_HEXADECIMAL
    CLR.L   D1
    MOVEM.L (SP)+,D0-D7
    RTS
    
VALID_MODE_0                         *Options are Dn, (An), or (An)+
    MOVEM.L D0-D7,-(SP)
    MOVE.W  D1,D4
    BTST    #4,D1
    BNE     VALID_MODE_01  
    JMP     VALID_MODE_00

VALID_MODE_00
    BTST    #3,D1
    BNE     VALID_MODE_001
    JSR     PRINT_D                
    
    MOVE.W  D4,D1  
    MOVE.B  #29,D6                   *Set the bit shift to 29 so we can isolate the register number 
    LSL.L   D6,D1                    
    LSR.L   D6,D1
    MOVE.B  #3,D0                   *Move trap task  #15 to convert to decimal and print  
    TRAP    #15
    MOVE.W  D4,D1                    *Move original unaltered bits back to D1
    MOVEM.L (SP)+,D0-D7
    RTS
VALID_MODE_01    
    JSR     PRINT_OPEN_PAREN        *Prints a ( to the output window.
    JSR     PRINT_A                 *Prints an A to the output window.
    
    MOVE.B  #29,D6                   *Set the bit shift to 29 so we can isolate the register number 
    LSL.L   D6,D1                    *Shift bits to isolate register number
    LSR.L   D6,D1                    *Shift bits back to position so we can get the number
    MOVE.B  #3,D0                   *Move trap task  #15 to convert to decimal and print  
    TRAP    #15
    
    JSR     PRINT_CLOSE_PAREN             *Prints a ) to the output window.
    MOVE.W  D4,D1                    *Copy original values back into D1
    BTST    #3,D1
    BNE     VALID_MODE_011 
    MOVEM.L (SP)+,D0-D7
    RTS

VALID_MODE_001
    JSR     PRINT_A                         *Prints an A to the output window.                   
    
    MOVE.W  D4,D1  
    MOVE.B  #29,D6                   *Set the bit shift to 29 so we can isolate the register number 
    LSL.L   D6,D1                    
    LSR.L   D6,D1
    MOVE.B  #3,D0                   *Move trap task  #15 to convert to decimal and print  
    TRAP    #15
    MOVE.W  D4,D1                    *Move original unaltered bits back to D1
    MOVEM.L (SP)+,D0-D7
    RTS

VALID_MODE_011
    JSR     PRINT_PLUS
    MOVEM.L (SP)+,D0-D7
    RTS

VALID_MODE_SOURCE_DEST_1     *Options here are                 
    BTST    #7,D1
    BNE     VALID_MODE_SOURCE_DEST_11
    
    *Bit mode here is 10, which means the full code is 100 or -(An)
    JSR     PRINT_MINUS         *Prints a - to the output window.
   
    JSR     PRINT_OPEN_PAREN             *Prints a ( to the output window.
    JSR     PRINT_A                         *Prints an A to the output window.
    
    MOVE.W  D4,D1                    *Copy original values back into D1
              
    MOVE.B  #20,D6                   *Set the bit shift to 29 so we can isolate the register number 
    LSL.L   D6,D1 
    MOVE.B  #29,D6                   
    LSR.L   D6,D1
    MOVE.B  #3,D0                   *Move trap task  #15 to convert to decimal and print  
    TRAP    #15
    
    JSR     PRINT_CLOSE_PAREN             *Prints a ) to the output window.
    MOVE.W  D4,D1                    *Move original unaltered bits back to D1
    
    RTS
VALID_MODE_SOURCE_DEST_11    
    BTST    #11,D1
    BNE     VALID_MODE_SOURCE_DEST_111_POUND
    JSR     PRINT_$                             *Prints a $ to the output window.
    
    MOVE.W  D4,D1
    BTST    #9,D1
    BNE     VALID_MODE_SOURCE_DEST_111_LONG
    MOVE.W  (A2)+,D6                            *This gets the remaining word from the function

    MOVE.W  D6,D1
    MOVE.L  D1,D2                    
    JSR     OUTPUT_HEXADECIMAL
    
    MOVE.W  D4,D1                    *Copy original values back into D1
    RTS
    
VALID_MODE_SOURCE_DEST_111_POUND
    JSR     PRINT_POUND         *Prints a # to the output window.
    
    MOVE.W  D4,D1
    MOVE.W  (A2)+,D6               *This gets the remaining word from the function

    MOVE.W  D6,D1
    MOVE.L  D1,D2                    
    JSR     OUTPUT_HEXADECIMAL
    
    MOVE.W  D4,D1                    *Copy original values back into D1
    RTS
VALID_MODE_SOURCE_DEST_111_LONG
    MOVE.L  (A2)+,D6
    MOVE.L  D6,D1
    MOVE.L  D1,D2                    
    JSR     OUTPUT_HEXADECIMAL
    CLR.L   D1
    
    RTS
VALID_MODE_SOURCE_DEST_0                         *Options are Dn, (An), or (An)+
    BTST    #7,D1
    BNE     VALID_MODE_SOURCE_DEST_01  
    JMP     VALID_MODE_SOURCE_DEST_00

VALID_MODE_SOURCE_DEST_00
    BTST    #6,D1
    BNE     VALID_MODE_SOURCE_DEST_001
    JSR     PRINT_D                   
    
    MOVE.W  D4,D1  
    MOVE.B  #20,D6                   *Set the bit shift to 20 so we can isolate the register number 
    LSL.L   D6,D1                    
    
    MOVE.B  #29,D6                   *Set the bit shift to 25 now to shift register number all the way to the right
    LSR.L   D6,D1
    MOVE.B  #3,D0                   *Move trap task  #15 to convert to decimal and print  
    TRAP    #15
    MOVE.W  D4,D1                    *Move original unaltered bits back to D1
    
    RTS
VALID_MODE_SOURCE_DEST_01    
    JSR     PRINT_OPEN_PAREN        *Prints a ( to the output window.
    JSR     PRINT_A                 *Prints an A to the output window. 
    
    MOVE.W  D4,D1  
    MOVE.B  #20,D6                   *Set the bit shift to 20 so we can isolate the register number 
    LSL.L   D6,D1                    
    
    MOVE.B  #29,D6                   *Set the bit shift to 25 now to shift register number all the way to the right
    LSR.L   D6,D1
    MOVE.B  #3,D0                   *Move trap task  #15 to convert to decimal and print  
    TRAP    #15
    
    JSR     PRINT_CLOSE_PAREN             *Prints a ) to the output window.
    MOVE.W  D4,D1                    *Copy original values back into D1
    BTST    #6,D1
    BNE     VALID_MODE_SOURCE_DEST_011 
    RTS

VALID_MODE_SOURCE_DEST_001
    JSR     PRINT_A                         *Prints an A to the output window.                   
    
    MOVE.W  D4,D1  
    MOVE.B  #29,D6                   *Set the bit shift to 29 so we can isolate the register number 
    LSL.L   D6,D1                    
    LSR.L   D6,D1
    MOVE.B  #3,D0                   *Move trap task  #15 to convert to decimal and print  
    TRAP    #15
    MOVE.W  D4,D1                    *Move original unaltered bits back to D1
    
    RTS

VALID_MODE_SOURCE_DEST_011
    JSR     PRINT_PLUS
    RTS

PRINT_INVALID_OPCODE
    MOVE.L  A0,D3
    MOVE.L  D3,D6
    MOVE.L  D1,D2
    LEA     INVALID_MESS,A1
    MOVE.B  #14,D0
    TRAP    #15
    JSR     PRINT_SPACE
    JSR     PRINT_$
    JSR     OUTPUT_HEXADECIMAL
    JSR     PRINT_SPACE
    JMP     RELOOP
    
HEXINPUT             
             MOVE.L  #28,D2           ;This is the number of bits that the first number needs to be shifted.                       

CONVERTSTRING MOVE.B    (A1)+,D0
              CMP.B     #$00,D0       ;This is making sure that we have reached the end of the string
              BEQ       STRINGEND
              CMP.B     #0,D2         ;This compare checks if the number of bits we are shifting is less than 0. 
              BLT       STRINGEND     ;if so then we have 8 valid characters
              CMP.W     #$0061,D0     ;This checks if its greater than 61 it is a lower case character or an invalid character
              BGE       LOWERCASE     ;Go to the LOWERCASE
              CMP.W     #$0041,D0     ;This checks if its greater than 41, it is an upper case or an invalid character
              BGE       UPPERCASE     ;Go to the UPPERCASE
              CMP.W     #$0030,D0     ;If D0 is greater than 30 then character is either invalid or a number
              BGE       NUMBER        ;Go to number
              BRA       CONVERTSTRING ;Go to the beginning of the loop
              
LOWERCASE     CMP.W     #$0066,D0     ;If the value is greater than $66, the character is invalid
              BGT       CONVERTSTRING ;Go to the CONVERTSTRING
              SUB       #87,D0        ;Converting from an ASCII value to its hex value
              LSL.L     D2,D0         ;Shifts the value in D0 to the right index
              ADD.L     D0,D3         ;Add D0 to the resulting hex value
              CLR.L     D0            ;Clear D0
              SUB.B     #4,D2         ;Subtract 4 from D2 to adjust number of bits to be shifted. 
              BRA       CONVERTSTRING ;Go back to the beginning of loop. 
              
UPPERCASE     CMP.B     #$0046,D0     ;If the value is greater than $46, the character is invalid. 
              BGT       CONVERTSTRING ;Go to the CONVERTSTRING
              SUB.B     #55,D0        ;Convert D0 from its ASCII to its hex value
              LSL.L     D2,D0
              ADD.L     D0,D3
              CLR.L     D0
              SUB.B     #4,D2
              BRA       CONVERTSTRING
             
NUMBER        CMP.B     #$0039,D0
              BGT       CONVERTSTRING
              SUB.B     #48,D0
              LSL.L     D2,D0
              ADD.L     D0,D3
              CLR.L     D0
              SUB.B     #4,D2
              BRA       CONVERTSTRING
              
STRINGEND     
            ADD.B       #4,D2
            LSR.L       D2,D3
            RTS 

REMOVE_ZEROS_START                      ;Used by Output Hexadecimal. Assumes value isn't zero, because that subroutine checks if it is.
             MOVE.L     D5,-(SP)        ;Restoring the values stored in the Stack
REMOVE_ZEROS                            ;Removing the leading zeros
             MOVE.L     D3,D5
             LSR.L      D4,D5
             AND.B      #$0F,D5
             CMP.B      #0,D5
             BEQ        REMOVE_ZERO
             MOVE.L     (SP)+,D5
             RTS
             
REMOVE_ZERO
             SUB.B      #4,D4          
             BRA        REMOVE_ZEROS    
OUTPUT_HEXADECIMAL  *Subroutine for outputting a hexadecimal number.
            MOVEM.L D3-D4,-(SP)
            CMP.L   #0,D2
            BEQ     VALUE_ZERO
            MOVE.L  D2,D3
            MOVE.L  #28,D4
            JSR     REMOVE_ZEROS_START
            LSR.L   D4,D3
            MULU    #6,D3
            LEA     OUTPUT_CHAR,A0
            JSR     0(A0,D3)

OUTPUT_LOOP  
            SUB.B   #4,D4   ;Changes the amount we are shifting by, in this case by 4
            CMP.B   #0,D4
            BLT     RETURN_CASE
            MOVE.L  D2,D3
            LSR.L   D4,D3
            AND.L   #$0F,D3 ;We are getting rid of everything that isn't the last 4 bits.
            MULU    #6,D3
            JSR     0(A0,D3)
            BRA     OUTPUT_LOOP
VALUE_ZERO
            JSR     OUTPUT0
RETURN_CASE 
            MOVEM.L (SP)+,D3-D4
            RTS            
            
OUTPUT_CHAR JMP     OUTPUT0
            JMP     OUTPUT1
            JMP     OUTPUT2
            JMP     OUTPUT3
            JMP     OUTPUT4
            JMP     OUTPUT5
            JMP     OUTPUT6
            JMP     OUTPUT7
            JMP     OUTPUT8
            JMP     OUTPUT9
            JMP     OUTPUTA
            JMP     OUTPUTB
            JMP     OUTPUTC
            JMP     OUTPUTD
            JMP     OUTPUTE
            JMP     OUTPUTF
                     
            
OUTPUT0     
            MOVE.B  #'0',D1    ;Moves the character into D1
            MOVE.B  #6,  D0    ;This trap task prints out character in D1
            TRAP    #15        ;This outputs to the output window
            RTS
            
OUTPUT1    
            MOVE.B  #'1',D1    ;Moves the character into D1   
            MOVE.B  #6,  D0    ;This trap task prints out character in D1
            TRAP    #15        ;This outputs to the output window
            RTS

OUTPUT2
            MOVE.B  #'2',D1    ;Moves the character into D1
            MOVE.B  #6,  D0    ;This trap task prints out character in D1
            TRAP    #15        ;This outputs to the output window
            RTS

OUTPUT3
            MOVE.B  #'3',D1    ;Moves the character into D1
            MOVE.B  #6,  D0    ;This trap task prints out character in D1
            TRAP    #15        ;This outputs to the output window
            RTS          

OUTPUT4
            MOVE.B  #'4',D1    ;Moves the character into D1
            MOVE.B  #6,  D0    ;This trap task prints out character in D1
            TRAP    #15        ;This outputs to the output window
            RTS

OUTPUT5
            MOVE.B  #'5',D1    ;Moves the character into D1
            MOVE.B  #6,  D0    ;This trap task prints out character in D1
            TRAP    #15        ;This outputs to the output window
            RTS

OUTPUT6
            MOVE.B  #'6',D1    ;Moves the character into D1
            MOVE.B  #6,  D0    ;This trap task prints out character in D1
            TRAP    #15        ;This outputs to the output window
            RTS

OUTPUT7
            MOVE.B  #'7',D1    ;Moves the character into D1
            MOVE.B  #6,  D0    ;This trap task prints out character in D1
            TRAP    #15        ;This outputs to the output window
            RTS

OUTPUT8
            MOVE.B  #'8',D1    ;Moves the character into D1
            MOVE.B  #6,  D0    ;This trap task prints out character in D1
            TRAP    #15        ;This outputs to the output window
            RTS

OUTPUT9 
           MOVE.B  #'9',D1    ;Moves the character into D1
           MOVE.B  #6,  D0    ;This trap task prints out character in D1
           TRAP    #15        ;This outputs to the output window
           RTS

OUTPUTA
           MOVE.B  #'A',D1    ;Moves the character into D1
           MOVE.B  #6,  D0    ;This trap task prints out character in D1
           TRAP    #15        ;This outputs to the output window
           RTS

OUTPUTB
           MOVE.B  #'B',D1    ;Moves the character into D1
           MOVE.B  #6,  D0    ;This trap task prints out character in D1
           TRAP    #15        ;This outputs to the output window
           RTS

OUTPUTC
           MOVE.B  #'C',D1    ;Moves the character into D1
           MOVE.B  #6,  D0    ;This trap task prints out character in D1
           TRAP    #15        ;This outputs to the output window
           RTS

OUTPUTD
            MOVE.B  #'D',D1    ;Moves the character into D1
            MOVE.B  #6,  D0    ;This trap task prints out character in D1
            TRAP    #15        ;This outputs to the output window
            RTS

OUTPUTE
            MOVE.B  #'E',D1    ;Moves the character into D1
            MOVE.B  #6,  D0    ;This trap task prints out character in D1
            TRAP    #15        ;This outputs to the output window
            RTS

OUTPUTF
            MOVE.B  #'F',D1    ;Moves the character into D1
            MOVE.B  #6,  D0    ;This trap task prints out character in D1
            TRAP    #15        ;This outputs to the output window
            RTS

OUTPUT_ERRORMESSAGE1
              LEA    ERRORMESSAGE1,A1
              MOVE.B  #14, D0
              TRAP    #15   
              BRA    GO_AGAIN
OUTPUT_ERRORMESSAGE2
              LEA    ERRORMESSAGE2,A1
              MOVE.B  #14, D0
              TRAP    #15   
              BRA    GO_AGAIN
PRINT_D
    MOVE.L  D1,-(SP)
    MOVE.B  #'D',D1
    MOVE.B  #6,D0
    TRAP    #15
    MOVE.L  (SP)+,D1
    RTS
PRINT_COMMA
    MOVE.L  D1,-(SP)
    MOVE.B  #',',D1
    MOVE.B  #6,D0
    TRAP    #15
    MOVE.L  (SP)+,D1
    RTS
PRINT_SLASH
    MOVE.L  D1,-(SP)
    MOVE.B  #'/',D1
    MOVE.B  #6,D0
    TRAP    #15
    MOVE.L  (SP)+,D1
    RTS
PRINT_SPACE
    MOVE.L  D1,-(SP)
    MOVE.B  #9,D1   *TAB
    MOVE.B  #6,D0
    TRAP    #15
    MOVE.L  (SP)+,D1
    RTS
PRINT_PLUS
    MOVE.L  D1,-(SP)
    MOVE.B  #'+',D1
    MOVE.B  #6,D0
    TRAP    #15
    MOVE.L  (SP)+,D1
    RTS
PRINT_MINUS
    MOVE.L  D1,-(SP)
    MOVE.B  #'-',D1
    MOVE.B  #6,D0
    TRAP    #15
    MOVE.L  (SP)+,D1
    RTS
PRINT_POUND
    MOVE.L  D1,-(SP)
    MOVE.B  #'#',D1
    MOVE.B  #6,D0
    TRAP    #15
    MOVE.L  (SP)+,D1
    RTS
PRINT_$
    MOVE.L  D1,-(SP)
    MOVE.B  #'$',D1
    MOVE.B  #6,D0
    TRAP    #15
    MOVE.L  (SP)+,D1
    RTS
PRINT_OPEN_PAREN
    MOVE.L  D1,-(SP)
    MOVE.B  #'(',D1
    MOVE.B  #6,D0
    TRAP    #15
    MOVE.L  (SP)+,D1
    RTS
PRINT_CLOSE_PAREN
    MOVE.L  D1,-(SP)
    MOVE.B  #')',D1
    MOVE.B  #6,D0
    TRAP    #15
    MOVE.L  (SP)+,D1
    RTS
PRINT_B
    MOVE.L  D1,-(SP)
    MOVE.B  #'B',D1
    MOVE.B  #6,D0
    TRAP    #15
    MOVE.L  (SP)+,D1
    RTS
PRINT_W
    MOVE.L  D1,-(SP)
    MOVE.B  #'W',D1
    MOVE.B  #6,D0
    TRAP    #15
    MOVE.L  (SP)+,D1
    RTS
PRINT_L
    MOVE.L  D1,-(SP)
    MOVE.B  #'L',D1
    MOVE.B  #6,D0
    TRAP    #15
    MOVE.L  (SP)+,D1
    RTS
PRINT_A
    MOVE.L  D1,-(SP)
    MOVE.B  #'A',D1
    MOVE.B  #6,D0
    TRAP    #15
    MOVE.L  (SP)+,D1
    RTS
    
PRINT_ADDRESS
    MOVE.L  D2,-(SP)
    MOVE.L  A2,D2
    JSR     OUTPUT_HEXADECIMAL
    MOVE.L  (SP)+,D2
    RTS
ONE_PAGE_PRINTED
    MOVEA.L #0,A6
    LEA     PAGE_PRINT_MESSAGE,A1
    MOVE.B  #13,D0
    TRAP    #15
    MOVE.B  #5,D0
DID_THEY_PRESS_ENTER
    TRAP    #15
    CMP.B   #$D,D1
    BNE     DID_THEY_PRESS_ENTER
    RTS
JMP_SECT
    MOVE.L  #%11000100,D7
    JSR     SRC_EFF_ADDR_MODE_REG
    BTST    #0,D3
    BEQ     PRINT_INVALID_OPCODE
    LEA     JMP_MESS,A1
    MOVE.B  #14,D0
    TRAP    #15
    JSR     PRINT_SPACE
    BEQ     VALID_MODE_0_JSR
    JSR     VALID_MODE_1 
    JMP     RELOOP
            SIMHALT             ; halt simulator
CR      EQU     $0D             ASCII code for Carriage Return
LF      EQU     $0A             ASCII code for Line Feed
MOVE_MESS       DC.B    'MOVE.',0
NOP_MESS        DC.B    'NOP',0
MOVEA_MESS      DC.B    'MOVEA.',0
ADDI_MESS       DC.B    'ADDI.',0
MOVEQ_MESS      DC.B    'MOVEQ ',0
MOVEM_MESS      DC.B    'MOVEM.',0
ADDQ_MESS       DC.B    'ADDQ.',0
LEA_MESS        DC.B    'LEA',0
CLR_MESS        DC.B    'CLR.',0
JSR_MESS        DC.B    'JSR',0
RTS_MESS        DC.B    'RTS',0
SUB_MESS        DC.B    'SUB.',0
DIVU_MESS       DC.B    'DIVU.',0
OR_MESS         DC.B    'OR.',0
CMP_MESS        DC.B    'CMP.',0
CMPA_MESS        DC.B    'CMPA.',0
ADD_MESS        DC.B    'ADD.',0
ADDA_MESS       DC.B    'ADDA.',0
MULS_MESS       DC.B    'MULS.',0
AND_MESS        DC.B    'AND.',0
ASR_MESS        DC.B    'ASR.',0
ASL_MESS        DC.B    'ASL.',0
LSL_MESS        DC.B    'LSL.',0
LSR_MESS        DC.B    'LSR.',0
ROR_MESS        DC.B    'ROR.',0
ROL_MESS        DC.B    'ROL.',0
BTST_MESS       DC.B    'BTST',0
BRA_MESS        DC.B    'BRA',0
BCC_MESS        DC.B    'BCC',0
BCS_MESS        DC.B    'BCS',0
BEQ_MESS        DC.B    'BEQ',0
BGE_MESS        DC.B    'BGE',0
BGT_MESS        DC.B    'BGT',0
BHI_MESS        DC.B    'BHI',0  
BLE_MESS        DC.B    'BLE',0  
BLS_MESS        DC.B    'BLS',0
BLT_MESS        DC.B    'BLT',0
BMI_MESS        DC.B    'BMI',0
BNE_MESS        DC.B    'BNE',0
BPL_MESS        DC.B    'BPL',0
BVC_MESS        DC.B    'BVC',0  
BVS_MESS        DC.B    'BVS',0
TRAP_MESS       DC.B    'TRAP',0
JMP_MESS        DC.B    'JMP',0
NEXT_LINE       DC.B    CR,LF,0    
INVALID_MESS    DC.B    'DATA',0

MESSAGE0         DC.B CR,LF,'Welcome to Disassembler.',CR,LF,'Created by: Abhi Trivedi, Conor Van Achte, and Samuel Meyerding.',CR,LF,0       
MESSAGE1         DC.B 'Please enter a starting address for your program: ',0
MESSAGE2         DC.B 'Please enter an ending address for your program: ',0
PAGE_PRINT_MESSAGE  DC.B CR,LF,'Please press enter to continue: ',0
ERRORMESSAGE1    DC.B 'Your ending address is less than the starting address',CR,LF,0
ERRORMESSAGE2    DC.B 'Error, entered addresses must be even numbers.',CR,LF,0
ENDOFPROGRAM     DC.B CR,LF,'Do you want to disassemble some more memory? (y/n)',CR,LF,0
NEWLINE          DC.B CR,LF,0

QUIT

* Put variables and constants here

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
