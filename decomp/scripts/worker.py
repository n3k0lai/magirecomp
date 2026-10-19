#!/usr/bin/env python3
"""The decomp worker: mechanical first, a model only for names (AGENTS.md W1-W9).

    worker.py targets [--project P] [--all]       evidence-backed targets and what lift.py would do
    worker.py lift [ADDR ...] [--auto N]          lift, build, compare, commit only exact matches
    worker.py pack ADDR|LABEL                     the context pack a model would get (printed)
    worker.py name LABEL [--llm-cmd CMD]          one naming round for a placeholder (W8)
    worker.py run [--batch N] [--names N]         lift until no target is left, then naming rounds
    worker.py stats                               rounds, tokens and matches per hour from the CSV

Every attempt appends one row to overnight/own/metrics.csv: time, project,
target, kind, bytes, rounds (model calls), tokens, seconds, result, commit.
A unit is committed only when the whole image still matches rom.sha1 and
`make check` passes; anything else is reverted and logged, never kept (W2).
The worker never pushes.
"""

from __future__ import annotations

import argparse
import csv
import fcntl
import json
import os
import re
import shlex
import subprocess
import sys
import time
from contextlib import contextmanager
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from lib import rom as R  # noqa: E402
from lib import sm83  # noqa: E402

import lift  # noqa: E402
import propagate as prop  # noqa: E402
import xref  # noqa: E402

FIELDS = ["time", "project", "target", "kind", "bytes", "rounds", "tokens",
          "seconds", "result", "detail", "commit"]
NAME_RE = re.compile(r"^[A-Z][A-Za-z0-9]{2,47}$")


# ---------------------------------------------------------------- plumbing

def run(cmd, **kw):
    return subprocess.run(cmd, cwd=R.ROOT, capture_output=True, text=True, **kw)


def nix() -> list[str]:
    return [] if os.environ.get("IN_NIX_SHELL") else ["nix", "develop", "--command"]


def make(p: R.Project, *targets: str):
    extra = [] if p.name == "magination" else [f"PROJECT={p.name}"]
    return run(nix() + ["make", *extra, *targets])


@contextmanager
def lock(p: R.Project):
    p.state.mkdir(parents=True, exist_ok=True)
    with open(p.state / "lock", "w") as f:
        fcntl.flock(f, fcntl.LOCK_EX)
        try:
            yield
        finally:
            fcntl.flock(f, fcntl.LOCK_UN)


def metric(p: R.Project, **row) -> None:
    path = p.state / "metrics.csv"
    p.state.mkdir(parents=True, exist_ok=True)
    new = not path.exists()
    with path.open("a", newline="") as f:
        w = csv.DictWriter(f, FIELDS)
        if new:
            w.writeheader()
        row.setdefault("time", time.strftime("%Y-%m-%dT%H:%M:%S%z"))
        row.setdefault("project", p.name)
        w.writerow({k: row.get(k, "") for k in FIELDS})


def clean_tree(p: R.Project) -> bool:
    rel = str(p.src.relative_to(R.ROOT))
    return not run(["git", "status", "--porcelain", "--", rel]).stdout.strip()


def revert(p: R.Project, created: list[str]) -> None:
    rel = str(p.src.relative_to(R.ROOT))
    run(["git", "checkout", "--", rel])
    for f in created:
        (R.ROOT / f).unlink(missing_ok=True)


def range_diff(p: R.Project, start: int, end: int) -> str | None:
    want = p.rom.read_bytes()[start:end]
    got = p.out.read_bytes()[start:end] if p.out.exists() else b""
    if want == got:
        return None
    i = next((k for k, (a, b) in enumerate(zip(want, got)) if a != b), min(len(want), len(got)))
    return f"first difference at ${start + i:06X}: want {want[i:i+6].hex(' ')} got {got[i:i+6].hex(' ')}"


# ---------------------------------------------------------------- targets

def targets(p: R.Project):
    """(address, unit or None, reason) for every distinct xref target in a hole."""
    refs = xref.collect(p)
    hs = R.holes(p.scaffold.read_text())
    seen, out = set(), []
    # a table owns every pointer target up to its edge: plan the first one only
    for r in sorted(refs, key=lambda r: r.target):
        a = r.target
        if a in seen or not R.hole_for(a, hs) or p.header[0] <= a < p.header[1]:
            continue
        seen.add(a)
        try:
            u = lift.plan(p, a, refs, hs)
            out.append((a, u, ""))
            seen.update(u.labels)
            seen.update(range(u.start, u.end))
        except lift.Reject as e:
            out.append((a, None, str(e)))
    return out


def cmd_targets(args) -> int:
    p = R.project(args.project)
    for a, u, why in targets(p):
        if u:
            print(f"${a:06X}  {u.kind:5}  {u.end - u.start:5} B  {u.label}  ({len(u.evidence)} refs)")
        elif args.all:
            print(f"${a:06X}  skip   {why}")
    return 0


# ---------------------------------------------------------------- lift

def apply_units(p: R.Project, units) -> list[str]:
    created = []
    for u in units:
        lift.splice(p, u)
        created.append(u.file)
        lift.propagate(p, u)
    return created


def gate(p: R.Project, units) -> tuple[bool, str]:
    r = make(p, "compare")
    if r.returncode != 0:
        bad = [f"{u.label}: {d}" for u in units if (d := range_diff(p, u.start, u.end))]
        return False, ("; ".join(bad) or (r.stdout + r.stderr)[-600:]).strip()
    r = make(p, "check")
    if r.returncode != 0:
        return False, ("check: " + (r.stdout + r.stderr)[-600:]).strip()
    return True, ""


def commit(p: R.Project, units, created) -> str:
    rel = str(p.src.relative_to(R.ROOT))
    run(["git", "add", "--", rel, *created])
    total = sum(u.end - u.start for u in units)
    kinds = sorted({u.kind for u in units})
    subject = (f"lift: {units[0].label} (${units[0].start:06X}, {total} B {kinds[0]})" if len(units) == 1 else
               f"lift: {len(units)} units, {total} B ({', '.join(kinds)}) in bank "
               f"{', '.join(sorted({f'${u.start >> 14:02X}' for u in units}))}")
    body = ["Mechanical lift by scripts/worker.py (no model rounds); the whole",
            "image matches rom.sha1 and make check passes.", ""]
    for u in units:
        body.append(f"- {u.label} ${u.start:06X}-${u.end - 1:06X} ({u.end - u.start} B {u.kind})")
        body += [f"    evidence: {e}" for e in u.evidence[:4]]
    r = run(["git", "commit", "-q", "-m", subject + "\n\n" + "\n".join(body) + "\n"])
    if r.returncode != 0:
        raise RuntimeError((r.stdout + r.stderr)[-600:])
    return run(["git", "rev-parse", "--short", "HEAD"]).stdout.strip()


def lift_batch(p: R.Project, addrs: list[int] | None, limit: int) -> dict:
    t0 = time.time()
    if not clean_tree(p):
        return {"error": f"{p.src} has uncommitted changes; commit or stash them first"}
    with lock(p):
        plans = []
        if addrs is None:
            plans = [u for _, u, _ in targets(p) if u][:limit]
        else:
            refs = xref.collect(p)
            hs = R.holes(p.scaffold.read_text())
            for a in addrs:
                try:
                    plans.append(lift.plan(p, a, refs, hs))
                except lift.Reject as e:
                    metric(p, target=f"{a:06X}", rounds=0, tokens=0, result="rejected", detail=str(e))
        if not plans:
            return {"lifted": 0, "detail": "no target with evidence"}
        try:
            created = apply_units(p, plans)
        except lift.Reject as e:
            revert(p, [u.file for u in plans])
            return {"error": str(e)}
        ok, why = gate(p, plans)
        kept = plans
        if not ok:
            # one bad unit must not sink the batch: retry each alone
            revert(p, created)
            kept = []
            for u in plans:
                t1 = time.time()
                c = apply_units(p, [u])
                good, why1 = gate(p, [u])
                if good:
                    kept.append(u)
                    hsha = commit(p, [u], c)
                    metric(p, target=f"{u.start:06X}", kind=u.kind, bytes=u.end - u.start,
                           rounds=0, tokens=0, seconds=round(time.time() - t1, 1),
                           result="matched", commit=hsha)
                else:
                    revert(p, c)
                    metric(p, target=f"{u.start:06X}", kind=u.kind, bytes=u.end - u.start,
                           rounds=0, tokens=0, seconds=round(time.time() - t1, 1),
                           result="discarded", detail=why1[:300])
            make(p, "build")
            return {"lifted": len(kept), "discarded": len(plans) - len(kept)}
        hsha = commit(p, plans, created)
        secs = round((time.time() - t0) / len(plans), 1)
        for u in plans:
            metric(p, target=f"{u.start:06X}", kind=u.kind, bytes=u.end - u.start, rounds=0,
                   tokens=0, seconds=secs, result="matched", commit=hsha)
        return {"lifted": len(plans), "bytes": sum(u.end - u.start for u in plans), "commit": hsha,
                "units": [f"{u.label} ${u.start:06X} {u.end - u.start} B {u.kind}" for u in plans]}


def cmd_lift(args) -> int:
    p = R.project(args.project)
    addrs = [int(a.lstrip("$"), 16) for a in args.address] or None
    res = lift_batch(p, addrs, args.auto)
    print(json.dumps(res, indent=1))
    return 0 if "error" not in res else 1


def propagate_round(p: R.Project) -> dict:
    """Symbol propagation as one verified commit (T3)."""
    t0 = time.time()
    if not clean_tree(p):
        return {"error": f"{p.src} has uncommitted changes"}
    with lock(p):
        edits, stats = prop.plan(p)
        if not edits:
            return {"propagated": 0}
        for f, t in edits.items():
            (R.ROOT / f).write_text(t)
        ok, why = gate(p, [])
        if not ok:
            revert(p, [])
            metric(p, target="*", kind="propagate", rounds=0, tokens=0,
                   seconds=round(time.time() - t0, 1), result="discarded", detail=why[:300])
            return {"error": why}
        run(["python3", "scripts/check_rules.py", "--project", p.name, "--update-ratchets"])
        run(["git", "add", "--", str(p.src.relative_to(R.ROOT)), "config/ratchets.tsv"])
        msg = (f"propagate: {stats['defs']} DEF aliases become their labels, "
               f"{stats['raw']} raw operands named\n\nscripts/propagate.py, byte-identical "
               f"(make compare OK). Each rewrite follows xref.py's resolution of the operand at\n"
               f"its own line, bank state included; a DEF used any other way stays.\n")
        r = run(["git", "commit", "-q", "-m", msg])
        if r.returncode != 0:
            return {"error": (r.stdout + r.stderr)[-400:]}
        hsha = run(["git", "rev-parse", "--short", "HEAD"]).stdout.strip()
    metric(p, target="*", kind="propagate", bytes=0, rounds=0, tokens=0,
           seconds=round(time.time() - t0, 1), result="propagated",
           detail=f"{len(edits)} files, {stats['defs']} defs, {stats['raw']} raw", commit=hsha)
    return {"propagated": len(edits), **stats, "commit": hsha}


def cmd_propagate(args) -> int:
    res = propagate_round(R.project(args.project))
    print(json.dumps(res))
    return 0 if "error" not in res else 1


# ---------------------------------------------------------------- packs

def unit_of_label(p: R.Project, label: str):
    for f in R.unit_banks(p).keys():
        path = R.ROOT / f
        if path.exists() and re.search(rf"^{re.escape(label)}::?", path.read_text(errors="replace"), re.M):
            return f
    return None


def excerpt(f: str, line: int, before=6, after=4) -> str:
    rows = (R.ROOT / f).read_text(errors="replace").splitlines()
    lo, hi = max(0, line - 1 - before), min(len(rows), line + after)
    return "\n".join(f"{'>' if k == line - 1 else ' '} {rows[k]}" for k in range(lo, hi))


def similar(p: R.Project, start: int, end: int, k: int = 2):
    """Lifted units with the most shared byte 3-grams (named ones only)."""
    data = p.rom.read_bytes()
    want = {data[i:i + 3] for i in range(start, end - 2)}
    if not want:
        return []
    best = []
    sizes = R.map_sections(p)
    titles = {s.title: s.includes[0] for s in R.sections(p.scaffold.read_text()) if s.includes}
    for title, (a, n) in sizes.items():
        if title not in titles or a == start or n < 4 or n > 4 * (end - start) + 64:
            continue
        if re.match(r"^(sub|unk)_", title):
            continue
        grams = {data[i:i + 3] for i in range(a, a + n - 2)}
        j = len(want & grams) / max(1, len(want | grams))
        if j > 0.2:
            best.append((j, titles[title]))
    return [f for _, f in sorted(best, reverse=True)[:k]]


def pack(p: R.Project, label: str) -> tuple[str, dict]:
    """The context a naming round needs, and nothing else (W6)."""
    f = unit_of_label(p, label)
    if f is None:
        raise SystemExit(f"no source file defines {label}")
    names = R.names(p)
    start = names.get(label)
    body = (R.ROOT / f).read_text(errors="replace")
    refs = [r for r in xref.collect(p) if r.target == start]
    callers = sorted({(r.file, r.line, r.routine, r.kind) for r in refs})[:4]
    # raw-number readers too: the label propagation step leaves names, so grep for it
    uses = []
    for g in R.unit_banks(p).keys():
        path = R.ROOT / g
        if g == f or not path.exists():
            continue
        for n, line in enumerate(path.read_text(errors="replace").splitlines(), 1):
            if re.search(rf"\b{re.escape(label)}\b", line.split(";", 1)[0]):
                uses.append((g, n))
    uses = uses[:4]
    sim = similar(p, start, start + len(body), 2) if start is not None else []
    parts = [f"# Name {label} (file ${start:06X}) in the Magi-Nation matching disassembly", "",
             "## Its source (bytes already match; do not change instructions)", "```asm", body.strip(), "```"]
    if callers or uses:
        parts += ["", "## Where it is used"]
        for g, n in sorted(set([(c[0], c[1]) for c in callers] + uses))[:4]:
            parts += [f"{g}:{n}", "```asm", excerpt(g, n), "```"]
    if sim:
        parts += ["", "## Similar named code, for naming style"]
        for g in sim:
            head = "\n".join((R.ROOT / g).read_text(errors="replace").splitlines()[:12])
            parts += [g, "```asm", head, "```"]
    parts += ["", "## Reply", "Exactly these lines, nothing else:",
              "NAME: <PascalCase name for what it does, or KEEP>",
              "EVIDENCE: <the line(s) above that prove it: file:line and what they show>",
              "COMMENT: <one or two sentences for the header, or empty>",
              "Reply KEEP unless the evidence above proves the name. A guess is worse than",
              f"{label}; a kept placeholder costs nothing (AGENTS.md S4)."]
    text = "\n".join(parts) + "\n"
    return text, {"file": f, "start": start, "uses": callers + uses}


def cmd_pack(args) -> int:
    p = R.project(args.project)
    text, meta = pack(p, args.label)
    print(text)
    print(f"[pack: {len(text)} chars, ~{len(text) // 4} tokens]", file=sys.stderr)
    return 0


# ---------------------------------------------------------------- naming

def ask(cmd: str, prompt: str) -> tuple[str, int]:
    """Run the model adapter: prompt on stdin, reply on stdout, and one JSON
    line {"tokens": N} on stderr if the adapter knows the usage."""
    r = subprocess.run(cmd, shell=True, input=prompt, capture_output=True, text=True, cwd=R.ROOT)
    tokens = 0
    for line in r.stderr.splitlines():
        try:
            tokens += int(json.loads(line).get("tokens", 0))
        except (ValueError, AttributeError):
            continue
    if r.returncode != 0:
        raise RuntimeError(f"model command failed: {r.stderr.strip()[-300:]}")
    return r.stdout, tokens or (len(prompt) + len(r.stdout)) // 4


def parse_name(reply: str) -> tuple[str | None, str, str]:
    name = (re.search(r"^NAME:\s*(\S+)", reply, re.M) or [None, None])[1]
    ev = (re.search(r"^EVIDENCE:\s*(.+)$", reply, re.M) or [None, ""])[1].strip()
    comment = (re.search(r"^COMMENT:\s*(.*)$", reply, re.M) or [None, ""])[1].strip()
    if name in (None, "KEEP"):
        return None, ev, comment
    return name, ev, comment


def name_round(p: R.Project, label: str, cmd: str) -> dict:
    t0 = time.time()
    text, meta = pack(p, label)
    reply, tokens = ask(cmd, text)
    name, ev, comment = parse_name(reply)
    row = dict(target=label, kind="name", rounds=1, tokens=tokens)
    if name is None:
        metric(p, **row, seconds=round(time.time() - t0, 1), result="kept-placeholder", detail=ev[:200])
        return {"label": label, "result": "kept-placeholder"}
    cited = re.findall(r"([\w/]+\.asm):(\d+)", ev)
    allowed = {meta["file"]} | {u[0] for u in meta["uses"]}
    problems = []
    if not NAME_RE.match(name):
        problems.append(f"{name!r} is not a PascalCase name")
    if name in R.names(p) or name in R.constants(p):
        problems.append(f"{name} is already defined")
    if not cited or not all(f in allowed for f, _ in cited):
        problems.append("evidence cites no line of the pack")
    if problems:
        metric(p, **row, seconds=round(time.time() - t0, 1), result="refused", detail="; ".join(problems))
        return {"label": label, "result": "refused", "why": problems}
    with lock(p):
        if not clean_tree(p):
            return {"error": "src has uncommitted changes"}
        touched = []
        for g in R.unit_banks(p).keys():
            path = R.ROOT / g
            if path.exists():
                t = path.read_text()
                t2 = re.sub(rf"\b{re.escape(label)}\b", name, t)
                if t2 != t:
                    path.write_text(t2)
                    touched.append(g)
        src = R.ROOT / meta["file"]
        t = src.read_text()
        t = re.sub(r"^; Name and comments wait for a naming pass.*\n", "", t, flags=re.M)
        t = re.sub(r"^; naming pass gives the fields a meaning.*\n", "", t, flags=re.M)
        t = f"; {comment}\n; Name evidence: {ev}\n" + t if comment else f"; Name evidence: {ev}\n" + t
        src.write_text(t)
        ok, why = gate(p, [])
        if not ok:
            revert(p, [])
            metric(p, **row, seconds=round(time.time() - t0, 1), result="discarded", detail=why[:300])
            return {"label": label, "result": "discarded", "why": why}
        run(["git", "add", "--", str(p.src.relative_to(R.ROOT))])
        run(["git", "commit", "-q", "-m", f"name: {label} -> {name}\n\nEvidence: {ev}\n"])
        hsha = run(["git", "rev-parse", "--short", "HEAD"]).stdout.strip()
    metric(p, **row, seconds=round(time.time() - t0, 1), result="named", detail=name, commit=hsha)
    return {"label": label, "result": "named", "name": name, "commit": hsha}


def placeholders(p: R.Project) -> list[str]:
    out = []
    for f in R.unit_banks(p).keys():
        path = R.ROOT / f
        if path.exists():
            out += re.findall(r"^((?:sub|unk)_[0-9A-F]{6})::?", path.read_text(errors="replace"), re.M)
    return sorted(out)


def model_cmd(args) -> str | None:
    return args.llm_cmd or os.environ.get("WORKER_LLM_CMD")


def cmd_name(args) -> int:
    p = R.project(args.project)
    cmd = model_cmd(args)
    if not cmd:
        print(json.dumps({"error": "set WORKER_LLM_CMD or --llm-cmd (see scripts/llm/README.md)"}))
        return 4
    print(json.dumps(name_round(p, args.label, cmd)))
    return 0


def cmd_run(args) -> int:
    p = R.project(args.project)
    while True:
        res = lift_batch(p, None, args.batch)
        print(json.dumps(res), flush=True)
        if "error" in res or not res.get("lifted"):
            break
    print(json.dumps(propagate_round(p)), flush=True)
    cmd = model_cmd(args)
    if cmd and args.names:
        for label in placeholders(p)[:args.names]:
            print(json.dumps(name_round(p, label, cmd)), flush=True)
    elif args.names:
        print(json.dumps({"names": "skipped", "why": "no WORKER_LLM_CMD"}))
    run(["python3", "scripts/progress.py", "--project", p.name, "--record"])
    return 0


def cmd_stats(args) -> int:
    p = R.project(args.project)
    path = p.state / "metrics.csv"
    if not path.exists():
        print("no metrics yet")
        return 0
    rows = list(csv.DictReader(path.open()))
    if args.since:
        rows = [r for r in rows if r["time"] >= args.since]
    by = {}
    for r in rows:
        by.setdefault(r["result"], []).append(r)
    matched = by.get("matched", []) + by.get("named", [])
    rounds = sum(int(r["rounds"] or 0) for r in rows)
    tokens = sum(int(r["tokens"] or 0) for r in rows)
    secs = sum(float(r["seconds"] or 0) for r in rows)
    print(f"attempts {len(rows)}: " + ", ".join(f"{k} {len(v)}" for k, v in sorted(by.items())))
    print(f"bytes matched {sum(int(r['bytes'] or 0) for r in by.get('matched', []))}")
    if matched:
        print(f"model rounds per match {rounds / len(matched):.2f}, tokens per match {tokens / len(matched):.0f}")
    if secs:
        print(f"matches per hour {3600 * len(matched) / secs:.0f} (worker wall time {secs:.0f} s)")
    kept_guesses = sum(1 for r in rows if r["result"] == "matched" and int(r["rounds"] or 0) > 0)
    print(f"model-written bytes kept: {kept_guesses} units")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--project", default="magination")
    sub = ap.add_subparsers(dest="cmd", required=True)
    s = sub.add_parser("targets"); s.add_argument("--all", action="store_true"); s.set_defaults(fn=cmd_targets)
    s = sub.add_parser("lift"); s.add_argument("address", nargs="*"); s.add_argument("--auto", type=int, default=10)
    s.set_defaults(fn=cmd_lift)
    s = sub.add_parser("propagate"); s.set_defaults(fn=cmd_propagate)
    s = sub.add_parser("pack"); s.add_argument("label"); s.set_defaults(fn=cmd_pack)
    s = sub.add_parser("name"); s.add_argument("label"); s.add_argument("--llm-cmd"); s.set_defaults(fn=cmd_name)
    s = sub.add_parser("run"); s.add_argument("--batch", type=int, default=10)
    s.add_argument("--names", type=int, default=0); s.add_argument("--llm-cmd"); s.set_defaults(fn=cmd_run)
    s = sub.add_parser("stats"); s.add_argument("--since"); s.set_defaults(fn=cmd_stats)
    args = ap.parse_args()
    return args.fn(args)


if __name__ == "__main__":
    raise SystemExit(main())
