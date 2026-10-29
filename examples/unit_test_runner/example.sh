#!/usr/bin/env bash
# shellcheck disable=SC2015  # "checks && ... || fail" chains are intended
# about: on-target unit tests (ring buffer, CRC-16) on Cortex-M4 (mps2-an386): failure count = exit status; checks a failing build too
# Usage (through ./qemu-box examples ...): example.sh build | run | test
set -euo pipefail
act=${1:-run}
OUT=${EX_OUT:?run through ./qemu-box examples}
run1() { bash "${BOXT_ROOT:?}/lib/run-elf.sh" mps2-an386 "$OUT/$1.elf" --timeout 20; }
build() {
  make -s OUT="$OUT" -j"${BOXT_JOBS:-4}"
  make -s -B OUT="$OUT" NAME=tests_fail DEFS=-DINJECT_FAILURE -j"${BOXT_JOBS:-4}" >/dev/null
}
case "$act" in
  build) build ;;
  run) build; run1 tests ;;
  test)
    build
    out=$(run1 tests 2>&1) || { echo "$out"; echo "FAIL: tests failed"; exit 1; }
    echo "$out"
    grep -q '5 tests, 0 failures' <<<"$out" || { echo "FAIL: summary"; exit 1; }
    rc=0; bad=$(run1 tests_fail 2>&1) || rc=$?
    echo "$bad" | grep -E 'FAIL|failed|failures'
    [ "$rc" -ne 0 ] && grep -q 'FAIL test_crc16' <<<"$bad" && grep -q 'main.c:[0-9]*: CHECK(' <<<"$bad" \
      && grep -q '5 tests, 1 failures' <<<"$bad" || { echo "FAIL: injected failure not reported (rc=$rc)"; exit 1; }
    echo "PASS unit_test_runner (pass run exit 0, injected failure exit $rc)" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac
