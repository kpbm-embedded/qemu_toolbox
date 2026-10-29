#!/usr/bin/env bash
# shellcheck disable=SC2015  # "checks && ... || fail" chains are intended
# about: STM32F100 (stm32vldiscovery, Cortex-M3, BluePill-class) USART1 driver + SCB CPUID check
# Usage (through ./qemu-box examples ...): example.sh build | run | test
set -euo pipefail
act=${1:-run}
OUT=${EX_OUT:?run through ./qemu-box examples}
RUN=(bash "${BOXT_ROOT:?}/lib/run-elf.sh" stm32vldiscovery "$OUT/usart.elf" --timeout 20)
build() { make -s OUT="$OUT" -j"${BOXT_JOBS:-4}"; }
case "$act" in
  build) build ;;
  run) build; "${RUN[@]}" ;;
  test)
    build
    out=$("${RUN[@]}" 2>&1 | tr -d '\r') || { echo "$out"; echo "FAIL: QEMU exit status"; exit 1; }
    echo "$out"
    grep -q 'hello from STM32F100 USART1' <<<"$out" && grep -q '(Cortex-M3)' <<<"$out" && grep -q '1000000/7 = 142857' <<<"$out" || { echo "FAIL: output"; exit 1; }
    echo "PASS stm32vldiscovery_usart" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac
