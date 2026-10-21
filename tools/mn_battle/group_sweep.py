#!/usr/bin/env python3
"""Drive the PyBoy oracle once per spell and per item.

From a save state parked at Tony's battle menu, each run rewrites the save so
Tony knows exactly one spell (or carries exactly one kind of item), then has him
cast / use it for a couple of rounds. Replay the traces with
tools/mn_battle/replay.lua --json to get the per-group match summary.

  python3 tools/mn_battle/group_sweep.py --rom ROM --state STATE --out DIR [--kind spell|item|both]
"""
import argparse, os, subprocess, sys

ap = argparse.ArgumentParser()
ap.add_argument('--rom', required=True)
ap.add_argument('--state', required=True)
ap.add_argument('--out', required=True)
ap.add_argument('--kind', default='both')
ap.add_argument('--rounds', type=int, default=2)
a = ap.parse_args()

rom = open(a.rom, 'rb').read()
here = os.path.dirname(os.path.abspath(__file__))
os.makedirs(a.out, exist_ok=True)

def rec(ptr):
    o = 7 * 0x4000 + ptr - 0x4000
    return rom[o:o + 0x22]

jobs = []
if a.kind in ('spell', 'both'):
    for sid in range(1, 20):
        ptr = 0x6FF5 + sid * 0x22
        known = ['%04X=00' % (0xA5A5 + k) for k in range(1, 20)]
        known.append('%04X=%02X' % (0xA5A5 + sid, rec(ptr)[4] or 1))
        jobs.append(('spell_%04X' % ptr, known, 'down wait30 down wait30 a wait90 a wait90 a!'))
if a.kind in ('item', 'both'):
    for iid in range(1, 28):
        ptr = 0x5DFF + iid * 0x22
        have = ['%04X=00' % (0xA3A7 + k) for k in range(1, 28)]
        have.append('%04X=03' % (0xA3A7 + iid))
        jobs.append(('item_%04X' % ptr, have, 'down wait30 down wait30 down wait30 a wait90 a wait90 a!'))

traces = []
for name, pokes, rnd in jobs:
    out = os.path.join(a.out, name + '.json')
    cmd = [sys.executable, os.path.join(here, 'oracle.py'), '--rom', a.rom, '--state', a.state, '--out', out,
           '--max-frames', '7200']
    for p in pokes:
        cmd += ['--poke-sram', p]
    for _ in range(a.rounds):
        cmd += ['--round', rnd]
    r = subprocess.run(cmd, capture_output=True, text=True)
    print(name, (r.stdout.strip().splitlines() or ['?'])[0], flush=True)
    if os.path.exists(out):
        traces.append(out)
with open(os.path.join(a.out, 'traces.txt'), 'w') as f:
    f.write('\n'.join(traces) + '\n')
