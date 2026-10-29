#!/usr/bin/env bash
# shellcheck disable=SC2015  # "checks && ... || fail" chains are intended
# about: nRF51822 (microbit, Cortex-M0) UART0 task/event driver, FICR flash size, serial on stdio
# Usage (through ./qemu-box examples ...): example.sh build | run | test
set -euo pipefail
act=${1:-run}
OUT=${EX_OUT:?run through ./qemu-box examples}
RUN=(bash "${BOXT_ROOT:?}/lib/run-elf.sh" microbit "$OUT/uart.elf" --timeout 20)
build() { make -s OUT="$OUT" -j"${BOXT_JOBS:-4}"; }
case "$act" in
  build) build ;;
  run) build; "${RUN[@]}" ;;
  test)
    build
    out=$("${RUN[@]}" 2>&1 | tr -d '\r') || { echo "$out"; echo "FAIL: QEMU exit status"; exit 1; }
    echo "$out"
    grep -q 'hello from nRF51822 UART0' <<<"$out" && grep -q 'flash = 256 KB' <<<"$out" && grep -q '3^10 = 59049' <<<"$out" || { echo "FAIL: output"; exit 1; }
    echo "PASS microbit_uart" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac
