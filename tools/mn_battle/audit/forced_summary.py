import json, sys, os, glob
def energy(w, sl):
    r = 0x147 + 0x37 * sl
    return (w[r + 7] << 8) | w[r + 8], w[r + 2], w[r + 0x15], bytes(w[r+0xB:r+0x11])
for d in sys.argv[1:]:
    print('==', d)
    for f in sorted(glob.glob(d + '/move_*.json')):
        t = json.load(open(f)); rolls = 0; kills = 0; status = 0; stat = 0
        for r in t['rounds']:
            n = sum(1 for x in r['draws'] if x[0] == 's' and 0x4838 <= x[2] < 0x5050)
            if not n: continue
            rolls += n
            a = bytes.fromhex(r['pre']['wram']); b = bytes.fromhex(r['post']['wram'])
            for sl in (5, 6, 7, 8, 9):
                ea, spa, sta, sa = energy(a, sl); eb, spb, stb, sb = energy(b, sl)
                if spa and ea > 0 and (eb == 0 or spb == 0): kills += 1
                if spa and (stb & ~sta) & 0xFF: status += 1
                if spa and spb == spa and sa != sb: stat += 1
        print(' ', os.path.basename(f)[5:9], 'rounds', len(t['rounds']), 'rolls', rolls, 'kills', kills, 'new-status', status, 'stat-change', stat)
