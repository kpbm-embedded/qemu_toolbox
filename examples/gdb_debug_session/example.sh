#!/usr/bin/env bash
# shellcheck disable=SC2015  # "checks && ... || fail" chains are intended
# about: scripted debug session: QEMU -gdb + lldb batch (break main, read global, step, continue)
# Usage (through ./qemu-box examples ...): example.sh build | run | test
# QEMU starts halted (-S) with its gdbstub on 127.0.0.1:PORT; lldb attaches with gdb-remote.
set -euo pipefail
act=${1:-run}
OUT=${EX_OUT:?run through ./qemu-box examples}
ELF="$OUT/debugme.elf"
LLDB=${QEMU_BOX_LLDB:-lldb}
build() { make -s OUT="$OUT" -j"${BOXT_JOBS:-4}"; }
session() { # -> lldb transcript on stdout, QEMU output in $OUT/qemu.log
  local port   # a port the kernel just handed out (a fixed or random one can be taken on a shared machine)
  port=$(python -c 'import socket; s = socket.socket(); s.bind(("127.0.0.1", 0)); print(s.getsockname()[1])')
  bash "${BOXT_ROOT:?}/lib/run-elf.sh" mps2-an386 "$ELF" --gdb="$port" --timeout 60 >"$OUT/qemu.log" 2>&1 &
  local qpid=$!
  local _i; for _i in $(seq 1 50); do (exec 3<>"/dev/tcp/127.0.0.1/$port") 2>/dev/null && break; sleep 0.2; done
  "$LLDB" -b -o "target create --arch thumbv7em-none-eabi $ELF" -o "gdb-remote 127.0.0.1:$port" \
    -s "$EX_DIR/session.lldb" 2>&1 || true
  wait "$qpid"; echo "qemu exit status: $?"
}
case "$act" in
  build) build ;;
  run) build; session; cat "$OUT/qemu.log" ;;
  test)
    build
    out=$(session); echo "$out"; cat "$OUT/qemu.log"
    grep -q 'counter = 7' <<<"$out" && grep -q 'counter = 17' <<<"$out" && grep -q 'counter = 27' <<<"$out" \
      && grep -q 'qemu exit status: 0' <<<"$out" && grep -q 'debugme finished' "$OUT/qemu.log" || { echo "FAIL: debug session"; exit 1; }
    echo "PASS gdb_debug_session" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac
