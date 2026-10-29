#!/usr/bin/env bash
# shellcheck disable=SC2015  # "checks && ... || fail" chains are intended
# about: QMP control of a running RISC-V virt guest: query-status, stop/cont, pmemsave of ELF symbols, HMP via QMP, quit (stdlib Python client)
# Usage (through ./qemu-box examples ...): example.sh build | run | test
set -euo pipefail
act=${1:-run}
OUT=${EX_OUT:?run through ./qemu-box examples}
ELF="$OUT/qmpt.elf"
build() { make -s OUT="$OUT" -j"${BOXT_JOBS:-4}"; }
session() {
  local sock; sock=$(mktemp -u "${TMPDIR:-/tmp}/qmp.XXXXXX")   # short path: unix sockets are limited to 108 bytes
  bash "${BOXT_ROOT:?}/lib/run-elf.sh" virt "$ELF" --timeout 60 -- -qmp "unix:$sock,server=on,wait=off" >"$OUT/qemu.log" 2>&1 &
  local qpid=$! rc=0
  sym() { llvm-nm "$ELF" | awk -v s="$1" '$3 == s { print $1 }'; }
  python "$EX_DIR/qmp.py" "$sock" "$(sym magic)" "$(sym heartbeat)" "$OUT" || { rc=$?; kill "$qpid" 2>/dev/null || true; }
  wait "$qpid" || true
  [ -S "$sock" ] && rm -f "$sock"   # QEMU's own socket file in the temp dir
  return "$rc"
}
case "$act" in
  build) build ;;
  run) build; session; cat "$OUT/qemu.log" ;;
  test)
    build
    out=$(session 2>&1) || { echo "$out"; echo "FAIL: QMP session"; exit 1; }
    echo "$out"; head -c 300 "$OUT/qemu.log"; echo
    grep -q 'status running' <<<"$out" && grep -q 'status paused' <<<"$out" && grep -q 'magic 0xc0ffee11' <<<"$out" \
      && grep -q 'QMP checks ok' <<<"$out" && grep -q 'qmp target running' "$OUT/qemu.log" || { echo "FAIL: output"; exit 1; }
    echo "PASS qmp_control" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac
