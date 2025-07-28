.intel_syntax noprefix

.section .data

.SDL_INIT_VIDEO:
    .int 0x00000020
.SDL_WINDOW_RESIZABLE:
    .quad 0x0000000000000020
.SDL_EVENT_QUIT:
    .int 0x100

.print_launch_args_1:
    .string "Running with %d arg(s):\n"
.print_launch_args_2:
    .string "| %s\n"

.sdl_init_error:
    .string "SDL_Init() failed: %s\n"
.create_window_error:
    .string "SDL_CreateWindow() failed: %s\n"
.create_renderer_error:
    .string "SDL_CreateRenderer() failed: %s\n"

.window_title:
    .string "sdl-asm"
.window_width:
    .int 1280
.window_height:
    .int 720
.clear_color:
    .byte 63, 127, 255, 255

.section .text

.global main
main:
    push rbp
    mov rbp, rsp
    sub rsp, 160
    xor eax, eax
    /* char** argv */
    mov QWORD PTR [rbp-8], rsi
    /* int argc */
    mov DWORD PTR [rbp-12], edi
    /* int should_quit */
    mov DWORD PTR [rbp-16], eax
    /* SDL_Window* window */
    mov QWORD PTR [rbp-24], rax
    /* SDL_Renderer* renderer */
    mov QWORD PTR [rbp-32], rax
    /* SDL_Event event */
    mov rcx, 16
    lea rdi, QWORD PTR [rbp-160]
    rep stosq

    mov rdi, OFFSET .print_launch_args_1
    mov esi, DWORD PTR [rbp-12]
    call printf

    xor r12d, r12d
    mov r13d, DWORD PTR [rbp-12]
    mov r14, QWORD PTR [rbp-8]
    print_args:
        cmp r12d, r13d
        jge init_sdl

        mov rdi, OFFSET .print_launch_args_2
        mov rsi, QWORD PTR [r14+r12*8]
        call printf

        inc r12d
        jmp print_args

init_sdl:
    mov edi, [.SDL_INIT_VIDEO]
    call SDL_Init
    test eax, eax
    jnz create_window
    call SDL_GetError
    mov rsi, rax
    mov rdi, OFFSET .sdl_init_error
    call printf
    jmp cleanup_sdl

create_window:
    mov rdi, OFFSET .window_title
    mov esi, [.window_width]
    mov edx, [.window_height]
    mov rcx, [.SDL_WINDOW_RESIZABLE]
    call SDL_CreateWindow
    mov QWORD PTR [rbp-24], rax
    test rax, rax
    jnz create_renderer
    call SDL_GetError
    mov rsi, rax
    mov rdi, OFFSET .create_window_error
    call printf
    jmp cleanup_sdl

create_renderer:
    mov rdi, QWORD PTR [rbp-24]
    xor esi, esi
    call SDL_CreateRenderer
    mov QWORD PTR [rbp-32], rax
    test rax, rax
    jnz main_loop
    call SDL_GetError
    mov rsi, rax
    mov rdi, OFFSET .create_renderer_error
    call printf
    jmp cleanup_window

    main_loop:
        lea rdi, DWORD PTR [rbp-160]
        call SDL_PollEvent
        test eax, eax
        jz main_tick

        mov eax, [.SDL_EVENT_QUIT]
        cmp DWORD PTR [rbp-160], eax
        sete al
        movzx eax, al
        or DWORD PTR [rbp-16], eax

        jmp main_loop
    main_tick:
        mov rdi, QWORD PTR [rbp-32]
        mov sil, [.clear_color+0]
        mov dl, [.clear_color+1]
        mov cl, [.clear_color+2]
        mov r8b, [.clear_color+3]
        call SDL_SetRenderDrawColor

        mov rdi, QWORD PTR [rbp-32]
        call SDL_RenderClear

        mov rdi, QWORD PTR [rbp-32]
        call SDL_RenderPresent

        cmp DWORD PTR [rbp-16], 0
        jz main_loop

cleanup_renderer:
    mov rdi, QWORD PTR [rbp-32]
    call SDL_DestroyRenderer

cleanup_window:
    mov rdi, QWORD PTR [rbp-24]
    call SDL_DestroyWindow

cleanup_sdl:
    call SDL_Quit

    mov eax, 0
    leave
    ret
