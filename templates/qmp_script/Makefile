# @NAME@: RISC-V guest controlled over QMP by a Python script (QEMU virt)
# From `qemu-box new qmp_script @NAME@` (32_10_qemu); clang + ld.lld, no libc, nothing outside this folder.
# Inside the qemu-box environment (qemu-box shell -- make test):
#   make          build $(OUT)/@NAME@.elf (+ .map)
#   make run      run headless on QEMU virt
#   make test     run with a QMP socket, qmp_client.py pauses/reads/resumes/quits
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
	bash "$${QEMU_BOX_LIB:?run inside qemu-box shell}/run-elf.sh" virt $(OUT)/$(NAME).elf --timeout 20

test: all
	@sock=$$(mktemp -u "$${TMPDIR:-/tmp}/qmp.XXXXXX"); \
	bash "$${QEMU_BOX_LIB:?run inside qemu-box shell}/run-elf.sh" virt $(OUT)/$(NAME).elf --timeout 60 -- -qmp unix:$$sock,server=on,wait=off >$(OUT)/qemu.log 2>&1 & qpid=$$!; \
	addr=$$(llvm-nm $(OUT)/$(NAME).elf | awk '$$3 == "counter" { print $$1 }'); \
	python qmp_client.py $$sock $$addr $(OUT); rc=$$?; [ $$rc -eq 0 ] || kill $$qpid 2>/dev/null; wait $$qpid; \
	[ -S $$sock ] && rm -f $$sock; cat $(OUT)/qemu.log; echo; [ $$rc -eq 0 ] || { echo "FAIL $(NAME)"; exit 1; }

.PHONY: all run test
