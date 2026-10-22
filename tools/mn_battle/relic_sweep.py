#!/usr/bin/env python3
"""Drive the PyBoy oracle once per relic.

From the Glade battle state (one party creature, saved at SRAM bank 1 $A025),
each run writes relic ids into that creature's saved bytes +$22/+$23 (they load
to $D134/$D135), has Tony Summon it, then lets it Fight for a few rounds so the
essence relics' damage-step routine (record pointer +4, run for the actor's
$D0FD/$D0FE) fires too. Replay the traces with tools/mn_battle/replay.lua.

  python3 tools/mn_battle/relic_sweep.py --rom ROM --state glade_menu.state --out DIR [--pairs]
"""
import argparse, os, subprocess, sys

ap = argparse.ArgumentParser()
ap.add_argument('--rom', required=True)
ap.add_argument('--state', required=True)
ap.add_argument('--out', required=True)
ap.add_argument('--rounds', type=int, default=4)
ap.add_argument('--first', type=int, default=1)
ap.add_argument('--last', type=int, default=36)
ap.add_argument('--poke', action='append', default=[], help='extra WRAM pokes passed to oracle.py')
ap.add_argument('--tag', default='')
ap.add_argument('--pairs', default='', help='comma separated AABB hex pairs instead of the single sweep')
a = ap.parse_args()

here = os.path.dirname(os.path.abspath(__file__))
os.makedirs(a.out, exist_ok=True)
runs = [(int(p[:2], 16), int(p[2:], 16)) for p in a.pairs.split(',') if p] or \
       [(i, 0) for i in range(a.first, a.last + 1)]
traces = []
for r1, r2 in runs:
    out = os.path.join(a.out, 'relic_%02X%02X%s.json' % (r1, r2, a.tag))
    cmd = [sys.executable, os.path.join(here, 'oracle.py'), '--rom', a.rom, '--state', a.state, '--out', out,
           '--max-frames', '9000', '--poke-sram', '1:A047=%02X%02X' % (r1, r2), '--round', 'a wait60 a!']
    for p in a.poke:
        cmd += ['--poke', p]
    for _ in range(a.rounds - 1):
        cmd += ['--round', 'a wait150 down wait60 a wait90 a!']
    r = subprocess.run(cmd, capture_output=True, text=True)
    print('%02X%02X' % (r1, r2), (r.stdout.strip().splitlines() or [r.stderr.strip()[-200:]])[0], flush=True)
    if os.path.exists(out):
        traces.append(out)
with open(os.path.join(a.out, 'traces.txt'), 'w') as f:
    f.write('\n'.join(traces) + '\n')
