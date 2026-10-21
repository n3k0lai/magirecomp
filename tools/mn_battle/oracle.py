#!/usr/bin/env python3
"""PyBoy oracle for the Magi-Nation battle engine port.

Runs the real game (the user's own ROM, never committed) from a save state
parked at a battle menu, feeds a scripted list of menu inputs, and records for
every round:

  pre    battle WRAM (bank 7 $D000-$D3FF) and $FFA9 when ApplyFourD096Slots
         ($02:6A01) starts, i.e. after the player side has chosen
  draws  every divider value the battle code consumed, in order:
           m  MaskDivByC result        (hook on its ret, $00:054E, A)
           s  AddDividerStep step      (hook on its ret, $00:0564, E) + new $FFA9
           d  JitterScaledTableByte    (hook after `ld a,[rDIV]`, $02:5414, A)
         with the caller's return address, so UI draws can be told apart
  post   battle WRAM and $FFA9 when the next round's menu opens ($02:6AED) or
         the battle ends ($02:6316)
  sram   the save's creature records Summon reads ($D107 points into SRAM)

tools/mn_battle/replay.lua loads `pre`, plays `draws` through mn.battle.Rng
and checks that the Lua engine produces `post` byte for byte.

  python3 tools/mn_battle/oracle.py --rom ROM --state STATE --out trace.json \
      --round "down a" --round "a a a" ...
"""
import argparse, json, sys

from pyboy import PyBoy

ap = argparse.ArgumentParser()
ap.add_argument('--rom', required=True)
ap.add_argument('--state', required=True)
ap.add_argument('--out', required=True)
ap.add_argument('--round', action='append', default=[], help='space separated buttons for one round')
ap.add_argument('--max-frames', type=int, default=60 * 60 * 3)
ap.add_argument('--settle', type=int, default=150, help='frames to wait for a menu to take input')
ap.add_argument('--poke', action='append', default=[],
                help='ADDR=HEXBYTES written into WRAM bank 7 before the first menu input, '
                     'e.g. D196=2E62 to give slot 1 a different first move')
ap.add_argument('--poke-sram', action='append', default=[],
                help='[BANK:]ADDR=HEXBYTES written into save RAM, bank wSRAMBank ($C727) unless BANK is given, '
                     'e.g. A3A8=02 for two of item 1, 1:A047=0C00 for a relic on the first party creature')
ap.add_argument('--force', action='append', default=[],
                help='KIND:LO-HI=VAL forces a roll by its caller return address: s:4838-5050=00 makes every '
                     'AddDividerStep called from the move handlers leave $FFA9 = $00 (chance branches fire), '
                     'm:5420-5440=00 forces MaskDivByC results. The trace records the forced values.')
ap.add_argument('--max-draws', type=int, default=20000,
                help='stop when one round consumes this many rolls (a game-side runaway loop)')
ap.add_argument('--save-end', default=None, help='save a PyBoy state where the run stops (at a menu)')
ap.add_argument('--shots', default=None, help='directory for a screenshot per round')
a = ap.parse_args()

pb = PyBoy(a.rom, window='null', sound_emulated=False, cgb=True)
pb.set_emulation_speed(0)
with open(a.state, 'rb') as f:
    pb.load_state(f)

for spec in a.poke:
    addr, data = spec.split('=')
    addr = int(addr, 16)
    for i, b in enumerate(bytes.fromhex(data)):
        pb.memory[7, addr + i] = b

for spec in a.poke_sram:
    addr, data = spec.split('=')
    if ':' in addr:
        bank, addr = addr.split(':'); bank = int(bank, 16)
    else:
        bank = pb.memory[0xC727]
    addr = int(addr, 16)
    for i, b in enumerate(bytes.fromhex(data)):
        pb.memory[bank, addr + i] = b

def wram7():
    return bytes(pb.memory[7, 0xD000:0xD400])

def ret_addr():
    rf = pb.register_file
    sp = rf.SP
    return pb.memory[sp] | pb.memory[sp + 1] << 8

st = {'draws': None, 'rounds': [], 'menu': False, 'ended': False, 'cur': None}

forces = []
for spec in a.force:
    kind, rest = spec.split(':', 1)
    rng, val = rest.split('=')
    lo, hi = (rng.split('-') + [None])[:2]
    forces.append((kind, int(lo, 16), int(hi or lo, 16), int(val, 16)))
forced = {'s': 0, 'm': 0}

def forced_value(kind, ra):
    for k, lo, hi, v in forces:
        if k == kind and lo <= ra < max(hi, lo + 1):
            return v
    return None

def on_mask(_):
    if st['draws'] is not None:
        ra = ret_addr()
        v = forced_value('m', ra)
        if v is not None:
            pb.register_file.A = v
            forced['m'] += 1
        st['draws'].append(['m', pb.register_file.A, ra, 0])

def on_step(_):
    if st['draws'] is not None:
        rf = pb.register_file
        ra = ret_addr()
        v = forced_value('s', ra)
        if v is not None:
            old = (rf.A - rf.E) & 0xFF
            rf.A = v
            rf.E = (v - old) & 0xFF
            pb.memory[0xFFA9] = v
            forced['s'] += 1
        e = rf.E
        if e >= 0x80: e -= 0x100
        st['draws'].append(['s', e, ra, rf.A])
        if len(st['draws']) > a.max_draws:
            st['runaway'] = True

def on_div(_):
    if st['draws'] is not None:
        st['draws'].append(['d', pb.register_file.A, 0x5414, 0])

def snap():
    return {'wram': wram7().hex(), 'ffa9': pb.memory[0xFFA9], 'cca7': pb.memory[0xCCA7],
            'srambank': pb.memory[0xC727]}

def on_round(_):
    # ApplyFourD096Slots: the player has chosen, the enemy AI runs next
    cur = {'pre': snap(), 'sram': sram()}
    st['cur'] = cur
    st['draws'] = []

def close_round(kind):
    cur = st['cur']
    if cur is None:
        return
    cur['post'] = snap()
    cur['draws'] = st['draws']
    cur['end'] = kind
    st['rounds'].append(cur)
    st['cur'] = None
    st['draws'] = None

def on_menu(_):
    close_round('menu')
    st['menu'] = True

def on_end(_):
    close_round('end')
    st['ended'] = True

def sram():
    # creature records live in cartridge RAM; dump the first two banks' $A000-$A7FF
    out = {}
    try:
        for bank in (0, 1, 2, 3):
            out[str(bank)] = bytes(pb.memory[bank, 0xA000:0xA800]).hex()
    except Exception as ex:  # older PyBoy without banked SRAM access
        out['error'] = str(ex)
    return out

pb.hook_register(0, 0x054E, on_mask, None)
pb.hook_register(0, 0x0564, on_step, None)
pb.hook_register(2, 0x5414, on_div, None)
pb.hook_register(2, 0x6A01, on_round, None)
pb.hook_register(2, 0x6AED, on_menu, None)
pb.hook_register(2, 0x6316, on_end, None)

def run(n):
    for i in range(n):
        pb.tick(1, False)

def press(k, hold=8, after=30):
    pb.button_press(k); run(hold); pb.button_release(k); run(after)

frames = 0
rounds = list(a.round)
ri = 0
st['menu'] = True  # the state is parked at a menu
while frames < a.max_frames and not st['ended'] and not st.get('runaway'):
    if st['menu']:
        st['menu'] = False
        run(a.settle)
        if a.shots:
            pb.tick(1, True); pb.screen.image.save('%s/oracle_r%02d.png' % (a.shots, ri))
        if ri >= len(rounds):
            break
        for k in rounds[ri].split():
            if k.startswith('wait'):
                run(int(k[4:] or 30))
            elif k.endswith('!'):
                # menus drop presses that land mid-redraw: repeat the final
                # confirm until the round actually starts
                for _ in range(40):
                    press(k[:-1])
                    if st['cur'] is not None or st['ended']:
                        break
            else:
                press(k)
        ri += 1
    pb.tick(1, False)
    frames += 1
    # keep text moving: tap A while the battle plays out, but never at a menu
    if not st['menu'] and st['cur'] is not None and frames % 20 == 0:
        press('a', 2, 2)

if a.shots:
    pb.tick(1, True); pb.screen.image.save('%s/oracle_end.png' % a.shots)
if a.save_end:
    with open(a.save_end, 'wb') as f:
        pb.save_state(f)
if st.get('runaway'):
    print('runaway: one round drew more than %d rolls; the open round is dropped' % a.max_draws)
json.dump({'rounds': st['rounds'], 'ended': st['ended'], 'runaway': bool(st.get('runaway')), 'inputs': rounds, 'force': a.force, 'forced': forced},
          open(a.out, 'w'))
print('rounds', len(st['rounds']), 'ended', st['ended'], 'frames', frames, 'forced', forced['s'], forced['m'])
for i, r in enumerate(st['rounds']):
    kinds = {}
    for d in r['draws']:
        kinds[d[0]] = kinds.get(d[0], 0) + 1
    print(i, r['end'], kinds, 'ffa9 %02X->%02X' % (r['pre']['ffa9'], r['post']['ffa9']))
