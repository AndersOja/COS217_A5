
        .equ    FALSE, 0
        .equ    TRUE, 1

//----------------------------------------------------------------------  

        .section .rodata
printfFormatStr:
        .string "%7ld %7ld %7ld\n"

//----------------------------------------------------------------------

        .section .data

lLineCount:
        .quad   0
lWordCount:
        .quad   0
lCharCount:
        .quad   0
iInWord:
        .quad   0
        

//----------------------------------------------------------------------

        .section .bss

iChar:
        .skip   4

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
        .equ    MAIN_STACK_BYTECOUNT, 16

        .global main

main:
        
        // Prolog
        sub     sp, sp, MAIN_STACK_BYTECOUNT
        str     x30, [sp]

startWhile:
        // if ((iChar = getchar()) == EOF) goto endWhile;


powerLoop:

        // if (lIndex > lExp) goto powerLoopEnd
        adr     x0, lIndex
        ldr     x0, [x0]
        adr     x1, lExp
        ldr     x1, [x1]
        cmp     x0, x1
        bgt     powerLoopEnd

        // lPower *= lBase
        adr     x0, lPower
        ldr     x1, [x0]
        adr     x2, lBase
        ldr     x2, [x2]
        mul     x1, x1, x2
        str     x1, [x0]

        // lIndex++
        adr     x0, lIndex
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]

        // goto powerLoop
        b       powerLoop

powerLoopEnd:

        // printf("%ld to the %ld power is %ld.\n", lBase, lExp, lPower)
        adr     x0, printfFormatStr
        adr     x1, lBase
        ldr     x1, [x1]
        adr     x2, lExp
        ldr     x2, [x2]
        adr     x3, lPower
        ldr     x3, [x3]
        bl      printf
        
        // Epilog and return 0
        mov     w0, 0
        ldr     x30, [sp]
        add     sp, sp, MAIN_STACK_BYTECOUNT
        ret

        .size   main, (. - main)