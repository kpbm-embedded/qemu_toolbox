# @NAME@: bare-metal Cortex-M4 firmware for QEMU mps2-an386, built with clang + ld.lld (no libc).
# Build inside the qemu-box environment:  qemu-box shell -- make   (or: qemu-box run make)
# Run:                                     qemu-box run-elf mps2-an386 build/@NAME@.elf
# Debug:                                   qemu-box run-elf mps2-an386 build/@NAME@.elf --gdb=1234
NAME    := @NAME@
OUT     ?= build
TARGET  := --target=thumbv7em-none-eabi -mcpu=cortex-m4 -mthumb -mfloat-abi=soft
CFLAGS  ?= -O1 -g3
CFLAGS  += $(TARGET) -ffreestanding -fno-builtin -nostdlib -fno-pic -ffunction-sections -fdata-sections -Wall -Wextra
LDFLAGS := $(TARGET) -nostdlib -fuse-ld=lld -static -T link.ld -Wl,--gc-sections -Wl,-Map=$(OUT)/$(NAME).map
SRCS    := startup.c semihost.c mini.c main.c

all: $(OUT)/$(NAME).elf

$(OUT)/$(NAME).elf: $(SRCS) link.ld $(wildcard *.h)
	mkdir -p $(OUT)
	clang $(CFLAGS) $(LDFLAGS) -o $@ $(SRCS)
	llvm-size $@

run: all
	bash "$${QEMU_BOX_LIB:?run inside qemu-box shell}/run-elf.sh" mps2-an386 $(OUT)/$(NAME).elf

.PHONY: all run
