SECTION .text

extern  printf

global  myprintf
global  count_printf_params

;===========================================================
; THIS IS NOT AN ACTUAL FUNCTION BUT A TRAMPOLINE TO
;       SIMULATE CDECL CALL CONVENTION
;
;
; Destr:
;===========================================================
; extern int myprintf (const char* fmt_string, params...)
myprintf:
        push r9
        push r8
        push rcx
        push rbx
        push rsi
        push rdi

        call myprintf_cdecl

        add rsp, 6 * 8

        ret

;===========================================================
;
;
;
; Destr:
;===========================================================
; extern int myprintf (const char* fmt_string, params...)
myprintf_cdecl:

        push rbp
        mov rbp, rsp

        push QWORD [rbp + 0x10]         ; push string offset

        call count_printf_params

        add rsp, 8                      ; pop call argument

        pop rbp

        mov rax, 0

        ret

;===========================================================
; Entry:
;       [RBP + 0x10] - format string which contains % symbols
; Returns:
;       RAX - number of parameters in printf format string
;
; if next symbol after % is not 0, then ignore it and go to i+2 (not i+1)
;
;===========================================================
count_printf_params:

        push rbp
        mov  rbp, rsp

        push rcx        ; save

        xor rax, rax

        mov rcx, [rbp + 0x10]

.next:

        loop .next

        pop rcx         ; restore

        pop rbp

        ret

SECTION .data
        fmt:    db "count printf params received = %s", 10, 0
        msg:    db "aloha daun", 10, 0