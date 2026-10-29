#!/usr/bin/env python3
"""Minimal QMP client (stdlib only): drive a running QEMU through its JSON control socket.

usage: qmp.py <socket> <magic_addr> <heartbeat_addr> <dump_dir>
Stops the VM, reads two globals with pmemsave (address from the ELF symbol table), checks that
the counter does not move while stopped and moves again after cont, then quits QEMU.
"""
import json
import socket
import sys
import time


class QMP:
    def __init__(self, path: str, timeout: float = 10.0) -> None:
        self.s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        self.s.settimeout(timeout)
        for _ in range(100):
            try:
                self.s.connect(path)
                break
            except OSError:
                time.sleep(0.1)
        self.f = self.s.makefile("rw")
        greeting = json.loads(self.f.readline())
        print("QEMU", "%(major)d.%(minor)d.%(micro)d" % greeting["QMP"]["version"]["qemu"])
        self.cmd("qmp_capabilities")

    def cmd(self, name: str, **args):
        self.f.write(json.dumps({"execute": name, "arguments": args} if args else {"execute": name}) + "\n")
        self.f.flush()
        while True:
            msg = json.loads(self.f.readline())
            if "event" in msg:
                print("event", msg["event"])
                continue
            if "error" in msg:
                raise RuntimeError(f"{name}: {msg['error']}")
            return msg["return"]


def read_u32(q: QMP, addr: int, path: str) -> int:
    q.cmd("pmemsave", val=addr, size=4, filename=path)
    with open(path, "rb") as f:
        return int.from_bytes(f.read(4), "little")


def main() -> int:
    sock, magic_addr, hb_addr, out = sys.argv[1], int(sys.argv[2], 16), int(sys.argv[3], 16), sys.argv[4]
    q = QMP(sock)
    print("status", q.cmd("query-status")["status"])
    time.sleep(0.3)
    q.cmd("stop")
    print("status", q.cmd("query-status")["status"])
    magic = read_u32(q, magic_addr, f"{out}/magic.bin")
    a = read_u32(q, hb_addr, f"{out}/hb1.bin")
    time.sleep(0.2)
    b = read_u32(q, hb_addr, f"{out}/hb2.bin")
    print(f"magic 0x{magic:08x}, heartbeat {a} -> {b} while stopped")
    q.cmd("cont")
    time.sleep(0.3)
    c = read_u32(q, hb_addr, f"{out}/hb3.bin")
    print(f"heartbeat {c} after cont")
    regs = q.cmd("human-monitor-command", **{"command-line": "info registers"})
    print("pc line:", next((ln.strip() for ln in regs.splitlines() if ln.strip().startswith("pc")), "?"))
    q.cmd("quit")
    ok = magic == 0xC0FFEE11 and a == b and c > b
    print("QMP checks", "ok" if ok else "FAILED")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
