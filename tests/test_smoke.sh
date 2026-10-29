#!/usr/bin/env bash
# Smoke test of the installed qemu-box: every QEMU binary starts, the LLVM toolchain builds
# every template into a temp dir: cortexm/riscv_virt build and run headless (exit 0), the others
# pass their own `make test`; lldb starts.
# Usage: tests/test_smoke.sh
set -uo pipefail
HERE=$(cd "$(dirname "$0")/.." && pwd -P)
Q="$HERE/qemu-box"
pass=0; failn=0
ok()  { printf 'ok    %s\n' "$*"; pass=$((pass+1)); }
bad() { printf 'FAIL  %s\n' "$*"; failn=$((failn+1)); }
tmp=$(mktemp -d)
cleanup() { if command -v trash-put >/dev/null; then trash-put "$tmp"; fi; }   # own temp dir; never rm
trap cleanup EXIT

for b in qemu-system-arm qemu-system-aarch64 qemu-system-riscv32 qemu-system-riscv64; do
  if v=$("$Q" run "$b" --version 2>&1 | head -1) && grep -q 'QEMU emulator version' <<<"$v"; then ok "$b: $v"
  else bad "$b: $v"; fi
done
for t in cortexm:mps2-an386 riscv_virt:virt; do
  kind=${t%%:*}; m=${t#*:}
  if "$Q" new "$kind" "smoke_$kind" --dir "$tmp" >/dev/null 2>&1 \
     && out=$("$Q" run bash -c "cd '$tmp/smoke_$kind' && make -s && bash \"\$QEMU_BOX_LIB/run-elf.sh\" $m build/smoke_$kind.elf --timeout 20" 2>&1) \
     && grep -q "smoke_$kind: hello" <<<"$out"; then ok "template $kind: build + run on $m"
  else bad "template $kind:"; tail -5 <<<"${out:-}" | sed 's/^/      /'; fi
done
for kind in cortexm0_microbit cortexm3_stm32 stm32f4_usart aarch64_virt riscv64_virt sifive_e \
            unit_tests_cm4 gdb_session riscv_irq cortexm_irq qmp_script; do
  if "$Q" new "$kind" "s_$kind" --dir "$tmp" >/dev/null 2>&1 \
     && out=$("$Q" run bash -c "cd '$tmp/s_$kind' && make -s test" 2>&1) && grep -q "s_$kind: PASS" <<<"$out"; then ok "template $kind: make test"
  else bad "template $kind:"; tail -5 <<<"${out:-}" | sed 's/^/      /'; fi
done
if v=$("$Q" gdb --version 2>&1 | head -1) && grep -q lldb <<<"$v"; then ok "debugger: $v"; else bad "debugger: $v"; fi
echo "smoke: $pass ok, $failn failed"
[ "$failn" -eq 0 ]
