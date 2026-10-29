#!/usr/bin/env bash
# shellcheck disable=SC2015  # "checks && ... || fail" chains are intended
# about: Cortex-M4 (mps2-an386): semihosting SYS_OPEN/READ/WRITE/FLEN/CLOCK/TIME - firmware reads in.txt, writes out.txt on the host
# Usage (through ./qemu-box examples ...): example.sh build | run | test
set -euo pipefail
act=${1:-run}
OUT=${EX_OUT:?run through ./qemu-box examples}
build() { make -s OUT="$OUT" -j"${BOXT_JOBS:-4}"; }
run1() { # QEMU's working directory is where the firmware's relative paths land
  printf '%s\n' 17 25 1000 3 "42 8" >"$OUT/in.txt"
  rm -f "$OUT/out.txt" 2>/dev/null || true   # own output file from the last run
  (cd "$OUT" && bash "${BOXT_ROOT:?}/lib/run-elf.sh" mps2-an386 fileio.elf --timeout 20)
}
case "$act" in
  build) build ;;
  run) build; run1; cat "$OUT/out.txt" ;;
  test)
    build
    out=$(run1 2>&1) || { echo "$out"; echo "FAIL: QEMU exit status"; exit 1; }
    echo "$out"; echo "out.txt: $(cat "$OUT/out.txt" 2>/dev/null)"
    grep -q 'read 6 numbers, sum 1095' <<<"$out" && [ "$(cat "$OUT/out.txt")" = 1095 ] \
      && grep -qE 'clock [0-9]+ cs, host time [0-9]{10}' <<<"$out" || { echo "FAIL: file I/O"; exit 1; }
    echo "PASS semihosting_file_io" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac
