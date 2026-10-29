#!/usr/bin/env bash
# shellcheck disable=SC2015  # "checks && ... || fail" chains are intended
# about: AArch64 bare metal on virt -cpu cortex-a53 (Yocto SoC class): PL011, CurrentEL, MIDR_EL1, generic timer, semihosting exit
# Usage (through ./qemu-box examples ...): example.sh build | run | test
set -euo pipefail
act=${1:-run}
OUT=${EX_OUT:?run through ./qemu-box examples}
RUN=(bash "${BOXT_ROOT:?}/lib/run-elf.sh" virt "$OUT/a64.elf" --timeout 20 -- -cpu cortex-a53)
build() { make -s OUT="$OUT" -j"${BOXT_JOBS:-4}"; }
case "$act" in
  build) build ;;
  run) build; "${RUN[@]}" ;;
  test)
    build
    out=$("${RUN[@]}" 2>&1) || { echo "$out"; echo "FAIL: QEMU exit status"; exit 1; }
    echo "$out"
    grep -q 'hello from AArch64' <<<"$out" && grep -q 'CurrentEL = EL1' <<<"$out" && grep -q '(Cortex-A53)' <<<"$out" \
      && grep -q 'CNTFRQ_EL0 = 62500000 Hz' <<<"$out" || { echo "FAIL: output"; exit 1; }
    echo "PASS aarch64_virt_pl011" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac
