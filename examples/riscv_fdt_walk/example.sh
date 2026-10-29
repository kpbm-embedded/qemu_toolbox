#!/usr/bin/env bash
# shellcheck disable=SC2015  # "checks && ... || fail" chains are intended
# about: RISC-V virt rv64: firmware walks the device tree from a1 (memory, serial); compared with dumpdtb + dtc on the host
# Usage (through ./qemu-box examples ...): example.sh build | run | test
set -euo pipefail
act=${1:-run}
OUT=${EX_OUT:?run through ./qemu-box examples}
RUN=(bash "${BOXT_ROOT:?}/lib/run-elf.sh" virt "$OUT/fdt.elf" --timeout 20)
build() { make -s OUT="$OUT" -j"${BOXT_JOBS:-4}"; }
dts() { # the same machine's tree, decompiled on the host
  qemu-system-riscv64 -M virt,dumpdtb="$OUT/virt.dtb" -bios none -nographic >/dev/null 2>&1 || true
  dtc -q -I dtb -O dts -o "$OUT/virt.dts" "$OUT/virt.dtb"
}
case "$act" in
  build) build ;;
  run) build; "${RUN[@]}"; dts; echo "decompiled tree: $OUT/virt.dts" ;;
  test)
    build; dts
    out=$("${RUN[@]}" 2>&1) || { echo "$out"; echo "FAIL: QEMU exit status"; exit 1; }
    echo "$out"
    nodes=$(grep -cE '^\s*[^ ]+ \{$|^\s*/ \{$' "$OUT/virt.dts" || true)
    mem=$(grep -A3 'memory@80000000' "$OUT/virt.dts" | grep -o 'reg = <.*>')
    echo "dtc: $nodes nodes, memory $mem"
    grep -q "fdt: [0-9]* bytes, $nodes nodes" <<<"$out" && grep -q 'memory base 0x0000000080000000 size 0x0000000008000000' <<<"$out" \
      && [ "$mem" = 'reg = <0x00 0x80000000 0x00 0x8000000>' ] && grep -q 'serial at 0x0000000010000000' <<<"$out" \
      && grep -q 'hello through the UART found in the device tree' <<<"$out" || { echo "FAIL: fdt walk"; exit 1; }
    echo "PASS riscv_fdt_walk" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac
