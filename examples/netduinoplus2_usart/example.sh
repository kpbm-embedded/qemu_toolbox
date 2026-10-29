#!/usr/bin/env bash
# shellcheck disable=SC2015  # "checks && ... || fail" chains are intended
# about: STM32F405 (netduinoplus2, BlackPill-like F4) USART1 polling driver, serial on stdio
# Usage (through ./qemu-box examples ...): example.sh build | run | test
set -euo pipefail
act=${1:-run}
OUT=${EX_OUT:?run through ./qemu-box examples}
RUN=(bash "${BOXT_ROOT:?}/lib/run-elf.sh" netduinoplus2 "$OUT/usart.elf" --timeout 20)
build() { make -s OUT="$OUT" -j"${BOXT_JOBS:-4}"; }
case "$act" in
  build) build ;;
  run) build; "${RUN[@]}" ;;
  test)
    build
    out=$("${RUN[@]}" 2>&1 | tr -d '\r') || { echo "$out"; echo "FAIL: QEMU exit status"; exit 1; }
    echo "$out"
    grep -q 'hello from STM32F405 USART1' <<<"$out" && grep -q 'tick 3' <<<"$out" && grep -q '^done' <<<"$out" || { echo "FAIL: output"; exit 1; }
    echo "PASS netduinoplus2_usart" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac
