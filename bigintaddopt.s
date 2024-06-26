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

        // Offsets for local variables
        .equ    lLength1, 8
        .equ    lLength2, 16
        .equ    lLarger, 24
        LLENGTH1        .req x19
        LLENGTH2        .req x20
        LLARGER         .req x21


BigInt_larger:
        // Prolog
        sub     sp, sp, LARGER_STACK_BYTECOUNT
        str     x30, [sp]
        str     x19, [sp, lLength1]
        str     x20, [sp, lLength2]
        str     x21, [sp, lLarger]
        mov     LLENGTH1, x0
        mov     LLENGTH2, x1
        

        // if (lLength1 <= lLength2) goto Else1
        cmp     LLENGTH1, LLENGTH2
        ble     Else1

        // lLarger = lLength1
        mov     LLARGER, LLENGTH1

        // goto endIf1
        b       endIf1

Else1:
        // lLarger = lLength2
        mov     LLARGER, LLENGTH2

endIf1:
        // Epilogue and return lLarger
        mov     x0, LLARGER
        ldr     LLENGTH1, [sp, lLength1]
        ldr     LLENGTH2, [sp, lLength2]
        ldr     LLARGER, [sp, lLarger]
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
        .equ    LLENGTH, 0
        .equ    AULDIGITS, 8
        .equ    INDEXMULT, 3
        OADDEND1        .req x19
        OADDEND2        .req x20
        OSUM            .req x21
        ULCARRY         .req x22
        ULSUM           .req x23
        LINDEX          .req x24
        LSUMLENGTH      .req x25

        .global BigInt_add

BigInt_add:
        // Prolog
        sub     sp, sp, ADD_STACK_BYTECOUNT
        str     x30, [sp]
        str     OADDEND1, [sp, oAddend1]
        str     OADDEND2, [sp, oAddend2]
        str     OSUM, [sp, oSum]
        str     ULCARRY, [sp, ulCarry]
        str     ULSUM, [sp, ulSum]
        str     LINDEX, [sp, lIndex]
        str     LSUMLENGTH, [sp, lSumLength]
        mov     OADDEND1, x0
        mov     OADDEND2, x1
        mov     OSUM, x2

        // lSumLength = BigInt_larger(oAddend1->lLength, 
        // oAddend2->lLength)
        ldr     x0, [OADDEND1, LLENGTH]
        ldr     x1, [OADDEND2, LLENGTH]
        bl      BigInt_larger
        mov     LSUMLENGTH, x0

        // if (oSum->lLength <= lSumLength) goto endIf2
        ldr     x0, [OSUM, LLENGTH]
        cmp     x0, LSUMLENGTH
        ble     endIf2

        // memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long))
        add     x0, OSUM, AULDIGITS
        mov     x1, 0
        mov     x2, MAX_DIGITS
        mov     x3, 8
        mul     x2, x2, x3
        bl      memset

endIf2:
        // ulCarry = 0
        mov     ULCARRY, 0

        // lIndex = 0
        mov     LINDEX, 0

startForLoop1:
        // if(lIndex >= lSumLength) goto endForLoop1
        cmp     LINDEX, LSUMLENGTH
        bge     endForLoop1

        // ulSum = ulCarry
        mov     ULSUM, ULCARRY

        // ulCarry = 0
        mov     ULCARRY, 0
        
        // ulSum += oAddend1->aulDigits[lIndex]
        add     x0, OADDEND1, AULDIGITS
        ldr     x0, [x0, LINDEX, lsl INDEXMULT]
        add     ULSUM, ULSUM, x0

        // if (ulSum >= oAddend1->aulDigits[lIndex]) goto ForIf1
        add     x0, OADDEND1, AULDIGITS
        ldr     x0, [x0, LINDEX, lsl INDEXMULT]
        cmp     ULSUM, x0
        bhs     ForIf1

        // ulCarry = 1
        mov     ULCARRY, 1

ForIf1:
        // ulSum += oAddend2->aulDigits[lIndex]
        add     x0, OADDEND2, AULDIGITS
        ldr     x0, [x0, LINDEX, lsl INDEXMULT]
        add     ULSUM, ULSUM, x0

        // if (ulSum >= oAddend2->aulDigits[lIndex]) goto ForIf2
        add     x0, OADDEND2, AULDIGITS
        ldr     x0, [x0, LINDEX, lsl INDEXMULT]
        cmp     ULSUM, x0
        bhs     ForIf2

        // ulCarry = 1
        mov     ULCARRY, 1

ForIf2:
        // oSum->aulDigits[lIndex] = ulSum
        add     x0, OSUM, AULDIGITS
        str     ULSUM, [x0, LINDEX, lsl INDEXMULT]


        // lIndex++
        add     LINDEX, LINDEX, 1

        // goto startForLoop1
        b       startForLoop1

endForLoop1:
        // if (ulCarry != 1) goto endIf3
        mov     x0, 1
        cmp     ULCARRY, x0
        bne     endIf3

        // if (lSumLength != MAX_DIGITS) goto endIf4
        mov     x0, MAX_DIGITS
        cmp     LSUMLENGTH, x0
        bne     endIf4

        // Epilogue and return FALSE DO SHIT HERE
        mov     x0, FALSE
        ldr     x30, [sp]
        ldr     OADDEND1, [sp, oAddend1]
        ldr     OADDEND2, [sp, oAddend2]
        ldr     OSUM, [sp, oSum]
        ldr     ULCARRY, [sp, ulCarry]
        ldr     ULSUM, [sp, ulSum]
        ldr     LINDEX, [sp, lIndex]
        ldr     LSUMLENGTH, [sp, lSumLength]
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret

endIf4:
        // oSum->aulDigits[lSumLength] = 1
        add     x0, OSUM, AULDIGITS
        mov     x1, 1
        str     x1, [x0, LSUMLENGTH, lsl INDEXMULT]

        // lSumLength++
        add     LSUMLENGTH, LSUMLENGTH, 1

endIf3:
        // oSum->lLength = lSumLength
        str     LSUMLENGTH, [OSUM, LLENGTH]

        // Epilogue and return TRUE
        mov x0, TRUE
        ldr     x30, [sp]
        ldr     OADDEND1, [sp, oAddend1]
        ldr     OADDEND2, [sp, oAddend2]
        ldr     OSUM, [sp, oSum]
        ldr     ULCARRY, [sp, ulCarry]
        ldr     ULSUM, [sp, ulSum]
        ldr     LINDEX, [sp, lIndex]
        ldr     LSUMLENGTH, [sp, lSumLength]
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret  

        .size   BigInt_add, (. - BigInt_add)
        