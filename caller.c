#include <stdio.h>
#include <stdlib.h>

extern void myprintf (char * fmt_string, ...);

int main ()
{
    myprintf ("char = %s\n", "char");


    return 0;
}