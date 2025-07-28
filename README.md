# sdl-asm
A simple SDL3 app/bootstrapper targeting Linux, written entirely in x64 assembly using the GNU assembler + GCC.

```bash
cd sdl-asm

make
./build/sdl-asm

# Alternatively:
make run
```

You might be able to get this working on Windows using MinGW, but that was outside the scope of this project.

Currently this just creates a window, sets some state and runs a simple event loop, clearing the window using `SDL_Renderer`:

<img width="1285" height="758" alt="wow, a blue window" src="https://github.com/user-attachments/assets/8f08d0b8-a02c-452a-92f9-42d2c9f43bce" />

## why?
Mostly a learning excercise for myself - this is in no way practical/faster than what a modern optimising compiler would output, 
but if you wanted to make a simple application in assembly this is a nice template.
