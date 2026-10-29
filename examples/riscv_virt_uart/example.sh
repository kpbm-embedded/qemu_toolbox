#!/usr/bin/env bash
# shellcheck disable=SC2015  # "checks && ... || fail" chains are intended
# about: RISC-V virt rv32 + rv64 bare-metal (M-mode, no OpenSBI): NS16550 UART + misa
# Usage (through ./qemu-box examples ...): example.sh build | run [rv32|rv64] | test
set -euo pipefail
act=${1:-run}
OUT=${EX_OUT:?run through ./qemu-box examples}
build() { local a; for a in rv32 rv64; do make -s ARCH=$a OUT="$OUT" -j"${BOXT_JOBS:-4}"; done; }
run1() { bash "${BOXT_ROOT:?}/lib/run-elf.sh" virt "$OUT/uart_$1.elf" --timeout 20; }
case "$act" in
  build) build ;;
  run) build; run1 "${2:-rv32}" ;;
  test)
    build
    for a in rv32 rv64; do
      out=$(run1 $a 2>&1) || { echo "$out"; echo "FAIL: $a QEMU exit status"; exit 1; }
      echo "$out"
      grep -q "hello from RISC-V virt NS16550 ($a)" <<<"$out" && grep -q 'sum 1..100 = 5050' <<<"$out" \
        && grep -q 'misa extensions: .*I.*M' <<<"$out" || { echo "FAIL: $a output"; exit 1; }
    done
    echo "PASS riscv_virt_uart (rv32, rv64)" ;;
  *) echo "usage: example.sh build|run [rv32|rv64]|test" >&2; exit 2 ;;
esac
