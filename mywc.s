
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
        bl      getchar
        adr     x1, iChar
        str     x0, [x1]
        ldr     x0, [x1]
        cmp     x0, EOF
        beq     endWhile

        // lCharCount++
        adr     x0, lCharCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]

        // if (!isspace(iChar)) goto Else
        adr     x0, iChar
        ldr     x0, [x0]
        bl      isspace
        cmp     x0, FALSE
        beq     Else

        // if (!iInWord) goto endIf1
        adr     x0, iInWord
        ldr     x0, [x0]
        cmp     x0, FALSE
        beq     endIf1

        // lWordCount++
        adr     x0, lWordCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]

        // iInWord = FALSE
        adr     x0, iInWord
        mov     x1, FALSE
        str     x1, [x0]

        // goto endIf1
        b       endIf1

Else:
        // if (iInWord) goto endIf1
        adr     x0, iInWord
        ldr     x0, [x0]
        cmp     x0, TRUE
        beq     endIf1

        // iInWord = TRUE
        adr     x0, iInWord
        mov     x1, TRUE
        str     x1, [x0]

endIf1:
        // if (iChar != '\n') goto startWhile
        adr     x0, iChar
        ldr     x0, [x0]
        mov     x1, '\n'
        cmp     x0, x1
        bne    startWhile

        // lLineCount++
        adr     x0, lLineCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]
        
        // goto startWhile
        b       startWhile

endWhile:
        // if (!iInWord) goto endIf2
        adr     x0, iInWord
        ldr     x0, [x0]
        cmp     x0, FALSE
        beq     endIf2
        // lWordCount++
        adr     x0, lWordCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]

endIf2:
        // printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount)
        adr     x0, printfFormatStr
        adr     x1, lLineCount
        ldr     x1, [x1]
        adr     x2, lWordCount
        ldr     x2, [x2]
        adr     x3, lCharCount
        ldr     x3, [x3]
        bl      printf

        // Epilog and return 0
        mov     w0, 0
        ldr     x30, [sp]
        add     sp, sp, MAIN_STACK_BYTECOUNT
        ret

        .size   main, (. - main)