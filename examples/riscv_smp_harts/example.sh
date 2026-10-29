#!/usr/bin/env bash
# shellcheck disable=SC2015  # "checks && ... || fail" chains are intended
# about: RISC-V virt rv64 -smp 4: CLINT software-interrupt wake-up (IPI), amoadd counter, amoswap spinlock, per-hart output
# Usage (through ./qemu-box examples ...): example.sh build | run | test
set -euo pipefail
act=${1:-run}
OUT=${EX_OUT:?run through ./qemu-box examples}
RUN=(bash "${BOXT_ROOT:?}/lib/run-elf.sh" virt "$OUT/smp.elf" --timeout 20 -- -smp 4)
build() { make -s OUT="$OUT" -j"${BOXT_JOBS:-4}"; }
case "$act" in
  build) build ;;
  run) build; "${RUN[@]}" ;;
  test)
    build
    out=$("${RUN[@]}" 2>&1) || { echo "$out"; echo "FAIL: QEMU exit status"; exit 1; }
    echo "$out"
    for h in 1 2 3; do grep -q "^hart $h up" <<<"$out" || { echo "FAIL: hart $h"; exit 1; }; done
    grep -q 'all 4 harts done, counter = 60' <<<"$out" || { echo "FAIL: output"; exit 1; }
    echo "PASS riscv_smp_harts" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac
