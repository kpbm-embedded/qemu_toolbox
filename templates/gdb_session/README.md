    # @NAME@

    A target plus a scripted debugger session: `make debug` starts QEMU halted with its gdbstub on a free
port and runs `session.lldb` in lldb (conditional breakpoint, variables, backtrace, expression).

    From `qemu-box new gdb_session @NAME@` (32_10_qemu). Freestanding C (no libc), clang + ld.lld; every file it
    needs is in this folder.

        qemu-box shell -- make test      # build, run headless on `mps2-an386`, check the output
        qemu-box shell -- make run       # just run
        qemu-box run-elf mps2-an386 build/@NAME@.elf --gdb=1234   # halted, gdbstub on :1234

Interactive: `qemu-box run-elf mps2-an386 build/@NAME@.elf --gdb=1234` and in a second shell
`qemu-box gdb build/@NAME@.elf -o 'gdb-remote 1234'` (or `arm-none-eabi-gdb`, `target remote :1234`).
