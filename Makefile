BUILD_DIR=build
LDFLAGS=`pkg-config --libs sdl3`
ARGS=

.PHONY: all clean run

all: $(BUILD_DIR)/sdl-asm

clean:
	rm -rf $(BUILD_DIR)

run: $(BUILD_DIR)/sdl-asm
	./$(BUILD_DIR)/sdl-asm $(ARGS)

$(BUILD_DIR)/main.o: main.s
	mkdir -p $(BUILD_DIR)
	as -o $(BUILD_DIR)/main.o main.s

$(BUILD_DIR)/sdl-asm: $(BUILD_DIR)/main.o
	gcc $(LDFLAGS) -o $(BUILD_DIR)/sdl-asm $(BUILD_DIR)/main.o
