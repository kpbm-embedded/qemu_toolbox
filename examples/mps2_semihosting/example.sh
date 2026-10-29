#!/usr/bin/env bash
# shellcheck disable=SC2015  # "checks && ... || fail" chains are intended
# about: Cortex-M4 (mps2-an386): hello + fib(30) over semihosting, exit status from main()
# Usage (through ./qemu-box examples ...): example.sh build | run | test
set -euo pipefail
act=${1:-run}
OUT=${EX_OUT:?run through ./qemu-box examples}
RUN=(bash "${BOXT_ROOT:?}/lib/run-elf.sh" mps2-an386 "$OUT/hello.elf" --timeout 20)
build() { make -s OUT="$OUT" -j"${BOXT_JOBS:-4}"; }
case "$act" in
  build) build ;;
  run) build; "${RUN[@]}" ;;
  test)
    build
    out=$("${RUN[@]}" 2>&1) || { rc=$?; echo "$out"; echo "FAIL: QEMU exit status $rc"; exit 1; }
    echo "$out"
    grep -q 'hello from Cortex-M4' <<<"$out" && grep -q 'fib(30) = 832040' <<<"$out" || { echo "FAIL: output"; exit 1; }
    echo "PASS mps2_semihosting" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac
