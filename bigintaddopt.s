        .equ    FALSE, 0
        .equ    TRUE, 1
        .equ    MAX_DIGITS, 32768

//----------------------------------------------------------------------  

        .section .rodata

//----------------------------------------------------------------------

        .section .data

//----------------------------------------------------------------------

        .section .bss

//----------------------------------------------------------------------

        .section .text

        //--------------------------------------------------------------
        // Return the larger of lLength1 and lLength2.
        //--------------------------------------------------------------

        // Must be a multiple of 16
        .equ    LARGER_STACK_BYTECOUNT, 32

        // Offsets for local variables and callee saved registers
        .equ    lLength1, 8
        .equ    lLength2, 16
        .equ    lLarger, 24
        lLength1    .req x19
        lLength2    .req x20
        lLarger     .req x21



BigInt_larger:
        // Prolog
        sub     sp, sp, LARGER_STACK_BYTECOUNT
        str     x30, [sp]
        str     x0, [sp, lLength1]
        str     x1, [sp, lLength2]
        str     lLength1, [sp, lLength1]

        // if (lLength1 <= lLength2) goto Else1
        cmp     x0, x1
        ble     Else1

        // lLarger = lLength1
        ldr     x0, [sp, lLength1]
        str     x0, [sp, lLarger]

        // goto endIf1
        b       endIf1

Else1:
        ldr     x0, [sp, lLength2]
        str     x0, [sp, lLarger]

endIf1:
        ldr     x0, [sp, lLarger]
        ldr     x30, [sp]
        add     sp, sp, LARGER_STACK_BYTECOUNT
        ret

        .size   BigInt_larger, (. - BigInt_larger)

        //--------------------------------------------------------------
        // Assign the sum of oAddend1 and oAddend2 to oSum. oSum should 
        // be distinct from oAddend1 and oAddend2.  Return 0 (FALSE) 
        // if an overflow occurred, and 1 (TRUE) otherwise.
        //--------------------------------------------------------------

        .equ    ADD_STACK_BYTECOUNT, 64

        //Offsets for local variables
        .equ    oAddend1, 8
        .equ    oAddend2, 16
        .equ    oSum, 24
        .equ    ulCarry, 32
        .equ    ulSum, 40
        .equ    lIndex, 48
        .equ    lSumLength, 56

        .global BigInt_add

BigInt_add:
        // Prolog
        sub     sp, sp, ADD_STACK_BYTECOUNT
        str     x30, [sp]
        str     x0, [sp, oAddend1]
        str     x1, [sp, oAddend2]
        str     x2, [sp, oSum]

        // lSumLength = BigInt_larger(oAddend1->lLength, 
        // oAddend2->lLength)
        ldr     x0, [sp, oAddend1]
        ldr     x0, [x0]
        ldr     x1, [sp, oAddend2]
        ldr     x1, [x1]
        bl      BigInt_larger
        str     x0, [sp, lSumLength]

        // if (oSum->lLength <= lSumLength) goto endIf2
        ldr     x0, [sp, oSum]
        ldr     x0, [x0]
        ldr     x1, [sp, lSumLength]
        cmp     x0, x1
        ble     endIf2

        // memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long))
        ldr     x0, [sp, oSum]
        add     x0, x0, 8
        mov     x1, 0
        mov     x2, MAX_DIGITS
        mov     x3, 8
        mul     x2, x2, x3
        bl      memset

endIf2:
        // ulCarry = 0
        mov     x0, 0
        str     x0, [sp, ulCarry]

        // lIndex = 0
        str     x0, [sp, lIndex]

startForLoop1:
        // if(lIndex >= lSumLength) goto endForLoop1
        ldr     x0, [sp, lIndex]
        ldr     x1, [sp, lSumLength]
        cmp     x0, x1
        bge     endForLoop1

        // ulSum = ulCarry
        ldr     x0, [sp, ulCarry]
        str     x0, [sp, ulSum]

        // ulCarry = 0
        mov     x0, 0
        str     x0, [sp, ulCarry]
        
        // ulSum += oAddend1->aulDigits[lIndex]
        ldr     x0, [sp, ulSum]
        ldr     x1, [sp, oAddend1]
        add     x1, x1, 8
        ldr     x2, [sp, lIndex]
        ldr     x1, [x1, x2, lsl 3]
        add     x0, x0, x1
        str     x0, [sp, ulSum]

        // if (ulSum >= oAddend1->aulDigits[lIndex]) goto ForIf1
        ldr     x0, [sp, ulSum]
        ldr     x1, [sp, oAddend1]
        add     x1, x1, 8
        ldr     x2, [sp, lIndex]
        ldr     x1, [x1, x2, lsl 3]
        cmp     x0, x1
        bhs     ForIf1

        // ulCarry = 1
        mov     x0, 1
        str     x0, [sp, ulCarry]

ForIf1:
        // ulSum += oAddend2->aulDigits[lIndex]
        ldr     x0, [sp, ulSum]
        ldr     x1, [sp, oAddend2]
        add     x1, x1, 8
        ldr     x2, [sp, lIndex]
        ldr     x1, [x1, x2, lsl 3]
        add     x0, x0, x1
        str     x0, [sp, ulSum]

        // if (ulSum >= oAddend2->aulDigits[lIndex]) goto ForIf2
        ldr     x0, [sp, ulSum]
        ldr     x1, [sp, oAddend2]
        add     x1, x1, 8
        ldr     x2, [sp, lIndex]
        ldr     x1, [x1, x2, lsl 3]
        cmp     x0, x1
        bhs     ForIf2

        // ulCarry = 1
        mov     x0, 1
        str     x0, [sp, ulCarry]

    ForIf2:
        // oSum->aulDigits[lIndex] = ulSum
        ldr     x0, [sp, ulSum]
        ldr     x1, [sp, oSum]
        add     x1, x1, 8
        ldr     x2, [sp, lIndex]
        str     x0, [x1, x2, lsl 3]

        // lIndex++
        ldr     x0, [sp, lIndex]
        add     x0, x0, 1
        str     x0, [sp, lIndex]

        // goto startForLoop1
        b       startForLoop1

endForLoop1:
        // if (ulCarry != 1) goto endIf3
        ldr     x0, [sp, ulCarry]
        mov     x1, 1
        cmp     x0, x1
        bne     endIf3

        // if (lSumLength != MAX_DIGITS) goto endIf4
        ldr     x0, [sp, lSumLength]
        mov     x1, MAX_DIGITS
        cmp     x0, x1
        bne     endIf4

        // Epilogue and return FALSE
        mov     x0, FALSE
        ldr     x30, [sp]
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret

endIf4:
        // oSum->aulDigits[lSumLength] = 1
        mov     x0, 1
        ldr     x1, [sp, oSum]
        add     x1, x1, 8
        ldr     x2, [sp, lSumLength]
        str     x0, [x1, x2, lsl 3]

        // lSumLength++
        ldr     x0, [sp, lSumLength]
        add     x0, x0, 1
        str     x0, [sp, lSumLength]

endIf3:
        // oSum->lLength = lSumLength
        ldr     x0, [sp, lSumLength]
        ldr     x1, [sp, oSum]
        str     x0, [x1]

        // Epilogue and return TRUE
        mov x0, TRUE
        ldr     x30, [sp]
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret  

        .size   BigInt_add, (. - BigInt_add)
        