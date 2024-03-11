SECTION .text

extern  printf

global  myprintf

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
; Return:
;       RAX - number of specifiers which were successfully
;               handled
; Destr:
;===========================================================
; extern int myprintf (const char* fmt_string, params...)
myprintf_cdecl:

        push rbp
        mov rbp, rsp

        push rcx                        ; save
        push rbx

        xor rcx, rcx                    ; rcx = 0
        mov rbx, QWORD [rbp + 0x10]     ; rbx = format string

; -----------------------------------------------------------------
.str_loop:
        cmp byte [rbx], '%'             ; check if symb is specifier
        je .specifier_encounter

        ; if not specifier - putchar()
        push rcx                        ; protect from syscall

        mov rax, 0x01                   ; write64 (rdi, rsi, rax)
        mov rdi, 0x01                   ; stdout fd
        mov rsi, rbx                    ; curr string pos
        mov rdx, 0x01                   ; display only 1 char
        syscall

        pop rcx

.str_loop_end:
        inc rbx                         ; next symbol

        cmp byte [rbx], 0               ; stop if encounter null terminator
        jne .str_loop
; -----------------------------------------------------------------
        jmp .func_end

.specifier_encounter:
        inc rcx                         ; increase number of processed specifiers
        inc rbx                         ; skip % symbol

                                        ; location of specifier parameter in stack
        push QWORD [rbp + rcx * 0x08 + 0x08]
        push QWORD [rbx]                ; specifier symbol

        call process_specifier

        add  rsp, 2 * 8                 ; clean stack

        jmp .str_loop_end

        jmp .func_end                   ; precaution

.func_end:

        mov rax, rcx                    ; return value
        pop rbx                         ; restore
        pop rcx

        pop rbp

        ret

;===========================================================
;
;===========================================================
process_specifier:

        push rbp
        mov rbp, rsp



        pop rbp

        ret

SECTION .data
        fmt:    db "count printf params received = %s", 10, 0
        msg:    db "aloha daun", 10, 0