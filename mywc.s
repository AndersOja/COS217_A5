
        .section .rodata

//----------------------------------------------------------------------

        .section .data

lPower:
        .quad   1

//----------------------------------------------------------------------

        .section .bss

lBase:
        .skip   8

lExp:
        .skip   8

lIndex:
        .skip   8

//----------------------------------------------------------------------

        .section .text

        //--------------------------------------------------------------
        // Read a non-negative base and exponent from stdin.  Write
        // base raised to the exponent power to stdout.  Return 0.
        // int main(void)
        //--------------------------------------------------------------

        // Must be a multiple of 16
        .equ    MAIN_STACK_BYTECOUNT, 16

        .global main

main:
        
        // Prolog
        sub     sp, sp, MAIN_STACK_BYTECOUNT
        str     x30, [sp]

        // printf("Enter the base:  ")
        adr     x0, basePromptStr
        bl      printf

        // scanf("%d", &lBase)
        adr     x0, scanfFormatStr
        adr     x1, lBase
        bl      scanf

        // printf("Enter the exponent:  ")
        adr     x0, expPromptStr
        bl      printf

        // scanf("%d", &lExp)
        adr     x0, scanfFormatStr
        adr     x1, lExp
        bl      scanf

        // lIndex = 1
        mov     x0, 1
        adr     x1, lIndex
        str     x0, [x1]

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