#!/usr/bin/env python3
"""Drive the PyBoy oracle once per creature move.

From a save state parked at a battle menu with a player creature in slot 1,
each run rewrites that creature's first move pointer (record +$18) to one
move, unlocks it, tops its energy up, then has Tony Focus and the creature
use that move for a few rounds. Every run's trace is replayed through the Lua
engine by tools/mn_battle/replay.lua, which writes the per-move summary the
headless tester folds into reports/battle-coverage.*.

  python3 tools/mn_battle/move_sweep.py --rom ROM --state STATE --out DIR [--only 5F1E,...]
"""
import argparse, os, subprocess, sys

ap = argparse.ArgumentParser()
ap.add_argument('--rom', required=True)
ap.add_argument('--state', required=True)
ap.add_argument('--out', required=True)
ap.add_argument('--slot', type=int, default=1)
ap.add_argument('--rounds', type=int, default=3)
ap.add_argument('--energy', type=int, default=0x50)
ap.add_argument('--only', default='')
ap.add_argument('--force', action='append', default=[], help='forced rolls passed to oracle.py')
ap.add_argument('--poke', action='append', default=[], help='extra WRAM pokes passed to oracle.py')
a = ap.parse_args()

rom = open(a.rom, 'rb').read()
def moves():
    base = 5 * 0x4000 - 0x4000
    for p in range(0x5EAE, 0x651E, 0x10):
        yield p, rom[base + p:base + p + 0x10]

here = os.path.dirname(os.path.abspath(__file__))
os.makedirs(a.out, exist_ok=True)
rec = 0xD147 + a.slot * 0x37
only = {int(x, 16) for x in a.only.split(',') if x}
traces = []
for ptr, raw in moves():
    if ptr < 0x5F1E or (only and ptr not in only):
        continue  # the first records are the Tony/Fight commands
    out = os.path.join(a.out, 'move_%04X.json' % ptr)
    pokes = [
        '%04X=%02X%02X' % (rec + 0x18, ptr & 0xFF, ptr >> 8),
        '%04X=FF' % (rec + 0x20),
        '%04X=%02X%02X%02X%02X' % (rec + 7, a.energy >> 8, a.energy & 0xFF, a.energy >> 8, a.energy & 0xFF),
    ]
    rnd = 'a wait150 down wait60 a wait90 a!'
    cmd = [sys.executable, os.path.join(here, 'oracle.py'), '--rom', a.rom, '--state', a.state, '--out', out,
           '--max-frames', str(2400 * a.rounds)]
    for f in a.force:
        cmd += ['--force', f]
    pokes += a.poke
    for p in pokes:
        cmd += ['--poke', p]
    for _ in range(a.rounds):
        cmd += ['--round', rnd]
    r = subprocess.run(cmd, capture_output=True, text=True)
    print('%04X' % ptr, (r.stdout.strip().splitlines() or ['?'])[0], flush=True)
    if os.path.exists(out):
        traces.append(out)
with open(os.path.join(a.out, 'traces.txt'), 'w') as f:
    f.write('\n'.join(traces) + '\n')
