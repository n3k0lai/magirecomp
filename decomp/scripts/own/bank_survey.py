#!/usr/bin/env python3
"""Classify ROM banks $0D-$7F by byte statistics and find who reads them.

Each 256-byte block gets one class:
  padding   one repeated byte
  oam       metasprite records (y, x, tile, attr) with y/x in $E0-$F8/$00-$18
  text      script bytecode with ASCII runs (>= 30% printable, 'e' and ' ' common)
  tiles     raw 2bpp tiles (plane-pair correlation, many $00/$FF/$7F)
  tilemap   low byte range (most bytes < $40), repeated rows
  packed    high entropy with $80+ command bytes (compressed graphics/maps)
  other     none of the above
Readers come from lifted code (a bank constant loaded within five lines
before a rROMB0 write or a banked call) and from far-pointer tables
(runs of four or more bank/lo/hi triples) in banks 0-12 and $4C.

Usage: bank_survey.py [--md out.md]
"""
import collections, glob, math, re, sys

ROM = "roms/magination.gbc"
CLASSES = ["padding", "oam", "text", "tiles", "tilemap", "packed", "other"]


def entropy(x):
    c = collections.Counter(x)
    return -sum(v / len(x) * math.log2(v / len(x)) for v in c.values())


def classify(x):
    if len(set(x)) == 1:
        return "padding"
    n = len(x)
    pr = sum(1 for c in x if 0x61 <= c <= 0x7A or c == 0x20) / n
    if (pr >= 0.22 and x.count(0x20) >= 6) or (pr >= 0.12 and x.count(0x45) >= 0.03 * n and x.count(0x20) >= 3):
        return "text"
    def sm(v):
        return v >= 0xC0 or v <= 0x30
    i = got = neg = 0
    while i + 4 <= n:
        r = x[i:i + 4]
        if sm(r[0]) and sm(r[1]) and r[2] != 0 and r[3] < 0x10:
            got += 4
            neg += r[0] >= 0xC0 or r[1] >= 0xC0
            i += 4
        else:
            i += 1
    best = got / n if neg * 4 >= 0.25 * got else 0
    if best >= 0.6:
        return "oam"
    h = entropy(x)
    if sum(1 for c in x if c < 0x40 or c == 0xF0) / n >= 0.85 and h < 5.2:
        return "tilemap"
    if sum(1 for c in x if c in (0x82, 0x08, 0xEF)) / n >= 0.08:
        return "packed"
    rows = sum(bin(x[i] ^ x[i + 2]).count("1") for i in range(0, n - 2, 2)) / (n / 2)
    if rows < 2.7 and h > 2.5:
        return "tiles"
    return "other"


def code_readers():
    hits = collections.defaultdict(set)
    for f in glob.glob("src/*.asm"):
        L = open(f).read().splitlines()
        for i, l in enumerate(L):
            m = re.match(r"\s*ld (a|e|b|d|c|h|l), \$([0-9A-Fa-f]{2})\b", l)
            if not m:
                continue
            v = int(m[2], 16)
            if not 0x0D <= v <= 0x7F:
                continue
            win = "\n".join(L[i + 1:i + 6])
            if re.search(r"rROMB0|\$2[01]00\]|CallBanked|Banked|MapRomBank", win, re.I):
                hits[v].add(f.split("/")[-1][:-4])
    return hits


def table_readers(d):
    hits = collections.defaultdict(set)
    banks = list(range(0, 13)) + [0x4C]
    for b in banks:
        base = b * 0x4000
        i = base
        while i < base + 0x4000 - 12:
            def ok(j, order):
                if order == 0:
                    bk, lo, hi = d[j], d[j + 1], d[j + 2]
                else:
                    lo, hi, bk = d[j], d[j + 1], d[j + 2]
                return 0x0D <= bk <= 0x7F and 0x40 <= hi <= 0x7F
            found = False
            for order in (0, 1):
                k = 0
                while ok(i + 3 * k, order) and i + 3 * k + 3 < base + 0x4000:
                    k += 1
                if k >= 4:
                    tbl = [d[i + 3 * t + (0 if order == 0 else 2)] for t in range(k)]
                    if len(set(tbl)) <= max(2, k // 2):
                        cpu = i - base + (0x4000 if b else 0)
                        for bk in set(tbl):
                            hits[bk].add(f"tbl {b:02X}:{cpu:04X}")
                        i += 3 * k
                        found = True
                        break
            if not found:
                i += 1
    return hits


def survey():
    d = open(ROM, "rb").read()
    cr, tr = code_readers(), table_readers(d)
    rows = []
    for b in range(0x0D, 0x80):
        x = d[b * 0x4000:(b + 1) * 0x4000]
        t = len(x)
        while t and x[t - 1] == 0:
            t -= 1
        tail = 0x4000 - t
        cnt = collections.Counter()
        for o in range(0, t, 256):
            blk = x[o:min(o + 256, t)]
            cnt[classify(blk) if len(blk) >= 32 else "other"] += len(blk)
        cnt["padding"] += tail
        top = cnt.most_common(1)[0]
        share = top[1] / 0x4000
        conf = "high" if share >= 0.8 else "medium" if share >= 0.55 else "low"
        rows.append((b, cnt, conf, sorted(cr.get(b, ())), sorted(tr.get(b, ())), tail))
    return rows


# Family by inspection. The block classifier above is noisy on its own
# (OAM records with $80 terminators, RLE maps, script bytecode with little
# text), so each bank's family comes from a signature checked by hand.
# conf: high = signature seen at several offsets and the block stats agree;
# medium = signature seen, stats mixed; low = guess.
FAM = {}
def _f(banks, fam, conf, ev):
    for b in banks:
        FAM[b] = (fam, conf, ev)
_f([0x0D], "graphics", "medium", "2bpp tiles, sparse (UI/font-like), 2.8 KB zero tail")
_f([0x0E, 0x0F, 0x10, 0x11, 0x25], "anim-scripts", "high", "a few KB of QueueSpriteList sprite lists at $4000, then sprite animation script bytecode ($46/$4C/$4D)")
_f([0x40], "anim-scripts", "low", "records like the animation scripts, no sprite-list head")
_f([0x20], "tables", "medium", "5-byte records ($FB $42 ...), metasprite-like at the head")
_f([0x21], "tables", "medium", "pointer tables (lo, $43, $01, $23 runs)")
_f(list(range(0x12, 0x20)) + [0x22, 0x23, 0x28, 0x2A, 0x2B, 0x2E, 0x2F], "scripts+text", "high",
   "script opcodes ($45 ... records) with ASCII dialogue, $FF/$FE line breaks")
_f([0x31], "scripts+text", "low", "dense records plus a leftover build-tool listing (\"p.dat eae3f9ae ...\")")
_f([0x24, 0x27, 0x41, 0x44, 0x45, 0x48, 0x4E, 0x4F, 0x50] + list(range(0x52, 0x61)), "graphics", "medium",
   "raw 2bpp tiles (row/plane correlation, $00/$FF/$7F-heavy)")
_f([0x26, 0x46, 0x51] + list(range(0x61, 0x7D)), "rle-tilemaps", "medium",
   "run codes $8n count byte ($82 $5E $02 ...) over tile ids: compressed tilemaps/attr maps")
_f([0x43, 0x49, 0x4A, 0x4B, 0x4D], "rle-tilemaps", "low", "$8n run codes at the head ($89 $00 $02 ...)")
_f(list(range(0x32, 0x37)) + list(range(0x38, 0x3D)), "music", "high",
   "songs: SongList in bank $30 (InstallSoundIndex); fully decoded by gen_music.py")
_f([0x42], "tilemaps", "medium", "font layout: ASCII-ordered tile ids $30-$7F in rows of 20")
_f([0x29], "rle-tilemaps", "low", "4.5 KB of records at the head, rest zero")
_f([0x30], "sound", "high", "sound driver (lifted) + music data, see music-format.md")
_f([0x4C], "scripts+text", "high", "battle scripts and text (data-script worker)")
_f([0x2C, 0x2D, 0x37, 0x3D, 0x3E, 0x3F, 0x47, 0x7D, 0x7E, 0x7F], "padding", "high", "all $00")

NOTES = {
    0x0D: "1bpp-style font/UI tiles", 0x26: "repeating 4-byte records ($94 $20 $8C $60): attribute/tilemap runs",
    0x29: "mostly padding; head looks like packed records", 0x30: "sound driver + sfx streams (see music-format.md)",
    0x31: "dense records ($FF/$FE delimiters): likely map/event tables", 0x42: "font layout tilemap (ASCII tile ids)",
    0x4C: "battle scripts and text (data-script worker)",
}


def md(rows):
    fam_tot = collections.Counter()
    out = ["# Bank survey, $0D-$7F", "",
           "Generated by `scripts/own/bank_survey.py`. \"family\" is set per bank from a",
           "byte signature checked by hand (see FAM in the script). \"pad\" is the zero",
           "tail, which the scaffold now builds with `ds` instead of INCBIN. \"blocks\" is",
           "the 256-byte block classifier's top two classes, for a second opinion.",
           "Readers are bank constants in lifted code and far-pointer tables in banks",
           "0-12 and $4C. Most script and map banks are reached through bank bytes",
           "stored in script records, which a static scan cannot see, so \"none found\"",
           "does not mean unused.", "",
           "| bank | family | data B | pad B | blocks | conf | readers | evidence |",
           "|---|---|---|---|---|---|---|---|"]
    for b, cnt, conf, cr, tr, tail in rows:
        fam, fconf, ev = FAM.get(b, ("unknown", "low", ""))
        data = 0x4000 - tail if fam != "padding" else 0
        fam_tot[fam] += data
        fam_tot["padding"] += 0x4000 - data
        blk = ", ".join(f"{k} {v // 1024}K" for k, v in cnt.most_common(3) if k != "padding")[:40]
        rd = ", ".join(cr[:3] + tr[:3]) or "none found"
        out.append(f"| ${b:02X} | {fam} | {data} | {0x4000 - data} | {blk} | {fconf} | {rd} | {ev} |")
    total = sum(fam_tot.values())
    out += ["", f"## Totals for $0D-$7F ({total} bytes)", "", "| family | bytes | share of $0D-$7F | share of ROM |", "|---|---|---|---|"]
    for f, v in fam_tot.most_common():
        out.append(f"| {f} | {v} | {100 * v / total:.1f}% | {100 * v / 0x200000:.1f}% |")
    return "\n".join(out) + "\n"


if __name__ == "__main__":
    rows = survey()
    text = md(rows)
    if "--md" in sys.argv:
        open(sys.argv[sys.argv.index("--md") + 1], "w").write(text)
    else:
        print(text)
