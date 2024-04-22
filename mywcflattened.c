/*--------------------------------------------------------------------*/
/* mywc.c                                                             */
/* Author: Bob Dondero                                                */
/*--------------------------------------------------------------------*/

#include <stdio.h>
#include <ctype.h>

/*--------------------------------------------------------------------*/

/* In lieu of a boolean data type. */
enum {FALSE, TRUE};

/*--------------------------------------------------------------------*/

static long lLineCount = 0;      /* Bad style. */
static long lWordCount = 0;      /* Bad style. */
static long lCharCount = 0;      /* Bad style. */
static int iChar;                /* Bad style. */
static int iInWord = FALSE;      /* Bad style. */

/*--------------------------------------------------------------------*/

/* Write to stdout counts of how many lines, words, and characters
   are in stdin. A word is a sequence of non-whitespace characters.
   Whitespace is defined by the isspace() function. Return 0. */

int main(void)
{
   startWhile:

   if ((iChar = getchar()) == EOF) goto endWhile;
      lCharCount++;

      if (!isspace(iChar)) goto Else;
         if (!iInWord) goto endIf1;
            lWordCount++;
            iInWord = FALSE;
       goto endIf1;
      Else:
         if (iInWord) goto endIf1;
            iInWord = TRUE;
      endIf1:

      if (iChar != '\n') goto startWhile;
         lLineCount++;
      goto startWhile;
   endWhile:


   if (!iInWord) goto endIf2;
      lWordCount++;
   endIf2:

   printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
   return 0;
}
