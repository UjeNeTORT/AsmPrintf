#include <stdio.h>
#include <stdlib.h>

extern int myprintf (char * fmt_string, ...);

int main ()
{
    int res = myprintf ("%o\n%d %s %x %d%%%c%b\n%d %s %x %d%%%c%b\n", -1, 
                            -1, "love", 80, 100, 33, 126,
                            -1, "love", 64, 100, 33, 126);

    printf ("this beast have returned %d\n", res);

    return 0;
}
