# @NAME@: Cortex-M4 target + scripted lldb session over QEMU's gdbstub (make debug)
# From `qemu-box new gdb_session @NAME@` (32_10_qemu); clang + ld.lld, no libc, nothing outside this folder.
# Inside the qemu-box environment (qemu-box shell -- make test):
#   make          build $(OUT)/@NAME@.elf (+ .map)
#   make run      run headless on QEMU mps2-an386
#   make debug    QEMU halted with its gdbstub + lldb running session.lldb
#   make test     debug session + checks
SHELL   := bash
NAME    := @NAME@
OUT     ?= build
TARGET  := --target=thumbv7em-none-eabi -mcpu=cortex-m4 -mthumb -mfloat-abi=soft
CFLAGS  ?= -O0 -g3
CFLAGS  += $(TARGET) -ffreestanding -fno-builtin -nostdlib -fno-pic -ffunction-sections -fdata-sections -Wall -Wextra -I.
LDFLAGS := $(TARGET) -nostdlib -fuse-ld=lld -static -T link.ld -Wl,--gc-sections -Wl,-Map=$(OUT)/$(NAME).map
SRCS    := startup.c semihost.c mini.c main.c

all: $(OUT)/$(NAME).elf

$(OUT)/$(NAME).elf: $(SRCS) link.ld $(wildcard *.h)
	mkdir -p $(OUT)
	clang $(CFLAGS) $(LDFLAGS) -o $@ $(SRCS)
	llvm-size $@

run: all
	bash "$${QEMU_BOX_LIB:?run inside qemu-box shell}/run-elf.sh" mps2-an386 $(OUT)/$(NAME).elf --timeout 20

debug: all
	@port=$$(python -c 'import socket; s = socket.socket(); s.bind(("127.0.0.1", 0)); print(s.getsockname()[1])'); \
	bash "$${QEMU_BOX_LIB:?run inside qemu-box shell}/run-elf.sh" mps2-an386 $(OUT)/$(NAME).elf --gdb=$$port --timeout 60 >$(OUT)/qemu.log 2>&1 & qpid=$$!; \
	for i in $$(seq 1 50); do (exec 3<>/dev/tcp/127.0.0.1/$$port) 2>/dev/null && break; sleep 0.2; done; \
	lldb -b -o "target create --arch thumbv7em-none-eabi $(OUT)/$(NAME).elf" -o "gdb-remote 127.0.0.1:$$port" -s session.lldb 2>&1 | tee $(OUT)/lldb.log; \
	wait $$qpid; echo "qemu exit status: $$?"; cat $(OUT)/qemu.log

test: all
	@$(MAKE) -s debug >$(OUT)/debug.log 2>&1; cat $(OUT)/debug.log; \
	  grep -q 's = 3' $(OUT)/debug.log && grep -q 'frame #1: .*step_machine' $(OUT)/debug.log && grep -q 'qemu exit status: 0' $(OUT)/debug.log \
	  && grep -q '$(NAME): PASS' $(OUT)/debug.log || { echo "FAIL $(NAME) debug session"; exit 1; }

.PHONY: all run debug test
