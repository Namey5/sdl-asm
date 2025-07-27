.intel_syntax noprefix

.section .data

.print_launch_args_1:
    .string "Running with %d arg(s):\n"
.print_launch_args_2:
    .string "| %s\n"

.section .text

.global main
main:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    /* char** argv */
    mov QWORD PTR [rbp-8], rsi
    /* int argc */
    mov DWORD PTR [rbp-12], edi

    mov rdi, OFFSET .print_launch_args_1
    mov esi, DWORD PTR [rbp-12]
    call printf

    mov r12d, 0
print_args:
    cmp r12d, DWORD PTR [rbp-12]
    jge print_args_end

    mov rdi, OFFSET .print_launch_args_2
    mov rsi, QWORD PTR [rbp-8]
    mov rsi, QWORD PTR [rsi+r12*8]
    call printf

    inc r12d
    jmp print_args
print_args_end:

    mov eax, 0
    leave
    ret
