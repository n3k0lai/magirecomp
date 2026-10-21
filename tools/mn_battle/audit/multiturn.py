import json, sys, glob, os, collections
STAT = ['str', 'skill', 'speed', 'def', 'res', 'luck']
NAMES = {1: 'plague', 2: 'stone', 4: 'hiccups', 8: 'eruption', 0x10: 'hidden', 0x20: 'mirror', 0x40: 'confusion', 0x80: 'diversion'}
ev = collections.defaultdict(set)
for f in sorted(set(sum([glob.glob(p) for p in sys.argv[1:]], []))):
    t = json.load(open(f)); name = '/'.join(f.split('/')[-2:])[:-5]
    for ri, r in enumerate(t['rounds']):
        a = bytes.fromhex(r['pre']['wram']); b = bytes.fromhex(r['post']['wram'])
        for sl in range(1, 10):
            o = 0x147 + 0x37 * sl
            if not b[o + 2] and not a[o + 2]: continue
            for k in range(6):
                x, y = a[o + 0xB + k], b[o + 0xB + k]
                if y == 0x63 and x != 0x63 and sl < 9: ev['stat capped at 99'].add(name)
                if x == 0x63 and y == 0x63 and r['draws'] and sl < 9: pass
                if y == 1 and x > 1: ev['stat floored at 1'].add(name)
            for bit, nm in NAMES.items():
                if not a[o + 0x15] & bit and b[o + 0x15] & bit: ev[nm + ' set'].add(name)
                if a[o + 0x15] & bit and not b[o + 0x15] & bit: ev[nm + ' cleared'].add(name)
            ea = (a[o + 7] << 8) | a[o + 8]; eb = (b[o + 7] << 8) | b[o + 8]
            if a[o + 0x15] & 1 and ea > 0 and eb == 0: ev['plague holder reached 0 energy'].add(name)
for k in sorted(ev):
    v = sorted(ev[k]); print('%-32s %3d traces  e.g. %s' % (k, len(v), ', '.join(v[:3])))
