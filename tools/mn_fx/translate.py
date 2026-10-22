# SM83 -> Lua block translator, v2: per-instruction cycle accounting (T-cycles) with
# per-access timing, so interrupts, IO reads and DMA land on the same instruction
# boundaries as the reference emulator. Templates for instruction semantics come from ops.py.
import json, sys
import os
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from sm83 import decode
import ops as G
T = json.load(open(os.path.join(HERE, 'pyboy_timing.json')))

def opkey(rd, pc):
    o = rd(pc)
    if o == 0xCB: return '%X' % (0x100 + rd(pc + 1))
    return '%02X' % o

def timing(key):
    name, seq = T[key]
    acc = []; c = 0
    for e in seq:
        if e[0] == 'c': c += e[1]
        elif e[0] in ('r', 'w'): acc.append((c, e[1]))
    return acc, c

def branch_totals(key):
    name, seq = T[key]
    xs = [i for i, e in enumerate(seq) if e[0] == 'x']
    if not xs: return sum(e[1] for e in seq if e[0] == 'c'), None
    # [x(if) ... x(else) ...]
    taken = sum(e[1] for e in seq[xs[0] + 1:xs[1]] if e[0] == 'c')
    nott = sum(e[1] for e in seq[xs[1] + 1:] if e[0] == 'c')
    return taken, nott

def inject(s, acc):
    """add timing args to rd(/wr( calls in evaluation (closing-paren) order"""
    stack = []; closes = []; i = 0; depth = 0; marks = []
    while i < len(s):
        if (s.startswith('rd(', i) or s.startswith('wr(', i)) and (i == 0 or not (s[i-1].isalnum() or s[i-1] == '_')):
            depth += 1; stack.append(depth); i += 3; continue
        ch = s[i]
        if ch == '(': depth += 1
        elif ch == ')':
            if stack and stack[-1] == depth: stack.pop(); marks.append(i)
            depth -= 1
        i += 1
    if len(marks) != len(acc): raise Exception('access count %d vs timing %d in %s' % (len(marks), len(acc), s))
    out = s
    for k in range(len(marks) - 1, -1, -1):
        pre, off = acc[k]; m = marks[k]
        out = out[:m] + (', CY+%d, %d' % (pre, off)) + out[m:]
    return out

PUSH = lambda v: 'SP = band(SP-1,0xFFFF); wr(SP, %d); SP = band(SP-1,0xFFFF); wr(SP, %d)' % (v >> 8, v & 255)
POPS = 'local lo = rd(SP); local hi = rd(band(SP+1,0xFFFF)); SP = band(SP+2,0xFFFF)'
BREAKS = {0x0A66}

def translate_block(rd, pc, maxins=32):
    lines = []; succ = []; calls = []; start = pc; n = 0; ents = []
    while True:
        if pc != start and pc in BREAKS:
            lines.append('return %d' % pc); succ.append(pc); break
        ins = decode(rd, pc); op = ins['op']; nxt = pc + ins['len']; a = ins['args']; key = opkey(rd, pc)
        n += 1
        if pc != start:
            ents.append(pc); lines.append('::L%d::' % len(ents))
        if op not in G.CONTROL:
            acc, tot = timing(key)
            s = G.gen_ins(ins, pc, nxt)
            s = inject(s, acc) if s else s
            if s: lines.append('do ' + s + ' end')
            lines.append('CY = CY + %d; if CY >= LIM then return %d end' % (tot, nxt))
            if op == 'st_abs' and a[0] < 0x8000: lines.append('return %d' % nxt); succ.append(nxt); break
            if n >= maxins: lines.append('return %d' % nxt); succ.append(nxt); break
            pc = nxt; continue
        tk, nt = branch_totals(key) if op not in ('invalid', 'stop', 'ei') else (4, None)
        if op in ('jp', 'jr'): lines.append('CY = CY + %d; return %d' % (tk, a[0])); succ.append(a[0])
        elif op in ('jpcc', 'jrcc'):
            lines.append('if %s then CY = CY + %d; return %d end' % (G.CCX[a[0]], tk, a[1]))
            lines.append('CY = CY + %d; return %d' % (nt, nxt)); succ += [a[1], nxt]
        elif op == 'call':
            acc, _ = timing(key)
            lines.append(inject(PUSH(nxt), acc) + '; CY = CY + %d; return %d' % (tk, a[0])); calls.append(a[0]); succ.append(nxt)
        elif op == 'callcc':
            # taken path: c16 w0 c4 w0 c4 (pushes after 16 cycles)
            lines.append('if %s then %s; CY = CY + %d; return %d end' % (G.CCX[a[0]], inject(PUSH(nxt), [(16, 0), (20, 0)]), tk, a[1]))
            lines.append('CY = CY + %d; return %d' % (nt, nxt)); calls.append(a[1]); succ.append(nxt)
        elif op == 'rst':
            acc, _ = timing(key)
            lines.append(inject(PUSH(nxt), acc) + '; CY = CY + %d; return %d' % (tk, a[0])); calls.append(a[0]); succ.append(nxt)
        elif op == 'ret':
            acc, _ = timing(key)
            lines.append('do %s; CY = CY + %d; return hi*256+lo end' % (inject(POPS, acc), tk))
        elif op == 'reti':
            acc, _ = timing(key)
            lines.append('do RETI(); %s; CY = CY + %d; return hi*256+lo end' % (inject(POPS, [(4, 0), (8, 0)]), tk))
        elif op == 'retcc':
            lines.append('if %s then %s; CY = CY + %d; return hi*256+lo end' % (G.CCX[a[0]], inject(POPS, [(8, 0), (12, 0)]), tk))
            lines.append('CY = CY + %d; return %d' % (nt, nxt)); succ.append(nxt)
        elif op == 'jphl': lines.append('CY = CY + %d; return H*256+L' % tk)
        elif op == 'halt': lines.append('HALTI(); CY = CY + 4; return %d' % pc); succ.append(nxt)
        elif op == 'stop': lines.append('STOPI(CY); CY = CY + 4; return %d' % nxt); succ.append(nxt)
        elif op == 'di': lines.append('DII(); CY = CY + 4; return %d' % nxt); succ.append(nxt)
        elif op == 'ei': lines.append('EII(); CY = CY + 4; return %d' % nxt); succ.append(nxt)
        elif op == 'invalid': lines.append('error(("invalid opcode %%02X at %%04X"):format(%d, %d))' % (a[0], pc))
        break
    if ents:
        lines.insert(0, 'if e ~= 0 then ' + ' else'.join('if e == %d then goto L%d' % (i + 1, i + 1) for i in range(len(ents))) + ' end end')
    return '\n    '.join(lines), succ, calls, pc, ents
