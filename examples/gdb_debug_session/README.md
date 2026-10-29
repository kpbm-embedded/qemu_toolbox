# gdb_debug_session

QEMU's gdbstub (`-S -gdb tcp:127.0.0.1:PORT`, via `run-elf.sh --gdb=PORT`) driven by **lldb**
in batch mode (`session.lldb`): break at `main`, read the global `counter` (7), step over
`bump()` twice (17, 27), print `pc`, continue to the semihosting exit.

lldb is used because conda-forge's gdb is built for the host target only; lldb speaks the gdb
remote protocol and knows Arm and RISC-V. Interactive use:

    ../../qemu-box run-elf mps2-an386 build/debugme.elf --gdb=1234 &
    ../../qemu-box gdb -o 'target create --arch thumbv7em-none-eabi build/debugme.elf' -o 'gdb-remote 1234'

Any other gdb (e.g. arm-none-eabi-gdb) works the same: `target remote :1234`.
