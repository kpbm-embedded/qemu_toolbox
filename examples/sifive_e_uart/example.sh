#!/usr/bin/env bash
# shellcheck disable=SC2015  # "checks && ... || fail" chains are intended
# about: SiFive FE310 (sifive_e / HiFive1) rv32: XIP flash + DTIM data, SiFive UART0
# Usage (through ./qemu-box examples ...): example.sh build | run | test
set -euo pipefail
act=${1:-run}
OUT=${EX_OUT:?run through ./qemu-box examples}
RUN=(bash "${BOXT_ROOT:?}/lib/run-elf.sh" sifive_e "$OUT/fe310.elf" --timeout 20)
build() { make -s OUT="$OUT" -j"${BOXT_JOBS:-4}"; }
case "$act" in
  build) build ;;
  run) build; "${RUN[@]}" ;;
  test)
    build
    out=$("${RUN[@]}" 2>&1) || { echo "$out"; echo "FAIL: QEMU exit status"; exit 1; }
    echo "$out"
    grep -q 'hello from SiFive FE310' <<<"$out" && grep -q 'counter = 42' <<<"$out" || { echo "FAIL: output"; exit 1; }
    echo "PASS sifive_e_uart" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac
