#!/usr/bin/env python3
"""Replay test for the code lifter (AGENTS.md W3).

    test_lift_replay.py [--project NAME] [--limit N]

For every global label that starts a section whose source is mostly instructions in the last build,
decode the routine the way lift.py would (every branch followed, inside the
section) and emit it with lift.py's own emitter, operands numeric. All of
them assemble at their real addresses in one throwaway image under out/, and
each routine's bytes are compared with the ROM. This proves the emitter on
code humans and models already matched, before it is trusted on new code.
"""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from lib import rom as R  # noqa: E402
import lift  # noqa: E402
import progress  # noqa: E402


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--project", default="magination")
    ap.add_argument("--limit", type=int, default=0)
    args = ap.parse_args()
    p = R.project(args.project)
    data = p.rom.read_bytes()
    sizes = R.map_sections(p)
    names = R.names(p)
    by_addr = {}
    for n, a in names.items():
        if "." not in n and not n.endswith("End"):
            by_addr.setdefault(a, n)
    counter = progress.Counter(p)
    units, skipped = [], {}
    for sec in R.sections(p.scaffold.read_text()):
        if len(sec.includes) != 1 or sec.title not in sizes:
            continue
        a, n = sizes[sec.title]
        if a not in by_addr or n == 0:
            continue
        code, _ = counter.file(sec.includes[0])
        if code * 2 < n:
            continue  # mostly data: not a routine to replay
        try:
            instrs, end = lift.decode_routine(data, a, a + n, fall_through=True)
        except lift.Reject as e:
            key = str(e).split(" at ")[0]
            skipped[key] = skipped.get(key, 0) + 1
            continue
        units.append((a, end, instrs))
        if args.limit and len(units) >= args.limit:
            break
    out = R.ROOT / "out" / "replay"
    out.mkdir(parents=True, exist_ok=True)
    asm = []
    for a, end, instrs in units:
        body = lift.code_lines(p, a, instrs, end, f"replay_{a:06X}", symbolic=False)
        asm += [f'SECTION "replay {a:06X}", {R.section_spec(a)}'] + body + [""]
    (out / "replay.asm").write_text("\n".join(asm))
    nix = [] if os.environ.get("IN_NIX_SHELL") else ["nix", "develop", "--command"]
    cmd = ("rgbasm -o out/replay/replay.o out/replay/replay.asm && "
           "rgblink -p 0 -m out/replay/replay.map -o out/replay/replay.gb out/replay/replay.o")
    r = subprocess.run(nix + ["bash", "-c", cmd], cwd=R.ROOT, capture_output=True, text=True)
    if r.returncode != 0:
        print(r.stderr[-1500:], file=sys.stderr)
        return 1
    built = (out / "replay.gb").read_bytes()
    bad = [(a, end) for a, end, _ in units if built[a:end] != data[a:end]]
    total = sum(end - a for a, end, _ in units)
    print(f"replay: {len(units)} routines ({total:,} bytes) re-emitted by lift.py; "
          f"{len(units) - len(bad)} byte-identical, {len(bad)} differ")
    if skipped:
        print("not replayable (decode refuses, as it would for a new target): "
              + ", ".join(f"{k}: {v}" for k, v in sorted(skipped.items(), key=lambda kv: -kv[1])))
    for a, end in bad[:10]:
        i = next(k for k in range(end - a) if built[a + k] != data[a + k])
        print(f"  ${a:06X}+{i}: want {data[a+i:a+i+4].hex(' ')} got {built[a+i:a+i+4].hex(' ')}")
    return 1 if bad else 0


if __name__ == "__main__":
    raise SystemExit(main())
