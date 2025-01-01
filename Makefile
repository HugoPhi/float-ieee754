# 目标名称
TARGET = ./bin/main

# 编译器
CC = gcc_riscv64

# 源文件
SRC = main.c \
      ./src/asm_riscv/add.s \
      ./src/asm_riscv/mult.s \
      ./src/asm_riscv/divi.s \
      ./src/c/interactor.c

# 输出目录
OUT_DIR = ./bin

all: $(TARGET)

$(TARGET): $(SRC)
	mkdir -p $(OUT_DIR)
	$(CC) $(SRC) -o $(TARGET)

clean:
	rm -rf $(OUT_DIR)

.PHONY: all clean
