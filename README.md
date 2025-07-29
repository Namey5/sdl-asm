# sdl-asm
A simple SDL3 app/bootstrapper targeting Linux, written entirely in x64 assembly using the GNU assembler + GCC.

Currently this just creates a window, sets some state and runs a simple event loop, clearing the window and drawing a centred rectangle using `SDL_Renderer`:

<img width="643" height="519" alt="window with blue rectangle" src="https://github.com/user-attachments/assets/c26b291f-7e8b-482e-911e-7177accfee89" />

## building
Here's what I used in testing:

| Dependency | Version |
| ---------- | ------- |
| GNU Make   | 4.4.1   |
| GCC        | 15.1.1  |
| pkg-config | 2.5.1   |
| SDL        | 3.2.18  |

```bash
cd sdl-asm

make
./build/sdl-asm

# Alternatively:
make run
```

You might be able to get this working on Windows using MinGW, but that was outside the scope of this project.

## why?
Mostly a learning excercise for myself - this is in no way practical/faster than what a modern optimising compiler would output, 
but if you wanted to make a simple application in assembly this is a nice template.
