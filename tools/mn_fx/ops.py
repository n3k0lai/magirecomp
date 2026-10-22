# Translate SM83 code blocks (decomp routines) into Lua block functions.
from sm83 import decode
CONTROL = {'jp','jr','jpcc','jrcc','call','callcc','ret','retcc','reti','jphl','rst','halt','stop','ei','di','invalid'}
def r8get(r):
    if r == '(hl)': return 'rd(H*256+L)'
    if isinstance(r, tuple): return str(r[1])
    return r.upper()
def r8set(r, v):
    if r == '(hl)': return f'wr(H*256+L, {v})'
    return f'{r.upper()} = {v}'
def r16get(r):
    if r == 'sp': return 'SP'
    if r == 'af': return '(A*256 + (FZ and 128 or 0) + (FN and 64 or 0) + (FH and 32 or 0) + (FC and 16 or 0))'
    return f'({r[0].upper()}*256+{r[1].upper()})'
def r16set(r, v):
    if r == 'sp': return f'SP = band({v}, 0xFFFF)'
    if r == 'af': return f'do local v = {v}; A = rshift(v,8); FZ = band(v,128)~=0; FN = band(v,64)~=0; FH = band(v,32)~=0; FC = band(v,16)~=0 end'
    a, b = r[0].upper(), r[1].upper()
    return f'do local v = band({v},0xFFFF); {a} = rshift(v,8); {b} = band(v,255) end'
CCX = {'nz':'not FZ','z':'FZ','nc':'not FC','c':'FC'}
def alu(op, s):
    v = r8get(s)
    if op == 'add': return f'do local v = {v}; local r = A + v; FH = band(A,15)+band(v,15) > 15; FC = r > 255; A = band(r,255); FZ = A == 0; FN = false end'
    if op == 'adc': return f'do local v = {v}; local c = FC and 1 or 0; local r = A + v + c; FH = band(A,15)+band(v,15)+c > 15; FC = r > 255; A = band(r,255); FZ = A == 0; FN = false end'
    if op == 'sub': return f'do local v = {v}; local r = A - v; FH = band(A,15) < band(v,15); FC = r < 0; A = band(r,255); FZ = A == 0; FN = true end'
    if op == 'sbc': return f'do local v = {v}; local c = FC and 1 or 0; local r = A - v - c; FH = band(A,15) - band(v,15) - c < 0; FC = r < 0; A = band(r,255); FZ = A == 0; FN = true end'
    if op == 'and': return f'A = band(A, {v}); FZ = A == 0; FN = false; FH = true; FC = false'
    if op == 'xor': return f'A = bxor(A, {v}); FZ = A == 0; FN = false; FH = false; FC = false'
    if op == 'or': return f'A = bor(A, {v}); FZ = A == 0; FN = false; FH = false; FC = false'
    if op == 'cp': return f'do local v = {v}; FZ = A == v; FN = true; FH = band(A,15) < band(v,15); FC = A < v end'
def rot(op, r):
    g = r8get(r)
    body = {
     'rlc': 'local c = rshift(v,7); r = band(lshift(v,1),255) + c; FC = c == 1',
     'rrc': 'local c = band(v,1); r = rshift(v,1) + c*128; FC = c == 1',
     'rl':  'r = band(lshift(v,1),255) + (FC and 1 or 0); FC = v >= 128',
     'rr':  'r = rshift(v,1) + (FC and 128 or 0); FC = band(v,1) == 1',
     'sla': 'r = band(lshift(v,1),255); FC = v >= 128',
     'sra': 'r = rshift(v,1) + band(v,128); FC = band(v,1) == 1',
     'swap':'r = band(lshift(v,4),0xF0) + rshift(v,4); FC = false',
     'srl': 'r = rshift(v,1); FC = band(v,1) == 1',
    }[op]
    return f'do local v = {g}; local r; {body}; FZ = r == 0; FN = false; FH = false; {r8set(r,"r")} end'

def gen_ins(ins, pc, nxt):
    op, a = ins['op'], ins['args']
    if op == 'nop': return ''
    if op == 'ld8': return r8set(a[0], r8get(a[1]))
    if op == 'ld16': return r16set(a[0], str(a[1]))
    if op == 'inc8': return f'do local v = band({r8get(a[0])}+1,255); FH = band(v,15) == 0; FZ = v == 0; FN = false; {r8set(a[0],"v")} end'
    if op == 'dec8': return f'do local v = band({r8get(a[0])}-1,255); FH = band(v,15) == 15; FZ = v == 0; FN = true; {r8set(a[0],"v")} end'
    if op == 'inc16': return r16set(a[0], r16get(a[0]) + '+1')
    if op == 'dec16': return r16set(a[0], r16get(a[0]) + '-1')
    if op == 'addhl': return f'do local hl = H*256+L; local v = {r16get(a[0])}; local r = hl + v; FH = band(hl,0xFFF)+band(v,0xFFF) > 0xFFF; FC = r > 0xFFFF; FN = false; r = band(r,0xFFFF); H = rshift(r,8); L = band(r,255) end'
    if op == 'push': return f'do local v = {r16get(a[0])}; SP = band(SP-1,0xFFFF); wr(SP, rshift(v,8)); SP = band(SP-1,0xFFFF); wr(SP, band(v,255)) end'
    if op == 'pop': return f'do local lo = rd(SP); local hi = rd(band(SP+1,0xFFFF)); SP = band(SP+2,0xFFFF); {r16set(a[0], "hi*256+lo" if a[0] != "af" else "hi*256+band(lo,0xF0)")} end'
    if op in ('add','adc','sub','sbc','and','xor','or','cp'): return alu(op, a[0])
    if op in ('rlc','rrc','rl','rr','sla','sra','swap','srl'): return rot(op, a[0])
    if op == 'bit': return f'FZ = band({r8get(a[1])}, {1 << a[0]}) == 0; FN = false; FH = true'
    if op == 'res': return r8set(a[1], f'band({r8get(a[1])}, {255 ^ (1 << a[0])})')
    if op == 'set': return r8set(a[1], f'bor({r8get(a[1])}, {1 << a[0]})')
    if op == 'st_ind': return f'wr({r16get(a[0])}, A)'
    if op == 'ld_ind': return f'A = rd({r16get(a[0])})'
    if op == 'st_hli': return 'do local hl = H*256+L; wr(hl, A); hl = band(hl+1,0xFFFF); H = rshift(hl,8); L = band(hl,255) end'
    if op == 'st_hld': return 'do local hl = H*256+L; wr(hl, A); hl = band(hl-1,0xFFFF); H = rshift(hl,8); L = band(hl,255) end'
    if op == 'ld_hli': return 'do local hl = H*256+L; A = rd(hl); hl = band(hl+1,0xFFFF); H = rshift(hl,8); L = band(hl,255) end'
    if op == 'ld_hld': return 'do local hl = H*256+L; A = rd(hl); hl = band(hl-1,0xFFFF); H = rshift(hl,8); L = band(hl,255) end'
    if op == 'rlca': return 'do local c = rshift(A,7); A = band(lshift(A,1),255) + c; FC = c == 1; FZ = false; FN = false; FH = false end'
    if op == 'rrca': return 'do local c = band(A,1); A = rshift(A,1) + c*128; FC = c == 1; FZ = false; FN = false; FH = false end'
    if op == 'rla': return 'do local c = A >= 128; A = band(lshift(A,1),255) + (FC and 1 or 0); FC = c; FZ = false; FN = false; FH = false end'
    if op == 'rra': return 'do local c = band(A,1) == 1; A = rshift(A,1) + (FC and 128 or 0); FC = c; FZ = false; FN = false; FH = false end'
    if op == 'daa': return 'A, FZ, FH, FC = daa(A, FN, FH, FC)'
    if op == 'cpl': return 'A = bxor(A,255); FN = true; FH = true'
    if op == 'scf': return 'FN = false; FH = false; FC = true'
    if op == 'ccf': return 'FN = false; FH = false; FC = not FC'
    if op == 'ldsphl': return 'SP = H*256+L'
    if op == 'ldh_c_a': return 'wr(0xFF00+C, A)'
    if op == 'ldh_a_c': return 'A = rd(0xFF00+C)'
    if op == 'ldh_n_a': return f'wr({0xFF00+a[0]}, A)'
    if op == 'ldh_a_n': return f'A = rd({0xFF00+a[0]})'
    if op == 'st_abs': return f'wr({a[0]}, A)'
    if op == 'ld_abs': return f'A = rd({a[0]})'
    if op == 'st_sp': return f'wr({a[0]}, band(SP,255)); wr({a[0]+1}, rshift(SP,8))'
    if op == 'addsp': return f'do local v = {a[0]}; local u = band(v,255); FH = band(SP,15)+band(u,15) > 15; FC = band(SP,255)+u > 255; FZ = false; FN = false; SP = band(SP+v,0xFFFF) end'
    if op == 'ldhlsp': return f'do local v = {a[0]}; local u = band(v,255); FH = band(SP,15)+band(u,15) > 15; FC = band(SP,255)+u > 255; FZ = false; FN = false; local r = band(SP+v,0xFFFF); H = rshift(r,8); L = band(r,255) end'
    raise Exception('unhandled '+op)

def push_ret(v): return f'SP = band(SP-1,0xFFFF); wr(SP, {v >> 8}); SP = band(SP-1,0xFFFF); wr(SP, {v & 255})'
POP_RET = 'local lo = rd(SP); local hi = rd(band(SP+1,0xFFFF)); SP = band(SP+2,0xFFFF)'

BREAKS = {0x0A66}
def translate_block(rd, pc, maxins=24):
    """returns (lua_body, successors(list of static targets), calls(list), end_pc)"""
    lines = []; cyc = 0; succ = []; calls = []; start = pc
    n = 0
    while True:
        if pc != start and pc in BREAKS:
            lines.append(f'CY = CY + {cyc}; return {pc}'); succ.append(pc); break
        ins = decode(rd, pc); op = ins['op']; nxt = pc + ins['len']; a = ins['args']
        n += 1
        if op not in CONTROL:
            cyc += ins['cyc']
            s = gen_ins(ins, pc, nxt)
            if s: lines.append(s)
            # writes to MBC bank registers or IO that can change timing: end block after absolute stores to ROM area
            if op == 'st_abs' and a[0] < 0x8000: lines.append(f'CY = CY + {cyc}; return {nxt}'); succ.append(nxt); break
            if op in ('ld8','st_ind','st_hli','st_hld') and False: pass
            if n >= maxins: lines.append(f'CY = CY + {cyc}; return {nxt}'); succ.append(nxt); break
            pc = nxt; continue
        # control
        if op == 'jp': lines.append(f'CY = CY + {cyc+ins["cyc"]}; return {a[0]}'); succ.append(a[0])
        elif op == 'jr': lines.append(f'CY = CY + {cyc+ins["cyc"]}; return {a[0]}'); succ.append(a[0])
        elif op in ('jpcc','jrcc'):
            lines.append(f'if {CCX[a[0]]} then CY = CY + {cyc+ins["taken"]}; return {a[1]} end')
            lines.append(f'CY = CY + {cyc+ins["cyc"]}; return {nxt}'); succ += [a[1], nxt]
        elif op == 'call':
            lines.append(f'{push_ret(nxt)}; CY = CY + {cyc+ins["cyc"]}; return {a[0]}'); calls.append(a[0]); succ.append(nxt)
        elif op == 'callcc':
            lines.append(f'if {CCX[a[0]]} then {push_ret(nxt)}; CY = CY + {cyc+ins["taken"]}; return {a[1]} end')
            lines.append(f'CY = CY + {cyc+ins["cyc"]}; return {nxt}'); calls.append(a[1]); succ.append(nxt)
        elif op == 'rst':
            lines.append(f'{push_ret(nxt)}; CY = CY + {cyc+ins["cyc"]}; return {a[0]}'); calls.append(a[0]); succ.append(nxt)
        elif op == 'ret': lines.append(f'do {POP_RET}; CY = CY + {cyc+ins["cyc"]}; return hi*256+lo end')
        elif op == 'reti': lines.append(f'do {POP_RET}; IME = true; CY = CY + {cyc+ins["cyc"]}; return hi*256+lo end')
        elif op == 'retcc':
            lines.append(f'if {CCX[a[0]]} then {POP_RET}; CY = CY + {cyc+ins["taken"]}; return hi*256+lo end')
            lines.append(f'CY = CY + {cyc+ins["cyc"]}; return {nxt}'); succ.append(nxt)
        elif op == 'jphl': lines.append(f'CY = CY + {cyc+ins["cyc"]}; return H*256+L')
        elif op == 'halt': lines.append(f'CY = CY + {cyc+ins["cyc"]}; HALT = true; return {nxt}'); succ.append(nxt)
        elif op == 'stop': lines.append(f'CY = CY + {cyc+ins["cyc"]}; STOP(); return {nxt}'); succ.append(nxt)
        elif op == 'di': lines.append(f'IME = false; CY = CY + {cyc+ins["cyc"]}; return {nxt}'); succ.append(nxt)
        elif op == 'ei': lines.append(f'EI_PENDING = true; CY = CY + {cyc+ins["cyc"]}; return {nxt}'); succ.append(nxt)
        elif op == 'invalid': lines.append(f'error(("invalid opcode %02X at %04X"):format({a[0]}, {pc}))')
        break
    return '\n    '.join(lines), succ, calls, pc
