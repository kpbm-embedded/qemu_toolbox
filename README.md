# 32_10_qemu - QEMU for embedded targets

QEMU system emulators for Arm (Cortex-M, Cortex-A) and RISC-V, plus an LLVM bare-metal toolchain, headless runners and a
scripted debugger session. Use it for fast unit tests of bare-metal code (semihosting exit status), quick gdb-style debugging,
and booting Linux on supported machines. The launcher is called **`qemu-box`** so it never shadows `qemu-system-*`. Everything
sits in this folder and works the same on any OS: no sudo, no system packages.

Status: **ready** (doctor 19 ok, examples 18/18, templates 13/13, 2026-10-29). Launcher: `./qemu-box`.

## What's included

| Part | Version | Notes |
|---|---|---|
| QEMU `qemu-system-arm`, `-aarch64` | xPack qemu-arm 9.2.4-1 | sha256 from xPack `.sha` files; 392 MB |
| QEMU `qemu-system-riscv32`, `-riscv64` | xPack qemu-riscv 9.2.4-1 | 365 MB |
| clang, ld.lld, llvm-objcopy/size/readelf | LLVM 22.1.8 (conda-forge) | one toolchain for Arm (`thumbv7m/v7em-none-eabi`) and RISC-V (`riscv32/64-unknown-elf`) |
| lldb | 22.1.8 (conda-forge) | the debugger (gdb remote client); no gdb is bundled because conda-forge's gdb is host-only |
| make, python | GNU make 4.4.1, Python 3.12 | conda-forge |
| dtc | 1.7.2 (conda-forge, Unix only) | decompiles the device trees QEMU generates (`-M virt,dumpdtb=x.dtb`) |
| pixi | 0.81.0 | sha256 pinned in `qemu-box` |

xPack QEMU is upstream QEMU 9.2.4 as portable builds for Linux x64/arm64, macOS x64/arm64 and Windows x64 (all five pinned in
`config/pins.tsv`). QEMU 10.x exists upstream, but these builds run unchanged everywhere. LLVM replaces xPack Arm GCC (1.1 GB) plus
RISC-V GCC (1.6 GB) because the examples are freestanding (no libc). Firmware that needs newlib/picolibc builds with the GCC
toolchains of `32_06_renode` or `32_01_mcu`; the ELFs run here unchanged (`run-elf` only reads the ELF).

### QEMU or Renode

| | QEMU (here) | Renode (`32_06_renode`) |
|---|---|---|
| Speed | fast TCG, starts in milliseconds; good for CI via semihosting exit status | slower, deterministic virtual time |
| Debugging | built-in gdbstub (`-S -gdb`), mature | gdb server too |
| Peripherals | thin MCU models (STM32 USART/timers, nRF51 basics; no RCC/GPIO depth) | rich MCU peripheral models, sensors, multi-node, Robot tests |
| Linux boards | good Cortex-A / RISC-V Linux machines (orangepi-pc, virt, sifive_u, raspi) | some (Zynq, K210, HiFive) |

Rule of thumb: algorithm and unit tests plus quick debug sessions here; driver, peripheral and system-level tests in Renode.

## Quick start

```sh
cd "$BOX_QEMU_EMBEDDED"                      # or: cd $BOX/30_39_tools/32_embedded/32_10_qemu
./qemu-box install && ./qemu-box doctor      # pinned pixi + LLVM env + QEMU + example build; binaries, clang/lld/lldb, machines
./qemu-box examples test                     # builds and runs all 18 examples and checks their output
./qemu-box machines arm                      # QEMU machine list (-M help)
./qemu-box run-elf netduinoplus2 fw.elf      # headless run of your ELF (serial on stdio, semihosting on)
```

With the Box shell set up once (`box shell install --apply`), the `qemu-box` shim works from any folder,
and `box test|doctor|status qemu` run this launcher (`box clean qemu` is a dry run until `--apply`).
Standalone (no Box, or `BOX_INTEGRATION=0`), `./qemu-box` keeps its output in this folder.

## Commands

Global option: `--dry-run` / `-n` prints what a command would do. Exit codes: 0 ok, 1 failure, 2 usage error (unknown command or option, or arguments given to `where`, `status`, `doctor`, `bootstrap` or `relocate`), 3 not applicable. `help` ends with this tool's own examples and variables (`tool examples`, `tool environment`).

| Command | What it does | Example |
|---|---|---|
| `bootstrap` | pinned pixi + env + core downloads (sha-checked) | `./qemu-box bootstrap` |
| `install [--no-demos]` | bootstrap + demo downloads + example build | `./qemu-box install` |
| `update [--check\|--env]` | `--check` (default): pins vs newest upstream; `--env`: re-solve pixi env | `./qemu-box update --check` |
| `clean [--all] [--yes]` | move build/log output (`--all`: also install/, .pixi, native/, downloads) to the Trash; dry run unless `--yes` | `./qemu-box --dry-run clean --all` |
| `status`, `where`, `doctor` | versions and sizes, paths, health checks (exit 1 on failure) | `./qemu-box doctor` |
| `shell [-- cmd ...]` | bash with `qemu-system-*`, clang, ld.lld, llvm-objcopy, lldb, make on PATH | `./qemu-box shell -- make run` |
| `run <cmd> [args]` | one command inside the environment | `./qemu-box run clang --version` |
| `machines [arm\|riscv]` | list QEMU machines (`-M help`) of qemu-system-arm/aarch64/riscv32/riscv64 | `./qemu-box machines riscv` |
| `run-elf <machine> <elf> [--gdb[=PORT]] [--timeout S] [--no-semihosting] [-- qemu args]` | headless run (`-nographic`, serial on stdio, semihosting on) | `./qemu-box run-elf mps2-an386 fw.elf --gdb=1234` |
| `gdb [args]` | the env's debugger, lldb 22 (gdb-remote client for QEMU `-gdb`) | `./qemu-box gdb` |
| `qemu <binary> [args]` | any bundled QEMU binary | `./qemu-box qemu qemu-system-arm -M help` |
| `test [--all]` | `tests/test_smoke.sh`; `--all` adds dry-run and examples tests | `./qemu-box test` |
| `new <kind> <name> [--dir D] [--force]` | from `templates/` (13 kinds, see below) | `./qemu-box new cortexm my_fw` |
| `examples list \| run <ex> [args] \| build [ex...] \| test [ex...]` | list, run, build or test examples | `./qemu-box examples run riscv_virt_uart rv64` |
| `native [--print]` | write `native/{native.zsh,native.bash,bin/}` | `./qemu-box native` |
| `relocate` | after moving the folder: re-create the env, rewrite `native/` | `./qemu-box relocate` |
| `pack [--with-cache] [--out F]` | tarball of this folder (without the env) for another machine | `./qemu-box pack` |
| `help`, `-h`, `--help` | command list | `./qemu-box help` |

With `--gdb=PORT` the machine starts halted with the gdbstub on 127.0.0.1:PORT. lldb connects with gdb-remote; any
`arm-none-eabi-gdb` / `riscv-none-elf-gdb` also works with `target remote :PORT`.

## Examples and templates

Examples (`./qemu-box examples test` runs all 18; none needs a board). Shared startup, semihosting and linker scripts are in `examples/common/`.

| Example | Machine | What it shows |
|---|---|---|
| `mps2_semihosting` | `mps2-an386` (Cortex-M4) | output via `SYS_WRITE0`; `main()`'s return value becomes QEMU's exit status |
| `netduinoplus2_usart` | `netduinoplus2` (STM32F405) | USART1 polling driver (same registers as the BlackPill F411), serial on stdio |
| `riscv_virt_uart` | `virt` rv32 + rv64 | M-mode without OpenSBI, NS16550 UART, `misa` decode; one source, two ISAs |
| `sifive_e_uart` | `sifive_e` (FE310, HiFive1) | XIP flash + DTIM `.data` copy, SiFive UART0 |
| `gdb_debug_session` | `mps2-an386` | QEMU gdbstub + lldb batch: break `main`, read a global, step twice, continue to exit |
| `microbit_uart` | `microbit` (nRF51822, Cortex-M0) | UART0 task/event driver (same legacy UART block as the nRF52840), FICR flash size, M0 divide helpers |
| `stm32vldiscovery_usart` | `stm32vldiscovery` (STM32F100, Cortex-M3) | USART1 driver for the STM32F1/BluePill class, SCB CPUID check |
| `cortexm_systick_irq` | `mps2-an386` | SysTick 1 ms interrupts with WFI, an NVIC interrupt pended from software (number from IPSR), weak handlers |
| `cortexm_hardfault` | `mps2-an386` | `udf` escalates to HardFault; the handler prints stacked PC/LR, CFSR, HFSR; the test checks PC against `llvm-nm` |
| `semihosting_file_io` | `mps2-an386` | SYS_OPEN/READ/WRITE/FLEN/CLOCK/TIME: firmware reads `in.txt` and writes `out.txt` on the host |
| `unit_test_runner` | `mps2-an386` | on-target unit tests (ring buffer, CRC-16) with file:line reports; failure count = exit status; an injected failure is checked too |
| `riscv_timer_irq` | `virt` rv32 | CLINT machine-timer interrupts: `mtimecmp`, `mtvec`, `interrupt("machine")` handler, 5 x 10 ms |
| `riscv_smp_harts` | `virt` rv64 `-smp 4` | own multi-hart entry, CLINT software-interrupt wake-up, `amoadd` counter, `amoswap` spinlock |
| `riscv_fdt_walk` | `virt` rv64 | firmware walks the device tree passed in a1 (memory, serial) and prints through the UART it found; compared with `dumpdtb` + `dtc` |
| `aarch64_virt_pl011` | `virt -cpu cortex-a53` | AArch64 bare metal at EL1: PL011, CurrentEL, MIDR_EL1, generic timer, A64 semihosting exit |
| `gdb_watchpoint` | `mps2-an386` | lldb batch: hardware write watchpoint on a global, backtrace to the writer, the caller's argument |
| `qmp_control` | `virt` rv32 | QMP socket driven by a stdlib Python client: query-status, stop/cont, `pmemsave` at ELF symbol addresses, HMP via QMP, quit |
| `exec_trace` | `virt` rv32 | `-icount`, one instruction per TB, `-d exec` log -> per-function instruction counts; checks the loop cost is linear |

Templates (`./qemu-box new <kind> <name> [--dir D]`). Each one is self-contained (startup, semihosting, linker script, Makefile);
`qemu-box shell -- make test` builds, runs headless and checks it (`cortexm`, `riscv_virt`: `make run`). All 13 are instantiated and
run by `tests/test_smoke.sh`.

| Kind | Machine | What you get |
|---|---|---|
| `cortexm` | `mps2-an386` | Cortex-M4 hello over semihosting |
| `riscv_virt` | `virt` rv32 | rv32imac hello, NS16550, semihosting exit |
| `cortexm0_microbit` | `microbit` | nRF51822 Cortex-M0, UART0 driver, M0 divide helpers |
| `cortexm3_stm32` | `stm32vldiscovery` | STM32F100 Cortex-M3, USART1 |
| `stm32f4_usart` | `netduinoplus2` | STM32F4 (BlackPill-class) with a reusable `uart.c` driver (BRR from the bus clock) |
| `aarch64_virt` | `virt -cpu cortex-a53` | AArch64 EL1 bare metal, PL011, system registers |
| `riscv64_virt` | `virt` rv64 | rv64imac, hart id + device tree pointer from a0/a1 |
| `sifive_e` | `sifive_e` | FE310: XIP flash + DTIM `.data`, SiFive UART0 |
| `unit_tests_cm4` | `mps2-an386` | on-target unit tests: `<name>_lib.c` under test, tiny CHECK runner, exit status = failures |
| `gdb_session` | `mps2-an386` | target + `session.lldb`; `make debug` runs it over the gdbstub (conditional breakpoint, backtrace, expression) |
| `riscv_irq` | `virt` rv32 | CLINT machine-timer interrupt handler |
| `cortexm_irq` | `mps2-an386` | SysTick + NVIC interrupts, weak handlers |
| `qmp_script` | `virt` rv32 | guest + `qmp_client.py`: pause, read memory at a symbol, resume, quit |

Which of your boards have a QEMU machine:

| Owned board | QEMU machine | Fidelity |
|---|---|---|
| BlackPill F411, F401/F405-class | `netduinoplus2`, `olimex-stm32-h405` (STM32F405) | core + USART/timers; no RCC/GPIO depth |
| STM32F103 (BluePill) | `stm32vldiscovery` (STM32F100, Cortex-M3) | similar, M3 |
| nRF51822 chips | `microbit` (Cortex-M0) | UART, timer, GPIO basics |
| Orange Pi / Allwinner H3 (Yocto) | `orangepi-pc` (Cortex-A7) | boots mainline U-Boot/Linux, SD, EMAC |
| Allwinner R40 / A-series | `bpim2u`, `cubieboard` | Linux-capable |
| K210 / K230 / CH32V / BL616 cores | `virt` rv32/rv64 | ISA-level only; no SoC peripherals |
| (none owned) HiFive1 | `sifive_e` | FE310 |

No QEMU machine for STM32G4/H5/H7, nRF52840 (use Renode), RP2040/RP2350, ESP32 (Espressif keeps a QEMU fork), CH32V003,
K210/K230 SoC peripherals, H616, T113, RK3506, RV1103, SG2002, STM32MP13.

## Configuration and environment variables

| Variable | Default | Meaning |
|---|---|---|
| `BOXT_OUT` | same ID path on idisk03, else `./build` | output root (`build/`, `log/`); or `config/local.env` |
| `BOXT_JOBS` | 8 (maximum 8) | parallel jobs |
| `BOXT_MIN_FREE_GB` / `BOXT_RAM_WAIT_MAX` | 8 / 3600 | pause builds below this free RAM (GB) / give up after s |
| `BOXT_NET_TIMEOUT` | 3600 | seconds for one download |
| `BOXT_PLATFORM` | detected (`linux-x64`) | override platform |
| `GITHUB_TOKEN` | unset | optional, lifts the API limit for `update --check` |
| `BOX_INTEGRATION` | 1 | `0` = standalone: ignore `$BOX`/`$BOX_V3`, keep output in this folder |
| `NO_COLOR` | unset | set to print plain text (colour is only used on a terminal anyway) |
| `BOX_QEMU_EMBEDDED` | set by `box_env.sh` | path of this ID, used by the native snippet |
| `BOX_NATIVE_OFF_QEMU` | unset | `1` skips native mode for one shell (old name `QEMUBOX_NATIVE_OFF` still honoured) |

Pins (`config/pins.tsv`) change only by a deliberate edit; `update` just compares.

## Where files go

| What | Where |
|---|---|
| Source, launcher, examples, templates | this ID (`qemu-box`, `lib/qemu.bash`, `lib/run-elf.sh`) |
| Tools | `install/qemu-arm-9.2.4-1` 392 MB, `install/qemu-riscv-9.2.4-1` 365 MB (+ `install/qemu-arm`, `qemu-riscv` symlinks), `.pixi/` 1.3 GB (LLVM env), `.bin/` 110 MB |
| Cache | `cache/` about 2.1 GB (downloads 68 MB + pixi packages incl. the superseded LLVM 23; `CACHEDIR.TAG`) |
| Build output and logs | `$BOX_V3/30_39_tools/32_embedded/32_10_qemu/{build,log}` (`build/examples/<ex>/`) |

About 4.3 GB with caches, 2.2 GB without. `clean [--all] --yes` moves the regenerable parts to the Trash (logged); without `--yes` it lists them.

## Native mode

`./qemu-box native` writes `native/native.{zsh,bash}` and relative wrappers in `native/bin`: `qemu-system-arm`,
`qemu-system-aarch64`, `qemu-system-riscv32`, `qemu-system-riscv64` (the xPack binaries directly) and `qemu-run-elf`
(`qemu-box run-elf`). Nothing from the conda env goes on PATH. Load it in every shell (zsh, bash, fish) with `box
native enable qemu --apply`: it runs `./qemu-box native` when the files are missing and rebuilds `box_env.d/native.*`
(without `--apply` it only shows the plan; `box native disable qemu --apply` undoes it). `BOX_NATIVE_OFF_QEMU=1` skips
it for one shell (the old `QEMUBOX_NATIVE_OFF` still works for now). Without Box, source `native/native.zsh` or
`native/native.bash` from your shell rc.

## Tests

```sh
./qemu-box test --all
tests/test_smoke.sh        # every QEMU binary starts, all 13 templates instantiate and pass (run / make test), lldb starts
tests/test_dry_run.sh      # every command in --dry-run + shellcheck
```

Last known (2026-10-29): doctor 19 ok / 0 failed; `examples test` 18/18; `test_smoke.sh` 18/18 (13 templates); `test_dry_run.sh` 29/29
(shellcheck of 24 scripts, Python syntax).

## Troubleshooting

| Symptom | Fix |
|---|---|
| `gdb` is the host's `/usr/bin/gdb` and cannot do Arm/RISC-V | use `./qemu-box gdb` (lldb from the env); conda-forge's gdb is host-only |
| `set architecture armv7e-m` fails | same cause: no cross gdb is bundled; use lldb or your own `arm-none-eabi-gdb` with `--gdb=PORT` |
| Disk use higher than expected | the pixi cache still holds LLVM 23 packages; `./qemu-box clean --all --yes` (moves to Trash) |
| `pixi clean` removed the env | do not run it; `./qemu-box bootstrap` regenerates the env |
| macOS blocks QEMU | allow the unsigned xPack binary once in Gatekeeper |
| Folder moved, env broken | `./qemu-box relocate` |
| `update --check` hits an API limit | export `GITHUB_TOKEN` |
| `-gdb ... Address already in use` | another process took the port; the examples ask the kernel for a free port |
| `undefined symbol: __aeabi_uidiv` / `__udivdi3` | no libgcc/compiler-rt: M0 uses the helpers in `mini.c`; avoid 64-bit `/` on rv32 |
| a global you read from the host is missing in `llvm-nm` | `--gc-sections` dropped it: reference it from code |

## Limitations / needs you

- QEMU models are thin for MCUs (see the board table); use `32_06_renode` for peripheral-level work.
- Windows: run from Git Bash or MSYS2. Linux arm64 and macOS are pinned but not tested here.
- No sudo, licence or hardware needed. No entry for this ID in `$BOX/00_09_meta/02_logs/2026_10_25_open_items.md` (its QEMU mentions concern Yocto images).

## Scripts

Each script has a `[scripts.*]` descriptor in `.box.toml` (`box scripts show 32_10`; `box scripts check 32_10` must stay clean).

- `examples/gdb_debug_session/example.sh`: scripted debug session: QEMU -gdb + lldb batch (break main, read global, step, continue)
- `examples/mps2_semihosting/example.sh`: Cortex-M4 (mps2-an386): hello + fib(30) over semihosting, exit status from main()
- `examples/netduinoplus2_usart/example.sh`: STM32F405 (netduinoplus2, BlackPill-like F4) USART1 polling driver, serial on stdio
- `examples/riscv_virt_uart/example.sh`: RISC-V virt rv32 + rv64 bare-metal (M-mode, no OpenSBI): NS16550 UART + misa
- `examples/sifive_e_uart/example.sh`: SiFive FE310 (sifive_e / HiFive1) rv32: XIP flash + DTIM data, SiFive UART0
- `examples/<the 13 added 2026-10-29>/example.sh`: see the examples table; `qmp_control/qmp.py` (QMP client) and `exec_trace/count.py` (exec log -> instruction counts) are their helpers
- `lib/boxtool.bash`: shared launcher framework (boxtool 3: bootstrap, pinned downloads, pixi env, every common command); byte-identical copy of `$BOX/00_09_meta/05_policy/templates/tool/lib/boxtool.bash` (edit there, then sync)
- `lib/qemu.bash`: this tool's part of the launcher: TOOL_* settings, hook_* functions and extra commands (`./qemu-box help`)
- `lib/run-elf.sh`: headless QEMU run of a bare-metal ELF (QEMU binary chosen from the ELF header); behind `./qemu-box run-elf`
- `qemu-box`: the launcher (POSIX sh): bootstraps the pinned pixi, keeps caches inside this folder, then runs lib/; `./qemu-box help` lists the commands
- `tests/test_dry_run.sh`: every launcher command in --dry-run mode, the read-only commands for real, plus shellcheck (no downloads or builds)
- `tests/test_smoke.sh`: Smoke test of the installed qemu-box: every QEMU binary starts, every template is instantiated into a temp dir and runs headless (`make run` / `make test`), lldb starts
- `native/`: written by `./qemu-box native` (wrappers in native/bin, native.zsh / native.bash); regenerate, do not edit

## Links

- xPack QEMU: <https://github.com/xpack-dev-tools/qemu-arm-xpack/releases/tag/v9.2.4-1>, <https://github.com/xpack-dev-tools/qemu-riscv-xpack/releases/tag/v9.2.4-1>
- LLVM on conda-forge: <https://github.com/conda-forge/clangdev-feedstock>, <https://github.com/conda-forge/lldb-feedstock>; pixi: <https://github.com/prefix-dev/pixi>
- History: `NOTES.md`; `examples/common/` has its own README. Reports: `$BOX/00_09_meta/02_logs/2026_10_25_readability_embedded_tools_verification_report.md`.
- Sibling: `32_06_renode` (peripheral-level simulation).
