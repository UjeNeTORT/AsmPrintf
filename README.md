# Assembly (NASM) Printf implementation
-------
*This project is created in eductational purpose.*   

`myprintf()` function is written in assembly and simulates behaviour of standart `printf()` function.    
The functionality is reduced, althoug basic data types are present.
## Overview
***Language***:  x86_64 NASM Assembly for Linux.   

***Supported data specifiers:***
- `%%` | display `%` character (no parameter required)
- `%d` | display decimal number
- `%o` | display octal number
- `%x` | display hex number
- `%b` | display binary number
- `%c` | display character
- `%s` | display null-terminated string of bytes

***Call convention***:
`stdcall`, although the function contains trampoline, which pushes register parameters to stack in order to simulate `cdecl`. 

## Compilation and usage

Create your own C file or use my example *caller.c*.   
Declare `myprintf()` via `extern int myprintf (char * fmt_string, ...);`  

1. Compile the assembly source file.
    ``` 
    nasm -f elf64 -o myprintf.o myprintf.s 
    ```

2. Compile and link the C source file and object file.

    ```
    gcc -Wall -no-pie -o printer myprintf.o caller.c
    ```

3. Run the executable file.

    ```
    ./printer
    ```

## Educational value

While working on this project I:
- learned how to call assembly functions from C file and vice versa
- wrote my own switch in assembly and understood jumptable conception
- expanded my asm instructions repertoire 
- did quite a lot of typos which cost me at least 5 more hours of debugging the project
- did not manage to use all the 16 registers i could :-((
- learned how to use radare2 debugger
- began my work on [quick-start radare2 guide](https://github.com/UjeNeTORT/r2GuideProdva) for future students of the course I am currently at

![alt text](addtext_com_MTczMzE2NDA1MDI.png)
