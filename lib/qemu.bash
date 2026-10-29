# shellcheck shell=bash disable=SC2015,SC2034  # d_* return 0; TOOL_* are read by boxtool.bash
# qemu-box: tool part (hooks for lib/boxtool.bash). xPack QEMU (qemu-arm: qemu-system-arm/
# aarch64, qemu-riscv: qemu-system-riscv32/64) + a pixi env with clang/lld/llvm-tools, make,
# lldb (gdb-remote client) for bare-metal firmware.
TOOL_TITLE="32_10_qemu: QEMU $(sed -n 's/^qemu-arm\t\([^\t]*\)\t.*/\1/p' "${BOXT_ROOT:?}/config/pins.tsv" | head -1) (xPack) for embedded targets + LLVM bare-metal toolchain"
TOOL_INSTALL_WHAT="the example firmware build (examples build)"
TOOL_HELP_USE="  machines [arm|riscv]    list QEMU machines (-M help) of qemu-system-arm/aarch64/riscv32/riscv64
  run-elf <machine> <elf> [--gdb[=PORT]] [--timeout S] [--no-semihosting] [-- qemu args]
                          headless run (-nographic, serial on stdio, semihosting on)
  gdb [args]              the env's debugger: lldb 22 (gdb-remote client for QEMU -gdb;
                          conda-forge gdb is host-only, so no gdb is bundled)
  qemu <binary> [args]    any bundled QEMU binary, e.g. qemu qemu-system-arm -M help"
hook_help() { # printed after boxtool's help: tool-specific examples and environment
  cat <<EOF

tool examples
  ./$BOXT_NAME machines arm                     QEMU machine names for -M
  ./$BOXT_NAME run-elf mps2-an386 fw.elf --timeout 10   headless run, semihosting exit code
  ./$BOXT_NAME run-elf mps2-an386 fw.elf --gdb  wait for a debugger on port 1234, then:
  ./$BOXT_NAME gdb fw.elf -o 'gdb-remote 1234'  lldb as the gdb-remote client
tool environment
  QEMU_BOX_TIMEOUT   run-elf: seconds before the run is stopped (30; --timeout overrides)
EOF
}
# shellcheck source-path=SCRIPTDIR source=boxtool.bash
. "$BOXT_ROOT/lib/boxtool.bash"

hook_env() {
  local p
  for p in "$INST/qemu-riscv/bin" "$INST/qemu-arm/bin"; do
    [ -d "$p" ] && PATH="$p:$PATH"
  done
  export PATH QEMU_BOX_ROOT="$ROOT" QEMU_BOX_LIB="$ROOT/lib"
}

hook_bootstrap() { cachedir_tag "$ROOT/cache"; }

hook_install() { # demos-flag
  info "building the example firmware (examples build)"
  cmd_examples build
}

hook_status() {
  local e n=0
  for e in $(ex_list); do [ -d "$BUILD/examples/$e" ] && n=$((n+1)); done
  printf '  %-22s %s of %s built in %s\n' examples "$n" "$(ex_list | wc -l)" "$BUILD/examples"
}

hook_doctor() {
  local b v
  for b in qemu-system-arm qemu-system-aarch64 qemu-system-riscv32 qemu-system-riscv64; do
    v=$("$b" --version 2>/dev/null | head -1) && d_ok "$v ($b)" || d_fail "$b missing or not runnable"
  done
  v=$(clang --version 2>/dev/null | head -1) && d_ok "$v" || d_fail "clang missing in the pixi env"
  v=$(ld.lld --version 2>/dev/null | head -1) && d_ok "$v" || d_fail "ld.lld missing"
  command -v llvm-objcopy >/dev/null && d_ok "llvm-objcopy/readelf (llvm-tools)" || d_fail "llvm-tools missing"
  v=$(make --version 2>/dev/null | head -1) && d_ok "$v" || d_fail "make missing"
  v=$(dtc --version 2>/dev/null | head -1) && d_ok "dtc: $v (device trees)" || d_warn "dtc missing (riscv_fdt_walk example)"
  if [ -x "$ENV_DIR/bin/lldb" ]; then
    v=$("$ENV_DIR/bin/lldb" --version 2>/dev/null | head -1 | awk '{print $3}')
    "$ENV_DIR/bin/lldb" -b -o 'settings show target.default-arch' >/dev/null 2>&1 && d_ok "lldb $v (env; gdb-remote to arm + riscv)" || d_fail "lldb not runnable"
  else d_fail "lldb missing in the pixi env"; fi
  local t; t=$(qemu-system-arm -M help 2>/dev/null | grep -cE '^(mps2-an386|netduinoplus2|microbit|stm32vldiscovery) ')
  [ "$t" -ge 3 ] && d_ok "qemu-system-arm machines: mps2-an386, netduinoplus2, microbit, ..." || d_fail "expected Cortex-M machines missing"
  t=$(qemu-system-riscv32 -M help 2>/dev/null | grep -cE '^(virt|sifive_e) ')
  [ "$t" -ge 2 ] && d_ok "qemu-system-riscv32 machines: virt, sifive_e, ..." || d_fail "expected RISC-V machines missing"
}

# native mode: the QEMU binaries directly (they are relocatable), gdb/run-elf via the launcher
hook_native_bins() {
  local b
  for b in qemu-system-arm qemu-system-aarch64; do echo "$b install/qemu-arm/bin/$b"; done
  for b in qemu-system-riscv32 qemu-system-riscv64; do echo "$b install/qemu-riscv/bin/$b"; done
  echo "qemu-run-elf @run-elf"
}

tool_cmd_machines() {
  activate
  local which=${1:-all} b
  case "$which" in arm) set -- qemu-system-arm qemu-system-aarch64 ;; riscv) set -- qemu-system-riscv32 qemu-system-riscv64 ;;
    all) set -- qemu-system-arm qemu-system-aarch64 qemu-system-riscv32 qemu-system-riscv64 ;; *) usage_error "usage: ./$NAME machines [arm|riscv]" ;; esac
  for b in "$@"; do
    echo "== $b"
    [ "$DRY" = 1 ] && { printf '+ %s -M help\n' "$b"; continue; }
    "$b" -M help | tail -n +2
  done
}
tool_cmd_run-elf() {
  activate
  [ "$DRY" = 1 ] && { printf '+ lib/run-elf.sh %s\n' "$*"; return 0; }
  exec bash "$ROOT/lib/run-elf.sh" "$@"
}
tool_cmd_gdb() {
  activate
  [ "$DRY" = 1 ] && { printf '+ lldb %s\n' "$*"; return 0; }
  exec "$ENV_DIR/bin/lldb" "$@"
}
tool_cmd_qemu() {
  [ $# -ge 1 ] || usage_error "usage: ./$NAME qemu <qemu-system-...> [args]"
  activate
  case "$1" in qemu-*) ;; *) die "not a QEMU binary: $1" ;; esac
  [ "$DRY" = 1 ] && { printf '+ %s\n' "$*"; return 0; }
  exec "$@"
}

boxt_main "$@"
