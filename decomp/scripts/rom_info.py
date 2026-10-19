#!/usr/bin/env python3
"""Print header fields and checksums for local Game Boy ROM images."""

import hashlib
import sys
import zlib
from pathlib import Path

CART_TYPES = {
    0x00: "ROM",
    0x01: "MBC1",
    0x02: "MBC1+RAM",
    0x03: "MBC1+RAM+BATTERY",
    0x05: "MBC2",
    0x06: "MBC2+BATTERY",
    0x08: "ROM+RAM",
    0x09: "ROM+RAM+BATTERY",
    0x0F: "MBC3+TIMER+BATTERY",
    0x10: "MBC3+TIMER+RAM+BATTERY",
    0x11: "MBC3",
    0x12: "MBC3+RAM",
    0x13: "MBC3+RAM+BATTERY",
    0x19: "MBC5",
    0x1A: "MBC5+RAM",
    0x1B: "MBC5+RAM+BATTERY",
    0x1C: "MBC5+RUMBLE",
    0x1D: "MBC5+RUMBLE+RAM",
    0x1E: "MBC5+RUMBLE+RAM+BATTERY",
    0x20: "MBC6",
    0x22: "MBC7+SENSOR+RUMBLE+RAM+BATTERY",
    0xFC: "POCKET CAMERA",
    0xFD: "BANDAI TAMA5",
    0xFE: "HuC3",
    0xFF: "HuC1+RAM+BATTERY",
}

RAM_SIZES = {
    0x00: "none",
    0x01: "2 KiB",
    0x02: "8 KiB",
    0x03: "32 KiB",
    0x04: "128 KiB",
    0x05: "64 KiB",
}


def header_checksum(data: bytes) -> int:
    total = 0
    for byte in data[0x134:0x14D]:
        total = (total - byte - 1) & 0xFF
    return total


def global_checksum(data: bytes) -> int:
    return (sum(data) - data[0x14E] - data[0x14F]) & 0xFFFF


def cgb_flag(value: int) -> str:
    if value == 0xC0:
        return "CGB only"
    if value == 0x80:
        return "CGB enhanced"
    return f"0x{value:02X}"


def describe(path: Path) -> bool:
    data = path.read_bytes()
    if len(data) < 0x150:
        print(f"{path}: too small to be a Game Boy ROM", file=sys.stderr)
        return False

    title = data[0x134:0x13F].split(b"\x00", 1)[0].decode("ascii", "replace")
    manufacturer = data[0x13F:0x143].decode("ascii", "replace")
    licensee = data[0x144:0x146].decode("ascii", "replace")
    cart = data[0x147]
    rom_code = data[0x148]
    ram_code = data[0x149]
    stored_header = data[0x14D]
    stored_global = int.from_bytes(data[0x14E:0x150], "big")
    calc_header = header_checksum(data)
    calc_global = global_checksum(data)
    rom_kib = 32 << rom_code

    print(path)
    print(f"  size            {len(data)} bytes")
    print(f"  sha1            {hashlib.sha1(data).hexdigest()}")
    print(f"  md5             {hashlib.md5(data).hexdigest()}")
    print(f"  crc32           {zlib.crc32(data) & 0xFFFFFFFF:08x}")
    print(f"  title           {title}")
    print(f"  manufacturer    {manufacturer}")
    print(f"  cgb flag        {cgb_flag(data[0x143])}")
    print(f"  licensee        {licensee}")
    print(f"  cartridge       0x{cart:02X} {CART_TYPES.get(cart, 'unknown')}")
    print(f"  rom             0x{rom_code:02X} ({rom_kib} KiB)")
    print(f"  ram             0x{ram_code:02X} ({RAM_SIZES.get(ram_code, 'unknown')})")
    print(f"  destination     {'Japan' if data[0x14A] == 0 else 'overseas'}")
    print(f"  version         {data[0x14C]}")
    print(f"  header checksum 0x{stored_header:02X} ({'ok' if stored_header == calc_header else 'BAD'})")
    print(f"  global checksum 0x{stored_global:04X} ({'ok' if stored_global == calc_global else 'BAD'})")
    return stored_header == calc_header and stored_global == calc_global


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print("usage: rom_info.py ROM [ROM ...]", file=sys.stderr)
        return 2
    ok = True
    for name in argv[1:]:
        path = Path(name)
        if not path.is_file():
            print(f"{path}: not found", file=sys.stderr)
            ok = False
            continue
        if not describe(path):
            ok = False
        print()
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
