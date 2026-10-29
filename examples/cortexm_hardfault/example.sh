#!/usr/bin/env bash
# shellcheck disable=SC2015  # "checks && ... || fail" chains are intended
# about: Cortex-M4 (mps2-an386): UDF -> HardFault handler prints stacked PC/LR, CFSR, HFSR; checks PC == fault_here (llvm-nm)
# Usage (through ./qemu-box examples ...): example.sh build | run | test
set -euo pipefail
act=${1:-run}
OUT=${EX_OUT:?run through ./qemu-box examples}
ELF="$OUT/fault.elf"
RUN=(bash "${BOXT_ROOT:?}/lib/run-elf.sh" mps2-an386 "$ELF" --timeout 20)
build() { make -s OUT="$OUT" -j"${BOXT_JOBS:-4}"; }
case "$act" in
  build) build ;;
  run) build; "${RUN[@]}" || echo "exit status $? (expected: the fault ends the run with a failure)" ;;
  test)
    build
    rc=0; out=$("${RUN[@]}" 2>&1) || rc=$?
    echo "$out"; echo "qemu exit status: $rc"
    # fault_here is a Thumb function: symbol value has bit 0 set, the stacked PC does not
    sym=$(llvm-nm "$ELF" | awk '$3 == "fault_here" { print $1 }')
    want=$(printf '0x%08x' $(( (16#$sym) & ~1 )))
    echo "fault_here at $want"
    [ "$rc" -ne 0 ] && grep -q "pc   = $want" <<<"$out" && grep -q 'cause: UNDEFINSTR' <<<"$out" \
      && grep -q 'HFSR = 0x40000000' <<<"$out" && ! grep -q 'not reached' <<<"$out" || { echo "FAIL: fault report"; exit 1; }
    echo "PASS cortexm_hardfault" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac
