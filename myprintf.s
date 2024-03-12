SECTION .text

extern  printf
extern  putchar

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

        add rsp, 6 * 0x08

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
        cmp BYTE [rbx], '%'             ; check if symb is specifier
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

        cmp BYTE [rbx], 0               ; stop if encounter null terminator
        jne .str_loop
; -----------------------------------------------------------------
        jmp .func_end

.specifier_encounter:
        inc rbx                         ; skip % symbol

                                        ; location of specifier parameter in stack
        push QWORD [rbp + rcx * 0x08 + 0x10]
        push rbx                        ; specifier symbol

        call process_specifier

        add  rsp, 2 * 0x08                 ; clean stack

        cmp rbx, '%'
        jne .spend_stack_param
        jmp .str_loop_end

.spend_stack_param:
        inc rcx                         ; increase number of processed specifiers
        jmp .str_loop_end

        jmp .func_end                   ; kinda silly precaution

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

        push rbx                ; save
        push rcx

        mov rbx, [rbp + 0x10]   ; arg1 - spec symbol
        mov cl, BYTE [rbx]
        xor rbx, rbx
        mov bl, cl

        cmp rbx, 'x'            ; x has the greates ASCII code among all the spec symbs
        ja .default
        cmp rbx, '%'
        jb .default

        sub rbx, '%'            ; % has the least ASCII code among
        jmp [.jmptbl + 0x08 * rbx]

.jmptbl:
        dq  .case_prcnt ; %
        dq  .L1         ; &
        dq  .L2         ; '
        dq  .L3         ; (
        dq  .L4         ; )
        dq  .L5         ; *
        dq  .L6         ; +
        dq  .L7         ; ,
        dq  .L8         ; -
        dq  .L9         ; .
        dq  .L10        ; /
        dq  .L11        ; 0
        dq  .L12        ; 1
        dq  .L13        ; 2
        dq  .L14        ; 3
        dq  .L15        ; 4
        dq  .L16        ; 5
        dq  .L17        ; 6
        dq  .L18        ; 7
        dq  .L19        ; 8
        dq  .L20        ; 9
        dq  .L21        ; :
        dq  .L22        ; ;
        dq  .L23        ; <
        dq  .L24        ; =
        dq  .L25        ; >
        dq  .L26        ; ?
        dq  .L27        ; @
        dq  .L28        ; A
        dq  .L29        ; B
        dq  .L30        ; C
        dq  .L31        ; D
        dq  .L32        ; E
        dq  .L33        ; F
        dq  .L34        ; G
        dq  .L35        ; H
        dq  .L36        ; I
        dq  .L37        ; J
        dq  .L38        ; K
        dq  .L39        ; L
        dq  .L40        ; M
        dq  .L41        ; N
        dq  .L42        ; O
        dq  .L43        ; P
        dq  .L44        ; Q
        dq  .L45        ; R
        dq  .L46        ; S
        dq  .L47        ; T
        dq  .L48        ; U
        dq  .L49        ; V
        dq  .L50        ; W
        dq  .L51        ; X
        dq  .L52        ; Y
        dq  .L53        ; Z
        dq  .L54        ; [
        dq  .L55        ; \
        dq  .L56        ; ]
        dq  .L57        ; ^
        dq  .L58        ; _
        dq  .L59        ; `
        dq  .L60        ; a
        dq  .case_b     ; b
        dq  .case_c     ; c
        dq  .case_d     ; d
        dq  .L64        ; e
        dq  .L65        ; f
        dq  .L66        ; g
        dq  .L67        ; h
        dq  .L68        ; i
        dq  .L69        ; j
        dq  .L70        ; k
        dq  .L71        ; l
        dq  .L72        ; m
        dq  .L73        ; n
        dq  .case_o     ; o
        dq  .L75        ; p
        dq  .L76        ; q
        dq  .L77        ; r
        dq  .case_s     ; s
        dq  .L79        ; t
        dq  .L80        ; u
        dq  .L81        ; v
        dq  .L82        ; w
        dq  .case_x     ; x
        dq  .default    ; handles error

.L1: ; &
.L2: ; '
.L3: ; (
.L4: ; )
.L5: ; *
.L6: ; +
.L7: ; ,
.L8: ; -
.L9: ; .
.L10: ; /
.L11: ; 0
.L12: ; 1
.L13: ; 2
.L14: ; 3
.L15: ; 4
.L16: ; 5
.L17: ; 6
.L18: ; 7
.L19: ; 8
.L20: ; 9
.L21: ; :
.L22: ; ;
.L23: ; <
.L24: ; =
.L25: ; >
.L26: ; ?
.L27: ; @
.L28: ; A
.L29: ; B
.L30: ; C
.L31: ; D
.L32: ; E
.L33: ; F
.L34: ; G
.L35: ; H
.L36: ; I
.L37: ; J
.L38: ; K
.L39: ; L
.L40: ; M
.L41: ; N
.L42: ; O
.L43: ; P
.L44: ; Q
.L45: ; R
.L46: ; S
.L47: ; T
.L48: ; U
.L49: ; V
.L50: ; W
.L51: ; X
.L52: ; Y
.L53: ; Z
.L54: ; [
.L55: ; \
.L56: ; ]
.L57: ; ^
.L58: ; _
.L59: ; `
.L60: ; a
.L64: ; e
.L65: ; f
.L66: ; g
.L67: ; h
.L68: ; i
.L69: ; j
.L70: ; k
.L71: ; l
.L72: ; m
.L73: ; n
.L75: ; p
.L76: ; q
.L77: ; r
.L79: ; t
.L80: ; u
.L81: ; v
.L82: ; w
.default:
        nop
        nop
        nop
        nop
        ; need something here
        jmp .func_end

.case_prcnt:
        push '%'                ; param - char '%'
        call putchar_cdecl
        add sp, 0x08            ; pop param

        jmp .func_end

.case_b:

        jmp .func_end

.case_c:
        push QWORD [rbp + 0x18] ; param - char
        call putchar_cdecl
        add sp, 0x08            ; pop param
        jmp .func_end

.case_d:

        jmp .func_end

.case_o:

        jmp .func_end

.case_s:

        jmp .func_end

.case_x:

        jmp .func_end

.func_end:
        pop rcx                 ; recover
        pop rbx

        pop rbp

        ret

;===========================================================
;
;
; Destr:
;===========================================================
putchar_cdecl:
        push rbp
        mov rbp, rsp

        push rax        ; save
        push rcx
        push rdx
        push rdi
        push rsi

        mov rdi, [rbp + 0x10]           ; curr symb
        call putchar

        pop rsi         ; recover
        pop rdi
        pop rdx
        pop rcx
        pop rax

        pop rbp

        ret

SECTION .data
        fmt:    db "count printf params received = %s", 10, 0
        msg:    db "aloha daun", 10, 0