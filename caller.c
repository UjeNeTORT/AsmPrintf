#include <stdio.h>
#include <stdlib.h>

extern void myprintf (char * fmt_string, ...);

int main ()
{
    myprintf ("auf%c\n", 'A');
    myprintf ("string1 = %s | str2 = %s %%%%\n", "git", "please");
    myprintf ("bin = %b\n", -1);

    return 0;
}