#!/usr/bin/env bash
# Every qemu-box command in --dry-run mode (no downloads, builds, moves or launches),
# plus shellcheck of every script. Usage: tests/test_dry_run.sh
set -uo pipefail
HERE=$(cd "$(dirname "$0")/.." && pwd -P)
Q="$HERE/qemu-box"
pass=0; failn=0
check() { # name expected-regex cmd...
  local name=$1 re=$2; shift 2
  local out rc
  out=$(timeout 300 "$@" 2>&1); rc=$?
  if [ "$rc" -eq 0 ] && grep -qE -- "$re" <<<"$out"; then
    printf 'ok    %s\n' "$name"; pass=$((pass+1))
  else
    printf 'FAIL  %s (rc=%s)\n%s\n' "$name" "$rc" "$(tail -5 <<<"$out" | sed 's/^/      /')"; failn=$((failn+1))
  fi
}
check help        'usage: \./qemu-box'                     "$Q" help
check where       '^qemu-arm '                             "$Q" where
check bootstrap   'pixi .*install'                         "$Q" --dry-run bootstrap
check install     'examples build: mps2_semihosting|\+ \(cd .*example\.sh build' "$Q" --dry-run install
check update      'curl https://api.github.com/repos/xpack-dev-tools/qemu-arm-xpack' "$Q" --dry-run update
check update-env  '\+ timeout .* update'                   "$Q" --dry-run update --env
check clean       'nothing to clean|dry run: re-run with --yes' "$Q" clean
check clean-all   'dry run: re-run with --yes'             "$Q" clean --all
check status      '^  qemu-arm '                           "$Q" status
check doctor      'doctor: [0-9]+ ok'                      bash -c "'$Q' doctor || true"
check shell       '\+ true'                                "$Q" --dry-run shell -- true
check run         '\+ qemu-system-arm --version'           "$Q" --dry-run run qemu-system-arm --version
check test        'test_smoke\.sh'                         "$Q" --dry-run test
check new         '\+ copy .*templates/cortexm'            "$Q" --dry-run new cortexm demo --dir /nonexistent
check ex-list     'mps2_semihosting .*semihosting'         "$Q" examples list
check ex-run      'example\.sh run'                        "$Q" --dry-run examples run riscv_virt_uart
check ex-build    'example\.sh build'                      "$Q" --dry-run examples build
check ex-test     'example\.sh test'                       "$Q" --dry-run examples test
check native      'qemu-system-riscv64 install/qemu-riscv' "$Q" --dry-run native
check relocate    'pixi env already matches|re-creating'   "$Q" --dry-run relocate
check pack        '\+ tar .*-cf .*qemu-box_'               "$Q" --dry-run pack
check machines    '\+ qemu-system-riscv32 -M help'         "$Q" --dry-run machines riscv
check run-elf     '\+ lib/run-elf\.sh virt x\.elf'         "$Q" --dry-run run-elf virt x.elf
check gdb         '\+ lldb --version'                      "$Q" --dry-run gdb --version
check qemu        '\+ qemu-system-arm -M help'             "$Q" --dry-run qemu qemu-system-arm -M help
check run-elf-usage 'usage: run-elf.sh'                    bash -c "bash '$HERE/lib/run-elf.sh' 2>&1; true"
check new-qmp     '\+ copy .*templates/qmp_script'         "$Q" --dry-run new qmp_script demo --dir /nonexistent
check python-syntax 'parsed [0-9]+'                        bash -c "cd '$HERE' && python3 -c 'import ast,sys; [ast.parse(open(f).read(), f) for f in sys.argv[1:]]; print(\"parsed\", len(sys.argv) - 1)' examples/*/*.py templates/*/*.py"
if command -v shellcheck >/dev/null; then
  mapfile -t files < <(cd "$HERE" && { echo qemu-box; ls lib/*.bash lib/*.sh tests/*.sh examples/*/example.sh; })
  if out=$(cd "$HERE" && shellcheck -x "${files[@]}" 2>&1); then printf 'ok    shellcheck (%s files)\n' "${#files[@]}"; pass=$((pass+1))
  else printf 'FAIL  shellcheck\n%s\n' "$(head -30 <<<"$out")"; failn=$((failn+1)); fi
else printf 'skip  shellcheck (not installed)\n'; fi
echo "dry-run: $pass ok, $failn failed"
[ "$failn" -eq 0 ]
