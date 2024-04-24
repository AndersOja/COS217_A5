#include <stdio.h>
#include <stdlib.h>

void main() {
    int i;
    for(i = 0; i < 48000; i++) {
        int randnum = (int) ((double)rand() * 97.0 / 
                    (double)((unsigned)RAND_MAX + 1) + 32);
        if (randnum == 127) randnum = 9;
        else if (randnum == 128) randnum = 10;
        putchar((char) randnum);
    }
}