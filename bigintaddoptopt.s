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
        .equ    ulSum, 32
        .equ    lIndex, 40
        .equ    lSumLength, 48
        
        // Offsets and sizes for struct params
        .equ    LLENGTH, 0
        .equ    AULDIGITS, 8
        .equ    INDEXMULT, 3

        // Registers for local variables
        OADDEND1        .req x4
        OADDEND2        .req x5
        OSUM            .req x6
        ULSUM           .req x7
        LINDEX          .req x9
        LSUMLENGTH      .req x10
        OA1AULD         .req x11
        OA2AULD         .req x12
        OSAULD          .req x13

        .global BigInt_add

BigInt_add:
        // Prolog
        sub     sp, sp, ADD_STACK_BYTECOUNT
        str     x30, [sp]
        mov     OADDEND1, x0
        mov     OADDEND2, x1
        mov     OSUM, x2

        // set auldigits registers
        add     OA1AULD, OADDEND1, AULDIGITS
        add     OA2AULD, OADDEND2, AULDIGITS
        add     OSAULD, OSUM, AULDIGITS

        // lSumLength = BigInt_larger(oAddend1->lLength, 
        // oAddend2->lLength)
        ldr     x0, [OADDEND1, LLENGTH]
        ldr     x1, [OADDEND2, LLENGTH]
        cmp     x0, x1
        ble     L1LessL2
        mov     LSUMLENGTH, x0
        b       endLarger

L1LessL2:
        // lSumLength = oAddend2->lLength
        mov     LSUMLENGTH, x1

endLarger:
        // if (oSum->lLength <= lSumLength) goto endIf2
        ldr     x0, [OSUM, LLENGTH]
        cmp     x0, LSUMLENGTH
        ble     endIf1

        // memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long))
        mov     x0, OSAULD
        mov     x1, 0
        mov     x2, MAX_DIGITS
        mov     x3, 8
        mul     x2, x2, x3
        bl      memset

endIf1:
        // lIndex = 0 and set carry flag to 0
        adds    LINDEX, xzr, xzr

        // initial loop condition
        sub     x0, LINDEX, LSUMLENGTH
        cbz     x0, forLoopEnd

forLoopStart:
        // ulSum = oAddend1->aulDigits[lIndex]
        // ulSum += oAddend2->aulDigits[lIndex]
        ldr     x0, [OA1AULD, LINDEX, lsl INDEXMULT]
        ldr     x1, [OA2AULD, LINDEX, lsl INDEXMULT]
        adcs    ULSUM, x0, x1

        // oSum->aulDigits[lIndex] = ulSum
        str     ULSUM, [OSAULD, LINDEX, lsl INDEXMULT]

        // lIndex++
        add     LINDEX, LINDEX, 1

        // loop condition
        sub     x0, LINDEX, LSUMLENGTH
        cbnz    x0, forLoopStart

forLoopEnd:
        // branch based on carry
        blo     endLoopNoCarry

        // if (lSumLength != MAX_DIGITS) goto endIf4
        mov     x0, MAX_DIGITS
        cmp     LSUMLENGTH, x0
        bne     endIf2

        // Epilogue and return FALSE
        mov     x0, FALSE
        ldr     x30, [sp]
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret

endIf2:
        // oSum->aulDigits[lSumLength] = 1
        add     x0, OSUM, AULDIGITS
        mov     x1, 1
        str     x1, [x0, LSUMLENGTH, lsl INDEXMULT]

        // lSumLength++
        add     LSUMLENGTH, LSUMLENGTH, 1

endLoopNoCarry:
        // oSum->lLength = lSumLength
        str     LSUMLENGTH, [OSUM, LLENGTH]

        // Epilogue and return TRUE
        mov x0, TRUE
        ldr     x30, [sp]
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret  

        .size   BigInt_add, (. - BigInt_add)
        