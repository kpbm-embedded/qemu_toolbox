#!/usr/bin/env python3
"""@NAME@: QMP client (stdlib only). usage: qmp_client.py <socket> <counter_addr_hex> <out_dir>

Connects to QEMU's QMP socket, pauses the guest, reads `counter` with pmemsave, resumes, reads
it again and quits QEMU. Extend main() with any QMP command (query-cpus-fast, system_reset, ...).
"""
import json
import socket
import sys
import time


def connect(path: str):
    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    s.settimeout(10)
    for _ in range(100):
        try:
            s.connect(path)
            break
        except OSError:
            time.sleep(0.1)
    f = s.makefile("rw")
    json.loads(f.readline())  # greeting
    return f


def cmd(f, name: str, **args):
    f.write(json.dumps({"execute": name, **({"arguments": args} if args else {})}) + "\n")
    f.flush()
    while True:
        msg = json.loads(f.readline())
        if "event" in msg:
            continue
        if "error" in msg:
            raise RuntimeError(f"{name}: {msg['error']}")
        return msg["return"]


def read_u32(f, addr: int, path: str) -> int:
    cmd(f, "pmemsave", val=addr, size=4, filename=path)
    with open(path, "rb") as fh:
        return int.from_bytes(fh.read(4), "little")


def main() -> int:
    f = connect(sys.argv[1])
    addr, out = int(sys.argv[2], 16), sys.argv[3]
    cmd(f, "qmp_capabilities")
    time.sleep(0.2)
    cmd(f, "stop")
    status = cmd(f, "query-status")["status"]
    a = read_u32(f, addr, f"{out}/c1.bin")
    cmd(f, "cont")
    time.sleep(0.2)
    b = read_u32(f, addr, f"{out}/c2.bin")
    cmd(f, "quit")
    ok = status == "paused" and b > a > 0
    print(f"status while stopped: {status}; counter {a} -> {b}")
    print("@NAME@: PASS" if ok else "@NAME@: FAIL")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
