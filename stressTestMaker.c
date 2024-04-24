#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main() {
    int i;
    for(i = 0; i < 48000; i++) {
        int randnum = (int) (srand(time(NULL)) % 97.0 + 32.0);
        if (randnum == 127) randnum = 9;
        else if (randnum == 128) randnum = 10;
        putchar((char) randnum);
    }
    return 0;
}