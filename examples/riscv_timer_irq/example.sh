#!/usr/bin/env bash
# shellcheck disable=SC2015  # "checks && ... || fail" chains are intended
# about: RISC-V virt rv32 M-mode: CLINT machine-timer interrupts (mtimecmp, mtvec, interrupt("machine") handler), 5 x 10 ms
# Usage (through ./qemu-box examples ...): example.sh build | run | test
set -euo pipefail
act=${1:-run}
OUT=${EX_OUT:?run through ./qemu-box examples}
RUN=(bash "${BOXT_ROOT:?}/lib/run-elf.sh" virt "$OUT/timer.elf" --timeout 20)
build() { make -s OUT="$OUT" -j"${BOXT_JOBS:-4}"; }
case "$act" in
  build) build ;;
  run) build; "${RUN[@]}" ;;
  test)
    build
    out=$("${RUN[@]}" 2>&1) || { echo "$out"; echo "FAIL: QEMU exit status"; exit 1; }
    echo "$out"
    grep -qE 'timer irq: 5 ticks, mcause 0x80000007, elapsed [0-9]+ ms' <<<"$out" || { echo "FAIL: output"; exit 1; }
    echo "PASS riscv_timer_irq" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac
