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
        cmp     x0, x1
        ble     L1LessL2
        mov     LSUMLENGTH, x0
        b       endLarger

L1LessL2:
        // lLarger = lLength2
        mov     LSUMLENGTH, x1

endLarger:

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
        // ulSum = ulCarry
        mov     ULSUM, ULCARRY

        // ulCarry = 0
        mov     ULCARRY, 0

        // ulSum += oAddend1->aulDigits[lIndex]
        add     x0, OADDEND1, AULDIGITS
        ldr     x0, [x0, LINDEX, lsl INDEXMULT]
        adcs    ULSUM, ULSUM, x0
        bhs     ForIf1

        // ulSum += oAddend2->aulDigits[lIndex]
        add     x0, OADDEND2, AULDIGITS
        ldr     x0, [x0, LINDEX, lsl INDEXMULT]
        adcs    ULSUM, ULSUM, x0
        b       ForIf2

ForIf1:
        // ulSum += oAddend2->aulDigits[lIndex]
        add     x0, OADDEND2, AULDIGITS
        ldr     x0, [x0, LINDEX, lsl INDEXMULT]
        add     ULSUM, ULSUM, x0

ForIf2:
        // oSum->aulDigits[lIndex] = ulSum
        add     x0, OSUM, AULDIGITS
        str     ULSUM, [x0, LINDEX, lsl INDEXMULT]

        // lIndex++
        add     LINDEX, LINDEX, 1

        // Set ulCarry
        blo     endCarry
        mov     ULCARRY, 1

endCarry:
        // if(lIndex < lSumLength) goto startForLoop1
        cmp     LINDEX, LSUMLENGTH
        blt     startForLoop1

        // if (ulCarry != 1) goto endIf3
        mov     x0, 1
        cmp     ULCARRY, x0
        bne     endIf3

        // if (lSumLength != MAX_DIGITS) goto endIf4
        mov     x0, MAX_DIGITS
        cmp     LSUMLENGTH, x0
        bne     endIf4

        // Epilogue and return FALSE
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
        str     x1, [x0, LINDEX, lsl INDEXMULT]

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
