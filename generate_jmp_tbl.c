#include <stdio.h>
#include <stdlib.h>

int main ()
{

    for (int i = 0; i < 'x' - '%' + 1; i++)
        printf ("       dq  .L%d ; %c\n", i, i + '%');

    for (int i = 0; i < 'x' - '%' + 1; i++)
        printf (".L%d: ; %c\n", i, i + '%');

    return 0;
}