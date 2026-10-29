# Shared build rules for the qemu-box bare-metal examples (LLVM: clang + ld.lld + llvm-objcopy).
# A Makefile sets NAME, ARCH (cm0|cm3|cm4|rv32|rv64|a64), LDS, SRCS and OUT, then includes this file.
# START = own startup file instead of the shared one (e.g. a multi-hart entry).
COMMON := $(dir $(lastword $(MAKEFILE_LIST)))
OWN_START := $(START)
CC      := clang
OBJCOPY := llvm-objcopy
SIZE    := llvm-size

ifeq ($(ARCH),cm0)
  TARGET := --target=thumbv6m-none-eabi -mcpu=cortex-m0 -mthumb -mfloat-abi=soft
  START  := $(COMMON)cortexm_start.c
else ifeq ($(ARCH),cm4)
  TARGET := --target=thumbv7em-none-eabi -mcpu=cortex-m4 -mthumb -mfloat-abi=soft
  START  := $(COMMON)cortexm_start.c
else ifeq ($(ARCH),cm3)
  TARGET := --target=thumbv7m-none-eabi -mcpu=cortex-m3 -mthumb -mfloat-abi=soft
  START  := $(COMMON)cortexm_start.c
else ifeq ($(ARCH),rv32)
  TARGET := --target=riscv32-unknown-elf -march=rv32imac -mabi=ilp32 -mcmodel=medlow
  START  := $(COMMON)riscv_start.S
else ifeq ($(ARCH),rv64)
  TARGET := --target=riscv64-unknown-elf -march=rv64imac -mabi=lp64 -mcmodel=medany
  START  := $(COMMON)riscv_start.S
else ifeq ($(ARCH),a64)
  TARGET := --target=aarch64-none-elf -mcpu=cortex-a53 -mgeneral-regs-only
  START  := $(COMMON)aarch64_start.S
else
  $(error ARCH must be cm0, cm3, cm4, rv32, rv64 or a64)
endif
ifneq ($(OWN_START),)
  START := $(OWN_START)
endif

CFLAGS  ?= -O1 -g3
CFLAGS  += $(TARGET) -ffreestanding -fno-builtin -nostdlib -fno-pic -ffunction-sections -fdata-sections \
           -Wall -Wextra -I$(COMMON) $(DEFS)
LDFLAGS += $(TARGET) -nostdlib -fuse-ld=lld -static -L$(COMMON)ld -T $(LDS) -Wl,--gc-sections -Wl,-Map=$(OUT)/$(NAME).map

ALL_SRCS := $(START) $(COMMON)semihost.c $(COMMON)mini.c $(SRCS)
ELF := $(OUT)/$(NAME).elf

all: $(ELF) $(OUT)/$(NAME).bin

$(ELF): $(ALL_SRCS) $(LDS) $(wildcard $(COMMON)*.h) | $(OUT)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(ALL_SRCS)
	$(SIZE) $@

$(OUT)/$(NAME).bin: $(ELF)
	$(OBJCOPY) -O binary $< $@

$(OUT):
	mkdir -p $@

.PHONY: all
