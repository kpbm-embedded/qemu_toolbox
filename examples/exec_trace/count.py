#!/usr/bin/env python3
"""Per-function instruction counts from a QEMU exec log (-d exec,nochain, one insn per TB).

usage: count.py <nm.txt from llvm-nm -S> <exec.log>   -> "<count> <function>" lines, largest first
"""
import re
import sys
from collections import Counter


def main() -> int:
    funcs = []
    for line in open(sys.argv[1]):
        parts = line.split()
        if len(parts) == 4 and parts[2] in "tT":
            start, size = int(parts[0], 16), int(parts[1], 16)
            funcs.append((start, start + size, parts[3]))
    counts: Counter = Counter()
    pc_re = re.compile(r"^Trace \d+: 0x[0-9a-f]+ \[[0-9a-f]+/([0-9a-f]+)/")
    for line in open(sys.argv[2]):
        m = pc_re.match(line)
        if not m:
            continue
        pc = int(m.group(1), 16)
        name = next((n for s, e, n in funcs if s <= pc < e), "?")
        counts[name] += 1
    for name, n in counts.most_common():
        print(n, name)
    return 0


if __name__ == "__main__":
    sys.exit(main())
