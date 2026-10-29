    # @NAME@

    Host-side control of a running guest over QMP (QEMU's JSON control socket): `qmp_client.py` pauses the
guest, reads a variable at its ELF symbol address with `pmemsave`, resumes and quits.

    From `qemu-box new qmp_script @NAME@` (32_10_qemu). Freestanding C (no libc), clang + ld.lld; every file it
    needs is in this folder.

        qemu-box shell -- make test      # build, run headless on `virt`, check the output
        qemu-box shell -- make run       # just run
        qemu-box run-elf virt build/@NAME@.elf --gdb=1234   # halted, gdbstub on :1234

Use it for test harnesses that inject state, take memory snapshots or reset the guest between cases.
