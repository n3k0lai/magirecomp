"""UnpackBytes stream format (bank 0, src/unpack_bytes.asm)."""

def decode(rom, off, limit=None):
    """Decode a stream at ROM offset off. Return (data, end_offset, ops) or None."""
    out = bytearray(); ops = []; p = off
    bank_end = (off // 0x4000 + 1) * 0x4000 if off >= 0x4000 else 0x4000
    while True:
        if p >= bank_end: return None
        c = rom[p]; kind = c >> 6; n = c & 0x3F
        if kind in (0, 2):
            if n == 0:
                ops.append(('end', c)); p += 1; break
            if kind == 0:
                lit = rom[p+1:p+1+n]
                if p + 1 + n > bank_end: return None
                out += lit; ops.append(('copy', n)); p += 1 + n
            else:
                out += bytes([rom[p+1]]) * n; ops.append(('fill', n)); p += 2
        else:
            n = (n << 8) | rom[p+1]
            if n == 0: return None  # 65536 wrap, never data
            if kind == 1:
                if p + 2 + n > bank_end: return None
                out += rom[p+2:p+2+n]; ops.append(('copyl', n)); p += 2 + n
            else:
                out += bytes([rom[p+2]]) * n; ops.append(('filll', n)); p += 3
        if limit and len(out) > limit: return None
    return bytes(out), p, ops


def encode(data, minrun=2, absorb_after_single=False):
    """Greedy encoder: runs of minrun or more become fills, the rest copies.

    absorb_after_single is the retail rule seen in most other streams: a run of
    exactly two right after a one-byte literal is copied with it, not filled
    ("c1 f2 c4" becomes "c7")."""
    out = bytearray(); lit = bytearray(); i = 0
    def flush():
        j = 0
        while j < len(lit):
            k = len(lit) - j
            if k <= 0x3F:
                out.append(k); out.extend(lit[j:]); j += k
            else:
                k = min(k, 0x3FFF); out.extend(bytes([0x40 | k >> 8, k & 0xFF])); out.extend(lit[j:j+k]); j += k
        lit.clear()
    while i < len(data):
        r = 1
        while i + r < len(data) and data[i + r] == data[i]: r += 1
        if r >= minrun and not (absorb_after_single and r == 2 and len(lit) == 1):
            flush(); n = r
            while n:
                k = min(n, 0x3FFF)
                if k <= 0x3F: out += bytes([0x80 | k, data[i]])
                else: out += bytes([0xC0 | k >> 8, k & 0xFF, data[i]])
                n -= k
        else:
            lit += data[i:i + r]
        i += r
    flush(); out.append(0)
    return bytes(out)


def ops_tokens(rom, off):
    """Exact command list of a stream: c/C copy short/long, f/F fill, then end."""
    toks = []; p = off
    while True:
        c = rom[p]; kind = c >> 6; n = c & 0x3F
        if kind in (0, 2) and n == 0:
            toks.append(f"end{c:02X}"); return toks
        if kind == 0: toks.append(f"c{n}"); p += 1 + n
        elif kind == 2: toks.append(f"f{n}"); p += 2
        else:
            n = (n << 8) | rom[p + 1]
            if kind == 1: toks.append(f"C{n}"); p += 2 + n
            else: toks.append(f"F{n}"); p += 3


def encode_ops(data, toks):
    out = bytearray(); i = 0
    for t in toks:
        if t.startswith("end"):
            out.append(int(t[3:], 16)); break
        k, n = t[0], int(t[1:])
        if k == "c": out.append(n); out += data[i:i + n]
        elif k == "C": out += bytes([0x40 | n >> 8, n & 0xFF]); out += data[i:i + n]
        elif k == "f": out += bytes([0x80 | n, data[i]])
        else: out += bytes([0xC0 | n >> 8, n & 0xFF, data[i]])
        if k in "fF" and any(b != data[i] for b in data[i:i + n]):
            raise ValueError(f"fill {n} at {i} is not a run")
        i += n
    if i != len(data):
        raise ValueError(f"ops cover {i} of {len(data)} bytes")
    return bytes(out)


def copy_all(data):
    """One copy command (long form past 63 bytes), then the terminator."""
    n = len(data)
    head = bytes([n]) if n <= 0x3F else bytes([0x40 | n >> 8, n & 0xFF])
    return head + data + b"\0"


MODES = {
    "greedy": lambda d: encode(d),
    "greedy1": lambda d: encode(d, absorb_after_single=True),
    "copy": copy_all,
}


def map_header(w, rows, n):
    """7-byte header read by UnpackMapHeaderIntoWRAMBank3: stride, stride*9,
    camera column limit (stride-11), camera row limit, map size."""
    m = w * 9
    return bytes([w, m & 0xFF, m >> 8, (w - 11) & 0xFF, rows, n & 0xFF, n >> 8])


def block_header(w, n):
    """3-byte header read by UnpackBlockIntoWRAMBank5: width, decoded length."""
    return bytes([w, n & 0xFF, n >> 8])


def width_for(n):
    for w in (32, 20, 16):
        if n % w == 0: return w
    return 16


def write_tmap(path, bank, addr, data, toks, mode, header=None):
    """header is None, ("map", w, rows) or ("block", w)."""
    w = header[1] if header else width_for(len(data))
    kind = {None: "UnpackBytes stream", "map": "Map record (7-byte header, then stream)",
            "block": "Block record (3-byte header, then stream)"}[header and header[0]]
    lines = [f"; {kind}, bank ${bank:02X} at ${addr:04X}.",
             f"; {len(data)} bytes decoded, shown {w} per row."]
    if header: lines.append("hdr " + " ".join(str(x) for x in header))
    lines.append("ops " + (mode if mode else " ".join(toks)))
    for i in range(0, len(data), w):
        lines.append(" ".join(f"{b:02X}" for b in data[i:i + w]))
    path.write_text("\n".join(lines) + "\n")


def read_tmap(path):
    toks = None; data = bytearray(); hdr = None
    for line in path.read_text().splitlines():
        line = line.split(";", 1)[0].strip()
        if not line: continue
        if line.startswith("hdr "):
            hdr = line[4:].split(); continue
        if line.startswith("ops "):
            toks = line[4:].split(); continue
        data += bytes(int(x, 16) for x in line.split())
    data = bytes(data)
    if len(toks) == 1 and toks[0] in MODES:
        body = MODES[toks[0]](data)
    else:
        body = encode_ops(data, toks)
    if hdr is None:
        return body
    if hdr[0] == "map":
        w, rows = int(hdr[1]), int(hdr[2])
        return map_header(w, rows, w * (rows + 10)) + body
    if hdr[0] == "block":
        return block_header(int(hdr[1]), len(data)) + body
    raise ValueError(f"unknown hdr {hdr}")
