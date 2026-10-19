#!/usr/bin/env python3
"""Progress visualizer for the README, in the style of Alchemy's progress chart.

    progress_visual.py --out DIR [--history FILE] [--readme PATH] [--commit SHA]

Counts DONE exactly as `make progress` does (AGENTS.md C1: committed source
outside an INCBIN; INCBIN counts 0; header left out) and draws it:

  DIR/progress.svg  the headline: DONE %, split into code and data, as a bar
  DIR/chart.svg     DONE over time, with code and data where they were recorded
  DIR/banks.svg     every ROM bank as a cell, filled by how much of it is DONE
  DIR/badge.json    a shields.io endpoint badge with the DONE %

--history is a TSV (date, commit, done, code, data, total). The current count
is appended when it differs from the last row, so the chart climbs run by run.
--readme rewrites the block between the progress markers in that file.

No ROM is needed: the count reads only the committed text. Without
roms/magination.gbc the image size is the retail size (2 MiB).
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import re
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import progress as P  # noqa: E402
from lib import rom as R  # noqa: E402

REPO = "n3k0lai/magirecomp"
RAW = f"https://raw.githubusercontent.com/{REPO}/progress"
START, END = "<!-- decomp-progress:start -->", "<!-- decomp-progress:end -->"
FIELDS = ["date", "commit", "done", "code", "data", "total"]

INK, MUTED, GRID, PAPER = "#2b2233", "#7a6f80", "#e9e3ec", "#fffdfb"
CODE, DATA, TODO = "#f2a93b", "#9c5a1a", "#f6dcdc"  # bright, darker, light rose
FONT = "font-family='-apple-system,Segoe UI,Helvetica,Arial,sans-serif'"


@dataclass
class _NoRom(R.Project):
    @property
    def size(self) -> int:
        return self.rom.stat().st_size if self.rom.exists() else P.ROM_SIZE


def count() -> dict:
    p = R.project("magination")
    p = _NoRom(**{k: getattr(p, k) for k in p.__dataclass_fields__})
    m = P.measure(p, R.scaffold_text(p))
    t = m["total"]
    return {"done": t["done"], "code": t["code"], "data": t["data"] + t["fill"],
            "total": t["total"], "rows": m["rows"]}


def head() -> str:
    r = subprocess.run(["git", "rev-parse", "--short=8", "HEAD"], cwd=R.ROOT,
                       capture_output=True, text=True)
    return r.stdout.strip() or "unknown"


def pct(a: int, b: int) -> float:
    return 100.0 * a / b if b else 0.0


# ---------------------------------------------------------------- history

def read_history(path: Path) -> list[dict]:
    if not path.exists():
        return []
    lines = path.read_text().splitlines()
    cols = lines[0].split("\t")
    out = []
    for line in lines[1:]:
        if not line.strip():
            continue
        row = dict(zip(cols, line.split("\t")))
        for k in ("done", "code", "data", "total"):
            row[k] = int(row[k]) if row.get(k) not in (None, "") else None
        out.append(row)
    return out


def write_history(path: Path, rows: list[dict]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    body = ["\t".join(FIELDS)]
    for r in rows:
        body.append("\t".join("" if r.get(k) is None else str(r[k]) for k in FIELDS))
    path.write_text("\n".join(body) + "\n")


def record(rows: list[dict], now: dict, commit: str) -> list[dict]:
    last = rows[-1] if rows else None
    if last and (last["done"], last["code"], last["data"]) == (now["done"], now["code"], now["data"]):
        return rows
    stamp = dt.datetime.now().astimezone().isoformat(timespec="seconds")
    return rows + [{"date": stamp, "commit": commit, "done": now["done"], "code": now["code"],
                    "data": now["data"], "total": now["total"]}]


# ---------------------------------------------------------------- drawing

def svg(w: int, h: int, body: list[str], title: str) -> str:
    return (f"<svg xmlns='http://www.w3.org/2000/svg' width='{w}' height='{h}' viewBox='0 0 {w} {h}' "
            f"role='img' aria-label='{title}'><title>{title}</title>"
            f"<rect width='{w}' height='{h}' rx='10' fill='{PAPER}' stroke='{GRID}'/>"
            + "".join(body) + "</svg>\n")


def text(x, y, s, size=13, fill=INK, anchor="start", weight="normal") -> str:
    return (f"<text x='{x:.1f}' y='{y:.1f}' {FONT} font-size='{size}' fill='{fill}' "
            f"text-anchor='{anchor}' font-weight='{weight}'>{s}</text>")


def headline_svg(now: dict, commit: str) -> str:
    w, h = 838, 150
    done, code, data, total = now["done"], now["code"], now["data"], now["total"]
    x0, bw, by, bh = 24, w - 48, 74, 26
    cw, dw = bw * code / total, bw * data / total
    b = [
        text(24, 38, "Magi Nation (USA)", 20, weight="bold"),
        text(w - 24, 40, f"{pct(done, total):.2f}% DONE", 26, CODE, "end", "bold"),
        text(24, 60, f"{done:,} of {total:,} bytes rebuilt from source that matches the cartridge "
                     f"(INCBIN counts 0)", 12, MUTED),
        f"<rect x='{x0}' y='{by}' width='{bw}' height='{bh}' rx='6' fill='{TODO}'/>",
        f"<clipPath id='c'><rect x='{x0}' y='{by}' width='{bw}' height='{bh}' rx='6'/></clipPath>",
        f"<g clip-path='url(#c)'><rect x='{x0}' y='{by}' width='{cw:.2f}' height='{bh}' fill='{CODE}'/>"
        f"<rect x='{x0 + cw:.2f}' y='{by}' width='{dw:.2f}' height='{bh}' fill='{DATA}'/></g>",
    ]
    ly = 126
    for i, (label, colour, n) in enumerate((("code", CODE, code), ("data", DATA, data),
                                             ("still INCBIN", TODO, total - done))):
        lx = 24 + i * 250
        b.append(f"<rect x='{lx}' y='{ly - 11}' width='12' height='12' rx='3' fill='{colour}'/>")
        b.append(text(lx + 18, ly, f"{label} {n:,} B ({pct(n, total):.2f}%)", 12))
    b.append(text(w - 24, ly, f"@ {commit}", 11, MUTED, "end"))
    return svg(w, h, b, f"Magi Nation decomp: {pct(done, total):.2f}% DONE")


def parse_date(s: str) -> dt.datetime:
    return dt.datetime.fromisoformat(s)


def chart_svg(rows: list[dict]) -> str:
    w, h = 838, 300
    l, r, t, btm = 56, 24, 60, 40
    pw, ph = w - l - r, h - t - btm
    b = [text(24, 28, "DONE over time", 15, weight="bold")]
    for i, (label, colour) in enumerate((("DONE", INK), ("code", CODE), ("data", DATA))):
        lx = w - 24 - (2 - i) * 80 - 60
        b.append(f"<rect x='{lx}' y='19' width='12' height='12' rx='3' fill='{colour}'/>")
        b.append(text(lx + 18, 29, label, 12))
    pts = [(parse_date(x["date"]), x) for x in rows if x.get("done") is not None]
    if not pts:
        return svg(w, h, b, "DONE over time")
    t0, t1 = pts[0][0], pts[-1][0]
    span = max((t1 - t0).total_seconds(), 1.0)
    top = max(10, min(100, (int(max(pct(x["done"], x["total"]) for _, x in pts) / 10) + 1) * 10))

    def X(d):
        return l + pw * (d - t0).total_seconds() / span

    def Y(v):
        return t + ph * (1 - v / top)

    for g in range(0, top + 1, 10 if top > 20 else 5):
        b.append(f"<line x1='{l}' x2='{w - r}' y1='{Y(g):.1f}' y2='{Y(g):.1f}' stroke='{GRID}'/>")
        b.append(text(l - 8, Y(g) + 4, f"{g}%", 11, MUTED, "end"))
    day = dt.datetime.combine(t0.date(), dt.time(), t0.tzinfo)
    while day <= t1:
        if day >= t0:
            b.append(f"<line x1='{X(day):.1f}' x2='{X(day):.1f}' y1='{t}' y2='{t + ph}' stroke='{GRID}'/>")
            b.append(text(X(day), h - 18, day.strftime("%b %d"), 11, MUTED, "middle"))
        day += dt.timedelta(days=1)

    def line(key, colour, width):
        seg = [(X(d), Y(pct(x[key], x["total"]))) for d, x in pts if x.get(key) is not None]
        if not seg:
            return
        if len(seg) > 1:
            path = " ".join(f"{'M' if i == 0 else 'L'}{a:.1f},{c:.1f}" for i, (a, c) in enumerate(seg))
            b.append(f"<path d='{path}' fill='none' stroke='{colour}' stroke-width='{width}' "
                     f"stroke-linejoin='round' stroke-linecap='round'/>")
        a, c = seg[-1]
        b.append(f"<circle cx='{a:.1f}' cy='{c:.1f}' r='{width + 1.5}' fill='{colour}'/>")

    line("data", DATA, 2)
    line("code", CODE, 2)
    line("done", INK, 3.5)
    last = pts[-1][1]
    b.append(text(X(pts[-1][0]) - 8, Y(pct(last["done"], last["total"])) - 10,
                  f"{pct(last['done'], last['total']):.2f}%", 13, INK, "end", "bold"))
    return svg(w, h, b, "Magi Nation decomp DONE over time")


def banks_svg(now: dict) -> str:
    rows = now["rows"]
    cols = 16
    cell, gap = 46, 4
    nrows = (len(rows) + cols - 1) // cols
    w = 838
    x0 = (w - (cols * cell + (cols - 1) * gap)) / 2
    y0 = 44
    h = int(y0 + nrows * (cell + gap) + 16)
    b = [text(24, 28, "ROM banks", 15, weight="bold"),
         text(w - 24, 28, "one cell per 16 KiB bank, filled from the bottom: code, then data",
              11, MUTED, "end")]
    for i, rw in enumerate(rows):
        cx = x0 + (i % cols) * (cell + gap)
        cy = y0 + (i // cols) * (cell + gap)
        tot = rw["total"] or 1
        ch = cell * rw["code"] / tot
        dh = cell * (rw["done"] - rw["code"]) / tot
        b.append(f"<g><title>bank ${rw['bank']:02X}: {pct(rw['done'], tot):.1f}% DONE "
                 f"(code {rw['code']:,} B, data {rw['done'] - rw['code']:,} B)</title>"
                 f"<rect x='{cx:.1f}' y='{cy:.1f}' width='{cell}' height='{cell}' rx='4' fill='{TODO}'/>"
                 f"<rect x='{cx:.1f}' y='{cy + cell - ch - dh:.1f}' width='{cell}' height='{dh:.1f}' fill='{DATA}'/>"
                 f"<rect x='{cx:.1f}' y='{cy + cell - ch:.1f}' width='{cell}' height='{ch:.1f}' fill='{CODE}'/>")
        b.append(f"<text x='{cx + cell / 2:.1f}' y='{cy + 15:.1f}' {FONT} font-size='10' fill='{INK}' "
                 f"text-anchor='middle' stroke='{PAPER}' stroke-width='3' paint-order='stroke'>"
                 f"{rw['bank']:02X}</text></g>")
    return svg(w, h, b, "Magi Nation decomp progress per ROM bank")


def badge(now: dict) -> dict:
    v = pct(now["done"], now["total"])
    colour = "brightgreen" if v >= 100 else "yellowgreen" if v >= 75 else "yellow" if v >= 50 \
        else "orange" if v >= 25 else "red"
    return {"schemaVersion": 1, "label": "decomp DONE", "message": f"{v:.2f}%", "color": colour}


def readme_block(now: dict, commit: str) -> str:
    done, code, data, total = now["done"], now["code"], now["data"], now["total"]
    v = pct(done, total)
    filled = round(v / 5)
    bar = "█" * filled + "░" * (20 - filled)
    when = dt.date.today().isoformat()
    return "\n".join([
        START,
        f"[![decomp DONE](https://img.shields.io/endpoint?url={RAW}/badge.json)](decomp/README.md)",
        "",
        f"<img src=\"{RAW}/progress.svg\" width=\"838\" alt=\"Magi Nation (USA) decomp: DONE code and data\" />",
        f"<img src=\"{RAW}/chart.svg\" width=\"838\" alt=\"DONE over time\" />",
        f"<img src=\"{RAW}/banks.svg\" width=\"838\" alt=\"DONE per ROM bank\" />",
        "",
        f"`{bar}` **{v:.2f}% DONE**: {done:,} / {total:,} bytes "
        f"(measured {when} at `{commit}`)",
        "",
        "| | Bytes | Share of the image |",
        "| --- | ---: | ---: |",
        f"| **DONE** | **{done:,}** | **{v:.2f}%** |",
        f"| DONE code | {code:,} | {pct(code, total):.2f}% |",
        f"| DONE data | {data:,} | {pct(data, total):.2f}% |",
        f"| still INCBIN | {total - done:,} | {pct(total - done, total):.2f}% |",
        END,
    ])


def update_readme(path: Path, block: str) -> bool:
    old = path.read_text()
    pat = re.compile(re.escape(START) + r".*?" + re.escape(END), re.S)
    if not pat.search(old):
        raise SystemExit(f"{path} has no {START} ... {END} block")
    new = pat.sub(lambda _: block, old)
    if new != old:
        path.write_text(new)
    return new != old


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", type=Path)
    ap.add_argument("--history", type=Path)
    ap.add_argument("--readme", type=Path)
    ap.add_argument("--commit")
    a = ap.parse_args()
    now = count()
    commit = a.commit or head()
    rows = []
    if a.history:
        rows = record(read_history(a.history), now, commit)
        write_history(a.history, rows)
    if a.out:
        a.out.mkdir(parents=True, exist_ok=True)
        if not rows:
            rows = record([], now, commit)
        (a.out / "progress.svg").write_text(headline_svg(now, commit))
        (a.out / "chart.svg").write_text(chart_svg(rows))
        (a.out / "banks.svg").write_text(banks_svg(now))
        (a.out / "badge.json").write_text(json.dumps(badge(now)) + "\n")
    if a.readme:
        update_readme(a.readme, readme_block(now, commit))
    print(f"magination: DONE {now['done']:,} / {now['total']:,} bytes "
          f"({pct(now['done'], now['total']):.2f}%) @ {commit}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
