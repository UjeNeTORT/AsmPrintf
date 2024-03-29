SECTION .rodata
jmptbl:
                        dq case_prcnt ; %
times ('b' - '%' - 1)   dq case_dflt
                        dq case_b     ; b
                        dq case_c     ; c
                        dq case_d     ; d

times ('o' - 'd' - 1)   dq case_dflt
 
                        dq case_o      ; o
 
times ('s' - 'o' - 1)   dq case_dflt
 
                        dq case_s     ; s
 
times ('x' - 's' - 1)   dq case_dflt
 
                        dq case_x     ; x
 
                        dq case_dflt  ; handles error

SECTION .text
 
global  myprintf
 
;===========================================================
; THIS IS NOT AN ACTUAL FUNCTION BUT A TRAMPOLINE TO
;       SIMULATE CDECL CALL CONVENTION
;
; Destr: -
;===========================================================
; extern int myprintf (const char* fmt_string, params...)
myprintf:

        pop r15                 ; how didnt i notice this by myself???

        push r9
        push r8
        push rcx
        push rdx
        push rsi
        push rdi
 
        call myprintf_cdecl
        
        add rsp, 6 * 0x08

        push r15                ; recover ret address

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
        push r10

        xor r10, r10                    ; r10 = 0 - not used (left it here in case % parameter counts as real one)
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
 
                                        ; value of specifier parameter in stack
        push QWORD [rbp + rcx * 0x08 + 0x18]
        push rbx                        ; specifier symbol
 
        call process_specifier
 
        add  rsp, 2 * 0x08              ; clean stack
 
        cmp BYTE [rbx], '%'             ; <-- FORMER BUG, KEEP AN EYE ON THIS PLACE
        jne .spend_stack_param

        jmp .str_loop_end
 
.spend_stack_param:
        inc rcx                         ; increase number of processed specifiers
        jmp .str_loop_end
 
        jmp .func_end                   ; kinda silly precaution
 
.func_end:
 
        mov rax, rcx                    ; return value

        pop r10                         ; restore
        pop rbx                         
        pop rcx
 
        pop rbp
 
        ret
 
;===========================================================
; Given specifier symbol and its corresponding parameter
;       perform expected interpretation of specifier
; Arguments:
;       arg1 - [rbp + 0x10] - specifier symbol addr
;       arg2 - [rbp + 0x18] - parameter value
;===========================================================
process_specifier:
        push rbp
        mov  rbp, rsp
 
        push rbx                        ; save
        push rcx
 
        mov rbx, [rbp + 0x10]           ; arg1 - spec symbol addr
 
        mov cl, BYTE [rbx]
        xor rbx, rbx
        mov bl, cl
 
        cmp rbx, 'x'                    ; x has the greates ASCII code among all the spec symbs
        ja case_dflt
        cmp rbx, '%'
        jb case_dflt
 
                                        ; % has the least ASCII code among all the spec symbs
        jmp [jmptbl + 8 * (rbx - '%')]   ; perform jumptable jump

L1: ; &
L2: ; '
L3: ; (
L4: ; )
L5: ; *
L6: ; +
L7: ; ,
L8: ; -
L9: ; .
L10: ; /
L11: ; 0
L12: ; 1
L13: ; 2
L14: ; 3
L15: ; 4
L16: ; 5
L17: ; 6
L18: ; 7
L19: ; 8
L20: ; 9
L21: ; :
L22: ; ;
L23: ; <
L24: ; =
L25: ; >
L26: ; ?
L27: ; @
L28: ; A
L29: ; B
L30: ; C
L31: ; D
L32: ; E
L33: ; F
L34: ; G
L35: ; H
L36: ; I
L37: ; J
L38: ; K
L39: ; L
L40: ; M
L41: ; N
L42: ; O
L43: ; P
L44: ; Q
L45: ; R
L46: ; S
L47: ; T
L48: ; U
L49: ; V
L50: ; W
L51: ; X
L52: ; Y
L53: ; Z
L54: ; [
L55: ; \
L56: ; ]
L57: ; ^
L58: ; _
L59: ; `
L60: ; a
L64: ; e
L65: ; f
L66: ; g
L67: ; h
L68: ; i
L69: ; j
L70: ; k
L71: ; l
L72: ; m
L73: ; n
L75: ; p
L76: ; q
L77: ; r
L79: ; t
L80: ; u
L81: ; v
L82: ; w
 
case_dflt:                      ; EXCEPTION
                                ; TODO: ERROR HANDLING
                                ; current behaviour - ignore unknown specifier and its parameter
                                ; THIS PLACE IS SILENT, IT DOES NOT INFORM USER THAT THIS IS AN EXCEPTION
        jmp switch_end
 
case_prcnt:                     ; PERCENT CHARACTER 
        push '%'                ; param - char '%'
        call putchar_cdecl
        add  rsp, 0x08          ; pop param

        jmp switch_end
 
case_b:                         ; BINARY (bufferized)
        push '0'                ; write prefix
        call putchar_cdecl
        add rsp, 0x08

        push 'b'
        call putchar_cdecl
        add rsp, 0x08

        push 2
        push QWORD [rbp + 0x18] ; param - number
        call write_base2
        add  rsp, 0x10          ; pop param

        jmp switch_end
 
case_c:                         ; CHARACTER (BYTE) (bufferized lol)
        push QWORD [rbp + 0x18] ; param - char
        call putchar_cdecl
        add  rsp, 0x08          ; pop param

        jmp switch_end
 
case_d:                         ; DECIMAL (bufferized)
        push QWORD [rbp + 0x18] ; param - number
        call write_dec
        add  rsp, 0x08           ; pop param

        jmp switch_end
 
case_o:                         ; OCTAL (bufferized)
        push '0'                ; write prefix
        call putchar_cdecl
        add rsp, 0x08

        push '0'
        call putchar_cdecl
        add rsp, 0x08

        push 8
        push QWORD [rbp + 0x18] ; param - number
        call write_base2
        add  rsp, 0x10          ; pop param

        jmp switch_end
 
case_s:                         ; DISPLAY STRING (pseudo-bufferized)
        push QWORD [rbp + 0x18] ; param - string ptr
        call puts_cdecl
        add  rsp, 0x08          ; pop param

        jmp switch_end
 
case_x:                         ; HEXADECIMAL (bufferized)
        push '0'                ; write prefix
        call putchar_cdecl
        add rsp, 0x08

        push 'x'
        call putchar_cdecl
        add rsp, 0x08

        push 16
        push QWORD [rbp + 0x18] ; param - number
        call write_base2
        add  rsp, 0x10          ; pop param

        jmp switch_end  
 
switch_end:                     ; END OF THE SWITCH
        pop rcx                 ; recover
        pop rbx
 
        pop rbp
 
        ret

;===========================================================
; Display decimal number 
; Arguments:
;       arg1 - [rbp + 0x10] - number
; Destr: -
;===========================================================
write_dec: 
        push rbp
        mov rbp, rsp

        push rax
        push rcx
        push r10
        push r11
        push r12
        push rdx

        call clear_num_buf      ; buffer stores 0s

        mov rax, [rbp + 0x10]   ; arg1 - number
        xor rcx, rcx
        xor r10, r10            ; r10 stores number of non-significant zeros 

        test eax, eax           ; if number < 0: do фокусы блять
        jns .nextdigit

        neg eax                 ; АХХАХАХАХ НЕГР ААЗАЗАЗЗАЗААы
        
                                ; display '-'
        push '-'
        call putchar_cdecl
        add rsp, 0x08
; ------------------------------------------
.nextdigit:                     ; put reversed representation of the number in buffer
        mov edx, eax

        push rbx                ; save 

        mov ebx, 10             ; divide by 10
        xor edx, edx
        div ebx

        pop rbx                 ; recover

        cmp edx, 0              
        je .put_digit

        xor r10, r10
        dec r10 

.put_digit:
        add edx, '0'
        mov BYTE [num_buf + rcx], dl

.loop_end:

        inc r10
        inc rcx
        
        cmp rcx, NUMBER_BUF_SIZE
        jne .nextdigit
; ------------------------------------------

; write on screen (no prefix)
        cmp r10, NUMBER_BUF_SIZE                ; trunctate unsignificant zeros
        jne .not_zero

        push '0'                                ; in case number is zero - write only zero
        call putchar_cdecl
        add rsp, 0x08

        jmp .func_end

.not_zero:

        mov rcx, NUMBER_BUF_SIZE
        sub rcx, r10

.display_digit:
        lea r11, [num_buf + rcx - 1]
        
        xor rax, rax
        mov al, BYTE [r11]

        push rax
        call putchar_cdecl
        add rsp, 0x08

        loop .display_digit

.func_end:

        pop rdx 
        pop r12
        pop r11
        pop r10
        pop rcx
        pop rax

        pop rbp

        ret

;===========================================================
; Display number in base 2 number system 
; Arguments:
;       arg1 - [rbp + 0x10] - number
;       arg2 - [rbp + 0x18] - mumber system base
; Destr: 
;===========================================================
write_base2: 
        push rbp
        mov rbp, rsp

        push rax
        push rcx
        push r10
        push r11
        push r12
        push rdx

        call clear_num_buf      ; buffer stores 0s

        mov rax, [rbp + 0x10]   ; arg1 - number
        xor rcx, rcx
        xor r10, r10            ; r10 stores number of non-significant zeros 

; ------------------------------------------
.nextdigit:                     ; put reversed representation of the number in buffer
        mov rdx, rax
        
        push rbx                ; save 

        mov rbx, [rbp + 0x18]   ; divide by 10
        xor rdx, rdx
        div rbx

        pop rbx                 ; recover

        cmp rdx, 0
        je .put_digit

        xor r10, r10
        dec r10 

.put_digit:
        cmp rdx, 10
        jae .digit_is_letter

        add rdx, '0'
        jmp .put_digit_end

.digit_is_letter:
        add rdx, 'A' - 10
        jmp .put_digit_end

.put_digit_end:
        mov BYTE [num_buf + rcx], dl

.loop_end:

        inc r10
        inc rcx
        
        cmp rcx, NUMBER_BUF_SIZE
        jne .nextdigit
; ------------------------------------------

; write on screen


        cmp r10, NUMBER_BUF_SIZE
        jne .not_zero

        push '0'
        call putchar_cdecl
        add rsp, 0x08

        jmp .func_end
        
.not_zero:

        mov rcx, NUMBER_BUF_SIZE
        sub rcx, r10

.display_digit:
        lea r11, [num_buf + rcx - 1]
        
        xor rax, rax
        mov al, BYTE [r11]

        push rax
        call putchar_cdecl
        add rsp, 0x08

        loop .display_digit

.func_end:

        pop rdx
        pop r12
        pop r11
        pop r10
        pop rcx
        pop rax

        pop rbp

        ret

;===========================================================
; Display null-terminated string of bytes  
; Arguments:
;       arg1 - [rbp + 0x10] - address of null-terminated string  
;
; Destr: r11 - probably (due to syscall)
;===========================================================
puts_cdecl:
        push rbp
        mov rbp, rsp
 
        push rcx                        ; protect from syscall
        push r11
 
        push rax
        push rdi
        push rsi
        push rbx
        push rdx
 
        mov rbx, [rbp + 0x10]
 
.next:
        mov rax, 0x01                   ; write64 (rdi, rsi, rax)
        mov rdi, 0x01                   ; stdout fd
        mov rsi, rbx                    ; curr string pos
        mov rdx, 0x01                   ; display only 1 char
        syscall
        inc rbx
 
        cmp BYTE [rbx], 0
        jne .next
 
        pop rdx
        pop rbx
        pop rsi
        pop rdi
        pop rax
        
        pop r11
        pop rcx
 
        pop rbp
 
        ret
 
;===========================================================
; Display char 
; Arguments:
;       arg1 - [rbp + 0x10] - char value
; Destr: [char_buf], r11 - probably (due to syscall)
;===========================================================
putchar_cdecl:
        push rbp
        mov rbp, rsp

        push rcx                        ; protect from syscall
        push r11

        push rax                        ; save regs
        push rdi
        push rsi
        push rbx
        push rdx
 
        mov rbx, [rbp + 0x10]
        mov BYTE [char_buf], bl         ; fill buffer with char
 
        mov rax, 0x01                   ; write64 (rdi, rsi, rax)
        mov rdi, 0x01                   ; stdout fd
        mov rsi, char_buf               ; curr string pos
        mov rdx, 0x01                   ; display only 1 char
        syscall
 
        pop rdx                         ; restore
        pop rbx
        pop rsi
        pop rdi
        pop rax
        
        pop r11
        pop rcx
 
        pop rbp                         ; here was a terrible bug i ve looked for for 2 hours (pop rsp) :((((
 
        ret

clear_num_buf:

        push rcx
        mov rcx, NUMBER_BUF_SIZE
.next:
        mov BYTE [num_buf + rcx - 1], 0
        loop .next

        pop rcx

        ret 

SECTION .data
        char_buf: db 0x00                               ; buffer for storage of char

        NUMBER_BUF_SIZE equ 64
        num_buf: times (NUMBER_BUF_SIZE) db 0x00        ; buffer for storage of number representation