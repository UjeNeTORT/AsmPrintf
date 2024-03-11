#include <stdio.h>
#include <stdlib.h>

extern void myprintf            (char * fmt_string, ...);
extern int  count_printf_params (char * fmt_string);

int main ()
{
    myprintf ("auf", 1, 2, 3, 4, 5, 6, 7);

    // printf ("caller done!\n");

    return 0;
}