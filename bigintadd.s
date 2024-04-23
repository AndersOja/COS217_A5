        .equ    FALSE, 0
        .equ    TRUE, 1
        .equ    32768

//----------------------------------------------------------------------  

        .section .rodata

//----------------------------------------------------------------------

        .section .data
        

//----------------------------------------------------------------------

        .section .bss


//----------------------------------------------------------------------

        .section .text

        //--------------------------------------------------------------
        // Write to stdout counts of how many lines, words, and 
        // characters are in stdin. A word is a sequence of 
        // non-whitespace characters. Whitespace is defined by the 
        // isspace() function. Return 0. 
        // int main(void)
        //--------------------------------------------------------------

        // Must be a multiple of 16
        .equ    LARGER_STACK_BYTECOUNT, 32
        .equ    ADD_STACK_BYTECOUNT, 64

        // Offsets for local variables
        
        //BigInt-Larger
        .equ    lLength1, 8
        .equ    lLength2, 16
        .equ    lLarger, 24

        //BigInt_add
        .equ    oAddend1, 8
        .equ    oAddend2, 16
        .equ    oSum, 24
        .equ    ulCarry, 32
        .equ    ulSum, 40
        .equ    lIndex, 48
        .equ    lSumLength, 56



        .global BigInt_add
        .private BigInt_larger

BigInt_larger:
        // Prolog
        sub     sp, sp, LARGER_STACK_BYTECOUNT
        str     x30, [sp]
        // if (lLength1 <= lLength2) goto Else1;
        cmp     x0, x1
        ble     Else1
        // lLarger = lLength1;
        str     x0, [sp, lLarger]
        // goto endIf1
        b       endIf1
Else1:
        ldr     x0, [sp, lLength2]
        str     x0, [sp, lLarger]
endIf1:
        ret

        .size   BigInt_larger, (. - BigInt_larger)

BigInt_add:
        // Prolog
        sub     sp, sp, ADD_STACK_BYTECOUNT
        str     x30, [sp]

        //lSumLength = BigInt_larger(oAddend1->lLength, 
        // oAddend2->lLength);
        ldr     x0, [sp, oAddend1]
        ldr     x0, [x0]
        ldr     x1, [sp, oAddend2]
        ldr     x1, [x1]
        bl      BigInt_larger
        str     x0, [sp, lSumLength]
        // if (oSum->lLength <= lSumLength) goto endIf2;
        ldr     x0, [sp, oSum]
        ldr     x0, [x0]
        ldr     x1, [sp, lSumLength]
        cmp     x0, x1
        ble     endIf2
        // memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
        ldr     x0, [sp, oSum]
        add     x0, x0, 8
        ldr     x0, [x0]
        mov     x1, 0
        mov     x2, MAX_DIGITS
        mov     x3, 8
        mul     x2, x2, x3
        bl      memset
endIf2:
        // ulCarry = 0;
        str     zr, [sp, ulCarry]
        // lIndex = 0;
        str     zr, [sp, lIndex]
startForLoop1:
        // if(lIndex >= lSumLength) goto endForLoop1;
        ldr     x0, [s, lIndex]
        ldr     x1, [sp, lSumLength]
        cmp     x0, x1
        bge     endForLoop1
        // ulSum = ulCarry;
        ldr     x0, [sp, ulCarry]
        str     x0, [sp, ulSum]
        // ulCarry = 0;
        str     zr, [sp, ulCarry]
        // ulSum += oAddend1->aulDigits[lIndex];
        ldr     x0, [sp, ulSum]
        ldr     x1, [sp, oAddend1]
        add     x1, 8
        ldr     x2, [sp, lIndex]
        ldr     x1, [x1, x2, lsl 3]
        add     x0, x0, x1
        str     x0, [sp, ulSum]
        // if (ulSum >= oAddend1->aulDigits[lIndex]) goto ForIf1;
        ldr     x0, [sp, ulSum]
        ldr     x1, [sp, oAddend1]
        add     x1, 8
        ldr     x2, [sp, lIndex]
        ldr     x1, [x1, x2, lsl 3]
        cmp     x0, x1
        bge     ForIf1
        // ulCarry = 1
        mov     x0, 1
        str     x0, [sp, ulCarry]
ForIf1:
        // ulSum += oAddend2->aulDigits[lIndex];
        ldr     x0, [sp, ulSum]
        ldr     x1, [sp, oAddend2]
        add     x1, 8
        ldr     x2, [sp, lIndex]
        ldr     x1, [x1, x2, lsl 3]
        add     x0, x0, x1
        // if (ulSum >= oAddend2->aulDigits[lIndex]) goto ForIf2;
        ldr     x0, [sp, ulSum]
        ldr     x1, [sp, oAddend2]
        add     x1, 8
        ldr     x2, [sp, lIndex]
        ldr     x1, [x1, x2, lsl 3]
        cmp     x0, x1
        bge     ForIf2
        // ulCarry = 1;
        mov     x0, 1
        str     x0, [sp, ulCarry]
    ForIf2:
        // oSum->aulDigits[lIndex] = ulSum;
        ldr     x0, [sp, ulSum]
        ldr     x1, [sp, oSum]
        add     x1, x1, 8
        ldr     x2, [sp, lIndex]
        str     x0, [x1, x2, lsl 3]
        // lIndex++;
        add     x2, x2, 1
        str     x2, [sp, ulIndex]
        // goto startForLoop1
        b       startForLoop1
endForLoop1:
        // if (ulCarry != 1) goto endIf3;
        ldr     x0, [sp, ulCarry]
        mov     x1, 1
        cmp     x0, x1
        bne     endIf3
        // if (lSumLength != MAX_DIGITS) goto endIf4;
        ldr     x0, [sp, lSumLength]
        mov     x1, MAX_DIGITS
        cmp     x0, x1
        bne     endIf4
        // return FALSE;
        mov     x0, FALSE
        ret
endIf4:
        // oSum->aulDigits[lSumLength] = 1;
        mov     x0, 1
        ldr     x1, [sp, oSum]
        add     x1, x1, 8
        ldr     x2, [sp, lSumLength]
        str     x0, [x1, x2, lsl 3]
        // lSumLength++;
        add     x2, x2, 1
endIf3:
        //oSum->lLength = lSumLength;
        ldr     x0, [sp, lSumLength]
        ldr     x1, [sp, oSum]
        str     x0, [x1]
        //return TRUE;
        mov x0, TRUE
        ret  

        .size   BigInt_add, (. - BigInt_add)
