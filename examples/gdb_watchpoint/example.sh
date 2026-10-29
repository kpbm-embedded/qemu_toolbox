#!/usr/bin/env bash
# shellcheck disable=SC2015  # "checks && ... || fail" chains are intended
# about: lldb batch over QEMU's gdbstub: hardware write watchpoint on a global, backtrace to the writer, caller's argument
# Usage (through ./qemu-box examples ...): example.sh build | run | test
set -euo pipefail
act=${1:-run}
OUT=${EX_OUT:?run through ./qemu-box examples}
ELF="$OUT/watchme.elf"
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
    grep -q 'stop reason = watchpoint 1' <<<"$out" && grep -q 'new value: 42' <<<"$out" \
      && grep -q 'frame #0: .*set_mode(m=42)' <<<"$out" && grep -q 'frame #1: .*handle_command(cmd=3)' <<<"$out" \
      && grep -q '(int) cmd = 3' <<<"$out" && grep -q 'qemu exit status: 0' <<<"$out" && grep -q 'watchme finished' "$OUT/qemu.log" \
      || { echo "FAIL: watchpoint session"; exit 1; }
    echo "PASS gdb_watchpoint" ;;
  *) echo "usage: example.sh build|run|test" >&2; exit 2 ;;
esac
