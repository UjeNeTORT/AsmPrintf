#include <stdio.h>
#include <stdlib.h>

extern void myprintf            (char * fmt_string, ...);

int main ()
{
    myprintf ("auf%d%o\n", 1, 2);

    // printf ("caller done!\n");

    return 0;
}