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

.section .text

.global main
main:
    push rbp
    mov rbp, rsp
    sub rsp, 176
    /* char** argv */
    mov QWORD PTR [rbp-8], rsi
    /* int argc */
    mov DWORD PTR [rbp-12], edi
    /* int result */
    mov DWORD PTR [rbp-16], 0
    /* SDL_Window* window */
    mov QWORD PTR [rbp-24], 0
    /* SDL_Renderer* renderer */
    mov QWORD PTR [rbp-32], 0
    /* SDL_Event event */
    mov DWORD PTR [rbp-160], 0
    /* int should_quit */
    mov DWORD PTR [rbp-164], 0

    mov rdi, OFFSET .print_launch_args_1
    mov esi, DWORD PTR [rbp-12]
    call printf

    mov r12d, 0
    print_args:
        cmp r12d, DWORD PTR [rbp-12]
        jge init_sdl

        mov rdi, OFFSET .print_launch_args_2
        mov rsi, QWORD PTR [rbp-8]
        mov rsi, QWORD PTR [rsi+r12*8]
        call printf

        inc r12d
        jmp print_args

init_sdl:
    mov edi, [.SDL_INIT_VIDEO]
    call SDL_Init
    mov DWORD PTR [rbp-16], eax
    cmp DWORD PTR [rbp-16], 0
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
    cmp QWORD PTR [rbp-24], 0
    jnz create_renderer
    call SDL_GetError
    mov rsi, rax
    mov rdi, OFFSET .create_window_error
    call printf
    jmp cleanup_sdl

create_renderer:
    mov rdi, QWORD PTR [rbp-24]
    mov rsi, 0
    call SDL_CreateRenderer
    mov QWORD PTR [rbp-32], rax
    cmp QWORD PTR [rbp-32], 0
    jnz main_loop
    call SDL_GetError
    mov rsi, rax
    mov rdi, OFFSET .create_renderer_error
    call printf
    jmp cleanup_window

    main_loop:
        lea rdi, DWORD PTR [rbp-160]
        call SDL_PollEvent
        mov DWORD PTR [rbp-16], eax
        cmp DWORD PTR [rbp-16], 0
        jz main_tick

        mov edi, DWORD PTR [rbp-164]
        mov esi, DWORD PTR [rbp-160]
        cmp esi, [.SDL_EVENT_QUIT]
        mov esi, 1
        cmove edi, esi
        mov DWORD PTR [rbp-164], edi

        jmp main_loop
    main_tick:
        mov rdi, QWORD PTR [rbp-32]
        mov sil, 63
        mov dl, 127
        mov cl, 255
        mov r8b, 255
        call SDL_SetRenderDrawColor
        mov DWORD PTR [rbp-16], eax

        mov rdi, QWORD PTR [rbp-32]
        call SDL_RenderClear
        mov DWORD PTR [rbp-16], eax

        mov rdi, QWORD PTR [rbp-32]
        call SDL_RenderPresent
        mov DWORD PTR [rbp-16], eax

        cmp DWORD PTR [rbp-164], 0
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
