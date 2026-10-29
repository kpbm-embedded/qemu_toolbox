#!/usr/bin/env bash
# shellcheck disable=SC2015  # "checks && ... || fail" chains are intended
# about: instruction tracing: -icount + one-insn-per-tb + -d exec log -> per-function instruction counts; checks the loop cost is linear in ITER
# Usage (through ./qemu-box examples ...): example.sh build | run | test
set -euo pipefail
act=${1:-run}
OUT=${EX_OUT:?run through ./qemu-box examples}
ITERS=(16 32 48)
build() { local n; for n in "${ITERS[@]}"; do make -s OUT="$OUT" NAME="trace$n" ITER="$n" -j"${BOXT_JOBS:-4}" >/dev/null; done; echo "built ${ITERS[*]/#/trace}"; }
trace() { # n -> instruction counts per function in $OUT/counts$n.txt, returns the count of checksum()
  local n=$1
  bash "${BOXT_ROOT:?}/lib/run-elf.sh" virt "$OUT/trace$n.elf" --timeout 30 -- \
    -icount shift=0 -accel tcg,one-insn-per-tb=on -d exec,nochain -D "$OUT/exec$n.log" >"$OUT/run$n.log" 2>&1
  llvm-nm -S "$OUT/trace$n.elf" >"$OUT/nm$n.txt"
  python "$EX_DIR/count.py" "$OUT/nm$n.txt" "$OUT/exec$n.log" >"$OUT/counts$n.txt"
  awk '$2 == "checksum" { print $1 }' "$OUT/counts$n.txt"
}
case "$act" in
  build) build ;;
  run) build; trace 16 >/dev/null; cat "$OUT/run16.log"; echo "instructions per function (ITER=16):"; cat "$OUT/counts16.txt" ;;
  test)
    build
    declare -A c
    for n in "${ITERS[@]}"; do c[$n]=$(trace "$n"); echo "ITER=$n: checksum() executed ${c[$n]} instructions"; done
    head -4 "$OUT/counts16.txt"
    d1=$(( c[32] - c[16] )); d2=$(( c[48] - c[32] ))
    echo "per 16 iterations: $d1 / $d2 instructions ($(( d1 / 16 )) per iteration)"
    [ "${c[16]}" -gt 0 ] && [ "$d1" -gt 0 ] && [ "$d1" -eq "$d2" ] && [ $(( d1 % 16 )) -eq 0 ] \
      && grep -q 'checksum(48) = ' "$OUT/run48.log" || { echo "FAIL: instruction counts"; exit 1; }
    echo "PASS exec_trace" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac
