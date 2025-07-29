.intel_syntax noprefix

.section .rodata

.align 16
.half:
    .float 0.5, 0.5, 0.5, 0.5

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
.window_min_size:
    .int 640, 480

.section .data

.window_size:
    .int 1280, 720
.clear_color:
    .byte 255, 245, 235, 255

.align 16
.draw_rect:
    .float 0.0, 0.0, 256.0, 256.0
.rect_color:
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
    /* SDL_Event is a union padded to 128 bytes, so can zero using 16 u64's: */
    mov rcx, 16
    lea rdi, QWORD PTR [rbp-160]
    rep stosq

    /* Print number of launch args followed by args list: */
    xor eax, eax
    mov rdi, OFFSET .print_launch_args_1
    mov esi, DWORD PTR [rbp-12]
    call printf

    xor r12d, r12d
    mov r13d, DWORD PTR [rbp-12]
    mov r14, QWORD PTR [rbp-8]
    print_launch_args:
        cmp r12d, r13d
        jge init_sdl

        xor eax, eax
        mov rdi, OFFSET .print_launch_args_2
        mov rsi, QWORD PTR [r14+r12*8]
        call printf

        inc r12d
        jmp print_launch_args

init_sdl:
    /* bool SDL_Init(SDL_InitFlags flags) */
    mov edi, DWORD PTR [.SDL_INIT_VIDEO]
    call SDL_Init
    test eax, eax
    jnz create_window
    /* All SDL calls use the same error handling: */
    call SDL_GetError
    mov rsi, rax
    xor eax, eax
    mov rdi, OFFSET .sdl_init_error
    call printf
    jmp cleanup_sdl

create_window:
    /* SDL_Window* SDL_CreateWindow(const char* title, int width, int height, SDL_WindowFlags flags) */
    mov rdi, OFFSET .window_title
    mov esi, DWORD PTR [.window_size+0]
    mov edx, DWORD PTR [.window_size+4]
    mov rcx, QWORD PTR [.SDL_WINDOW_RESIZABLE]
    call SDL_CreateWindow
    mov QWORD PTR [rbp-24], rax
    test rax, rax
    jnz set_window_properties

    call SDL_GetError
    mov rsi, rax
    xor eax, eax
    mov rdi, OFFSET .create_window_error
    call printf
    jmp cleanup_sdl

set_window_properties:
    /* bool SDL_SetWindowMinimumSize(SDL_Window* window, int width, int height) */
    mov rdi, QWORD PTR [rbp-24]
    mov esi, DWORD PTR [.window_min_size+0]
    mov edx, DWORD PTR [.window_min_size+4]
    call SDL_SetWindowMinimumSize

create_renderer:
    /* SDL_CreateRenderer(SDL_Window* window, const char* name) */
    mov rdi, QWORD PTR [rbp-24]
    xor esi, esi
    call SDL_CreateRenderer
    mov QWORD PTR [rbp-32], rax
    test rax, rax
    jnz main_loop

    call SDL_GetError
    mov rsi, rax
    xor eax, eax
    mov rdi, OFFSET .create_renderer_error
    call printf
    jmp cleanup_window

    main_loop:
        /* bool SDL_PollEvent(SDL_Event* event) */
        lea rdi, DWORD PTR [rbp-160]
        call SDL_PollEvent
        test eax, eax
        jz main_tick

        /* Flag should_quit if the user has requested it (i.e. closed the window). */
        mov eax, DWORD PTR [.SDL_EVENT_QUIT]
        cmp DWORD PTR [rbp-160], eax
        sete al
        movzx eax, al
        or DWORD PTR [rbp-16], eax

        /* Completely flush SDL events before running next tick. */
        jmp main_loop
    main_tick:
        /* bool SDL_GetWindowSizeInPixels(SDL_Window* window, int* w, int* h) */
        mov rdi, QWORD PTR [rbp-24]
        lea rsi, DWORD PTR [.window_size+0]
        lea rdx, DWORD PTR [.window_size+4]
        call SDL_GetWindowSizeInPixels

        /* bool SDL_SetRenderDrawColor(SDL_Renderer* renderer, u8 r, u8 g, u8 b, u8 a) */
        mov rdi, QWORD PTR [rbp-32]
        mov sil, BYTE PTR [.clear_color+0]
        mov dl, BYTE PTR [.clear_color+1]
        mov cl, BYTE PTR [.clear_color+2]
        mov r8b, BYTE PTR [.clear_color+3]
        call SDL_SetRenderDrawColor
        /* bool SDL_RenderClear(SDL_Renderer* renderer) */
        mov rdi, QWORD PTR [rbp-32]
        call SDL_RenderClear

        /* Move draw_rect to the middle of the screen (also need to offset by rect size). */
        movq xmm0, QWORD PTR [.window_size]
        cvtdq2ps xmm0, xmm0
        movq xmm1, QWORD PTR [.draw_rect+8]
        subps xmm0, xmm1
        mulps xmm0, XMMWORD PTR [.half]
        movlps QWORD PTR [.draw_rect], xmm0

        /* bool SDL_SetRenderDrawColor(SDL_Renderer* renderer, u8 r, u8 g, u8 b, u8 a) */
        mov rdi, QWORD PTR [rbp-32]
        mov sil, BYTE PTR [.rect_color+0]
        mov dl, BYTE PTR [.rect_color+1]
        mov cl, BYTE PTR [.rect_color+2]
        mov r8b, BYTE PTR [.rect_color+3]
        call SDL_SetRenderDrawColor
        /* bool SDL_RenderFillRect(SDL_FRect* rect) */
        mov rdi, QWORD PTR [rbp-32]
        lea rsi, XMMWORD PTR [.draw_rect]
        call SDL_RenderFillRect

        /* bool SDL_RenderPresent(SDL_Renderer* renderer) */
        mov rdi, QWORD PTR [rbp-32]
        call SDL_RenderPresent

        /* Keep going until the user closes the window. */
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
