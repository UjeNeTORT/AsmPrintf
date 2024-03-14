#include <stdio.h>
#include <stdlib.h>

extern void myprintf (char * fmt_string, ...);

int main ()
{
    myprintf ("auf%c\n", 'A');
    myprintf ("string1 = %s | str2 = %s %%%%\n", "git", "please");
    myprintf ("bin = %b\n", 0);
    myprintf ("oct = %o\n", 10);
    myprintf ("hex = %x and %x\n", -10, 64);

    return 0;
}