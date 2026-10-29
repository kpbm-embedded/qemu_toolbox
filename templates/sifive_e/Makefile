# @NAME@: SiFive FE310 (HiFive1) rv32 firmware: XIP flash + DTIM, QEMU sifive_e
# From `qemu-box new sifive_e @NAME@` (32_10_qemu); clang + ld.lld, no libc, nothing outside this folder.
# Inside the qemu-box environment (qemu-box shell -- make test):
#   make          build $(OUT)/@NAME@.elf (+ .map)
#   make run      run headless on QEMU sifive_e
#   make test     run and check the output / exit status
SHELL   := bash
NAME    := @NAME@
OUT     ?= build
TARGET  := --target=riscv32-unknown-elf -march=rv32imac -mabi=ilp32 -mcmodel=medlow
CFLAGS  ?= -O1 -g3
CFLAGS  += $(TARGET) -ffreestanding -fno-builtin -nostdlib -fno-pic -ffunction-sections -fdata-sections -Wall -Wextra -I.
LDFLAGS := $(TARGET) -nostdlib -fuse-ld=lld -static -T link.ld -Wl,--gc-sections -Wl,-Map=$(OUT)/$(NAME).map
SRCS    := startup.S semihost.c mini.c main.c

all: $(OUT)/$(NAME).elf

$(OUT)/$(NAME).elf: $(SRCS) link.ld $(wildcard *.h)
	mkdir -p $(OUT)
	clang $(CFLAGS) $(LDFLAGS) -o $@ $(SRCS)
	llvm-size $@

run: all
	bash "$${QEMU_BOX_LIB:?run inside qemu-box shell}/run-elf.sh" sifive_e $(OUT)/$(NAME).elf --timeout 20

test: all
	@out=$$(bash "$${QEMU_BOX_LIB:?run inside qemu-box shell}/run-elf.sh" sifive_e $(OUT)/$(NAME).elf --timeout 20 2>&1 | tr -d '\r'); rc=$$?; echo "$$out"; \
	  [ $$rc -eq 0 ] && grep -q '$(NAME): PASS' <<<"$$out" || { echo "FAIL $(NAME) (exit $$rc)"; exit 1; }

.PHONY: all run test
