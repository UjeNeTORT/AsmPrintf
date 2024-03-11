SECTION .text
global say_hi

say_hi:
        mov rax, 0x01   ; write (rdi, rsi, rdx)
        mov rdi, 0x01   ; stdout
        mov rsi, string
        mov rdx, length
        syscall

        ret

SECTION .data
        string: db "ya sdohnu na etoy nedele", 0x0a
        length  equ $-string
          
