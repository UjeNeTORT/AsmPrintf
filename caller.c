#include <stdio.h>
#include <stdlib.h>

extern int myprintf (char * fmt_string, ...);

int main ()
{
    // myprintf ("auf%c\n", 'A');
    // myprintf ("string1 = %s | str2 = %s %%%%\n", "git", "please");
    // myprintf ("bin = %b\n", 0);
    // myprintf ("oct = %o\n", 10);
    // myprintf ("hex = %x and %x\n", -10, 64);
    // myprintf ("dec = %d\n", 33);

    int res = myprintf ("%o\n%d %s %x %d%%%c%b\n%d %s %x %d%%%c%b\n", -1, 
                            -1, "love RADAR", 226, 100, 33, 126,
                            -1, "love RADAR", 226, 100, 33, 126);

    printf ("%d\n", res);

    return 0;
}