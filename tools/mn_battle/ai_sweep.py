#!/usr/bin/env python3
"""Drive the PyBoy oracle once per enemy AI type.

The AI routine an enemy runs is its record byte +$17 (copied to $D0F0). From a
Korg duel state with BlackAgovo out (slot 6, record $D291) this writes each type
0-16 into BlackAgovo's byte, or into Korg's ($D336), and plays a few rounds with
Tony focusing and the player creature fighting. Both enemies get high energy so
the fight lasts. Replay the traces with tools/mn_battle/replay.lua.

  python3 tools/mn_battle/ai_sweep.py --rom ROM --state duel_r3.state --out DIR
"""
import argparse, os, subprocess, sys

ap = argparse.ArgumentParser()
ap.add_argument('--rom', required=True)
ap.add_argument('--state', required=True)
ap.add_argument('--out', required=True)
ap.add_argument('--rounds', type=int, default=4)
ap.add_argument('--who', default='creature,magi')
a = ap.parse_args()
here = os.path.dirname(os.path.abspath(__file__))
os.makedirs(a.out, exist_ok=True)
traces = []
for who in a.who.split(','):
    addr = {'creature': 0xD291 + 0x17, 'magi': 0xD336 + 0x17}[who]
    for t in range(17):
        out = os.path.join(a.out, 'ai_%s_%02d.json' % (who, t))
        cmd = [sys.executable, os.path.join(here, 'oracle.py'), '--rom', a.rom, '--state', a.state, '--out', out,
               '--max-frames', str(2400 * a.rounds), '--poke', '%04X=%02X' % (addr, t),
               '--poke', 'D298=03E703E7', '--poke', 'D33D=03E703E7', '--poke', 'D1BC=03E703E7']
        for _ in range(a.rounds):
            cmd += ['--round', 'a wait150 a wait90 a!']
        try:
            r = subprocess.run(cmd, capture_output=True, text=True, timeout=180)
            print(who, t, (r.stdout.strip().splitlines() or [r.stderr.strip()[-200:]])[0], flush=True)
        except subprocess.TimeoutExpired:
            # the game itself locks up (an AI routine that never returns): no trace
            print(who, t, 'timeout: the game did not return to a menu', flush=True)
            continue
        if os.path.exists(out):
            traces.append(out)
with open(os.path.join(a.out, 'traces.txt'), 'w') as f:
    f.write('\n'.join(traces) + '\n')
