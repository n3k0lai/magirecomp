#!/usr/bin/env python3
"""Scripted fights that combine effects, on the Korg duel state.

Each case gives the player creature (slot 2) one move and sets a status on both
enemies (BlackAgovo's record at $D291 and Korg's at $D336, byte +$15 = $D125 when
loaded) before the first menu, then plays a few rounds through the oracle.

  python3 tools/mn_battle/combo_sweep.py --rom ROM --state duel_menu.state --out DIR
"""
import argparse, os, subprocess, sys

CASES = {
    # name: (move, status byte, extra oracle args)
    'plague_fire': (0x60AE, 0x01, []),      # Flame: fire cures plague
    'plague_scratch': (0x62EE, 0x01, []),   # control: plague stays and ticks
    'hiccups_water': (0x63BE, 0x04, []),    # Squirt: water cures hiccups
    'hiccups_scratch': (0x62EE, 0x04, []),
    'stone_earth': (0x631E, 0x02, []),      # Shake (earth) against stone
    'stone_fire': (0x60AE, 0x02, []),       # Flame against stone: half damage
    'hidden_mirror': (0x62EE, 0x30, []),    # hidden plus mirror
    'hidden_only': (0x62EE, 0x10, []),
    'confusion': (0x62EE, 0x40, []),
    'eruption': (0x62EE, 0x08, []),
    'diversion': (0x62EE, 0x80, []),
    'infect_fire': (0x617E, 0x00, []),      # Infect then the ticking plague
}

ap = argparse.ArgumentParser()
ap.add_argument('--rom', required=True)
ap.add_argument('--state', required=True)
ap.add_argument('--out', required=True)
ap.add_argument('--rounds', type=int, default=6)
ap.add_argument('--only', default='')
a = ap.parse_args()
here = os.path.dirname(os.path.abspath(__file__))
os.makedirs(a.out, exist_ok=True)
traces = []
for name, (move, status, extra) in CASES.items():
    if a.only and name not in a.only.split(','):
        continue
    out = os.path.join(a.out, 'combo_%s.json' % name)
    rec = 0xD147 + 2 * 0x37
    pokes = ['%04X=%02X%02X' % (rec + 0x18, move & 0xFF, move >> 8), '%04X=FF' % (rec + 0x20),
             '%04X=00C800C8' % (rec + 7), 'D298=00C800C8', 'D33D=00C800C8',
             'D2A6=%02X' % status, 'D34B=%02X' % status]
    cmd = [sys.executable, os.path.join(here, 'oracle.py'), '--rom', a.rom, '--state', a.state, '--out', out,
           '--max-frames', str(2400 * a.rounds)] + extra
    for p in pokes:
        cmd += ['--poke', p]
    for _ in range(a.rounds):
        cmd += ['--round', 'a wait150 down wait60 a wait90 a!']
    r = subprocess.run(cmd, capture_output=True, text=True)
    print(name, (r.stdout.strip().splitlines() or [r.stderr.strip()[-200:]])[0], flush=True)
    if os.path.exists(out):
        traces.append(out)
with open(os.path.join(a.out, 'traces.txt'), 'w') as f:
    f.write('\n'.join(traces) + '\n')
