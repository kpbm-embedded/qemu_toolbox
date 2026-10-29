#!/usr/bin/env bash
# shellcheck disable=SC2015  # "checks && ... || fail" chains are intended
# about: Cortex-M4 (mps2-an386): SysTick 1 ms interrupts + WFI, NVIC software-pended IRQ (IPSR), weak handlers
# Usage (through ./qemu-box examples ...): example.sh build | run | test
set -euo pipefail
act=${1:-run}
OUT=${EX_OUT:?run through ./qemu-box examples}
RUN=(bash "${BOXT_ROOT:?}/lib/run-elf.sh" mps2-an386 "$OUT/irq.elf" --timeout 20)
build() { make -s OUT="$OUT" -j"${BOXT_JOBS:-4}"; }
case "$act" in
  build) build ;;
  run) build; "${RUN[@]}" ;;
  test)
    build
    out=$("${RUN[@]}" 2>&1) || { echo "$out"; echo "FAIL: QEMU exit status"; exit 1; }
    echo "$out"
    grep -q 'systick: 10 ticks of 1 ms' <<<"$out" && grep -q 'nvic: IRQ 7 handled' <<<"$out" || { echo "FAIL: output"; exit 1; }
    echo "PASS cortexm_systick_irq" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac
