    # @NAME@

    On-target unit tests: `@NAME@_lib.c` is the code under test, `main.c` the tests, `unity_mini.*` a tiny
runner (CHECK/CHECK_EQ with file:line). Output via semihosting; failure count = exit status.

    From `qemu-box new unit_tests_cm4 @NAME@` (32_10_qemu). Freestanding C (no libc), clang + ld.lld; every file it
    needs is in this folder.

        qemu-box shell -- make test      # build, run headless on `mps2-an386`, check the output
        qemu-box shell -- make run       # just run
        qemu-box run-elf mps2-an386 build/@NAME@.elf --gdb=1234   # halted, gdbstub on :1234

Point `SRCS` at your firmware's portable modules to test them with the board's compiler and ABI.
