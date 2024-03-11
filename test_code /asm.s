SECTION .text
global say_hi

extern printf

say_hi:
        push rbp

        mov rdi, fmt
        mov rsi, msg
        mov rax, 0

        call printf

        pop rbp

        mov rax, 0

        ret

SECTION .data
        string: db "ya sdohnu na etoy nedele", 0x0a
        length  equ $-string

        fmt:    db "message = %s", 10, 0
        msg:    db "ya rot tvoy ebal", 0

