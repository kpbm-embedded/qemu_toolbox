# @NAME@: STM32F4 (BlackPill-class) firmware with a USART driver module, QEMU netduinoplus2
# From `qemu-box new stm32f4_usart @NAME@` (32_10_qemu); clang + ld.lld, no libc, nothing outside this folder.
# Inside the qemu-box environment (qemu-box shell -- make test):
#   make          build $(OUT)/@NAME@.elf (+ .map)
#   make run      run headless on QEMU netduinoplus2
#   make test     run and check the output / exit status
SHELL   := bash
NAME    := @NAME@
OUT     ?= build
TARGET  := --target=thumbv7em-none-eabi -mcpu=cortex-m4 -mthumb -mfloat-abi=soft
CFLAGS  ?= -O1 -g3
CFLAGS  += $(TARGET) -ffreestanding -fno-builtin -nostdlib -fno-pic -ffunction-sections -fdata-sections -Wall -Wextra -I.
LDFLAGS := $(TARGET) -nostdlib -fuse-ld=lld -static -T link.ld -Wl,--gc-sections -Wl,-Map=$(OUT)/$(NAME).map
SRCS    := startup.c semihost.c mini.c main.c uart.c

all: $(OUT)/$(NAME).elf

$(OUT)/$(NAME).elf: $(SRCS) link.ld $(wildcard *.h)
	mkdir -p $(OUT)
	clang $(CFLAGS) $(LDFLAGS) -o $@ $(SRCS)
	llvm-size $@

run: all
	bash "$${QEMU_BOX_LIB:?run inside qemu-box shell}/run-elf.sh" netduinoplus2 $(OUT)/$(NAME).elf --timeout 20

test: all
	@out=$$(bash "$${QEMU_BOX_LIB:?run inside qemu-box shell}/run-elf.sh" netduinoplus2 $(OUT)/$(NAME).elf --timeout 20 2>&1 | tr -d '\r'); rc=$$?; echo "$$out"; \
	  [ $$rc -eq 0 ] && grep -q '$(NAME): PASS' <<<"$$out" || { echo "FAIL $(NAME) (exit $$rc)"; exit 1; }

.PHONY: all run test
