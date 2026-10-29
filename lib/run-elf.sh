#!/usr/bin/env bash
# run-elf.sh <machine> <elf> [--gdb[=PORT]] [--timeout S] [--no-semihosting] [-- extra qemu args]
# Headless QEMU run of a bare-metal ELF: -nographic, first serial port on stdio, no monitor,
# semihosting on (programs end with SYS_EXIT; the exit status is the program's).
# The QEMU binary follows from the machine and the ELF class (32/64 bit).
# --gdb waits for a debugger on PORT (default 1234) before the first instruction (-S -gdb).
# Needs qemu-system-* on PATH (./qemu-box run-elf sets it up).
set -euo pipefail
usage() { echo "usage: run-elf.sh <machine> <elf> [--gdb[=PORT]] [--timeout S] [--no-semihosting] [-- qemu args]" >&2; exit 2; }
[ $# -ge 2 ] || usage
machine=$1 elf=$2; shift 2
gdb="" tmo=${QEMU_BOX_TIMEOUT:-30} semi=1 extra=()
while [ $# -gt 0 ]; do
  case "$1" in
    --gdb) gdb=1234 ;;
    --gdb=*) gdb=${1#*=} ;;
    --timeout) tmo=${2:?}; shift ;;
    --no-semihosting) semi=0 ;;
    --) shift; extra=("$@"); break ;;
    *) usage ;;
  esac; shift
done
[ -r "$elf" ] || { echo "run-elf: no such file: $elf" >&2; exit 2; }
[ "$(head -c4 "$elf" | od -An -c | tr -d ' ')" = '177ELF' ] || { echo "run-elf: not an ELF file: $elf" >&2; exit 2; }
class=$(od -An -tu1 -j4 -N1 "$elf" | tr -d ' ')        # 1 = 32 bit, 2 = 64 bit
emach=$(od -An -tu2 -j18 -N2 "$elf" | tr -d ' ')       # 40 = ARM, 183 = AArch64, 243 = RISC-V
case "$emach" in
  40) bin=qemu-system-arm ;;
  183) bin=qemu-system-aarch64 ;;
  243) if [ "$class" = 2 ]; then bin=qemu-system-riscv64; else bin=qemu-system-riscv32; fi ;;
  *) echo "run-elf: unsupported ELF machine $emach" >&2; exit 2 ;;
esac
args=(-M "$machine" -nographic -monitor none -serial stdio)
[ "$semi" = 1 ] && args+=(-semihosting-config "enable=on,target=native")
if [ "$emach" = 243 ]; then
  case "$machine" in virt|spike) args+=(-bios none) ;; esac   # no OpenSBI: our code runs in M-mode
fi
args+=(-kernel "$elf")
if [ -n "$gdb" ]; then args+=(-S -gdb "tcp:127.0.0.1:$gdb"); fi
echo "+ $bin ${args[*]} ${extra[*]:-}" >&2
exec timeout --foreground -k 5 "$tmo" "$bin" "${args[@]}" "${extra[@]+"${extra[@]}"}"
