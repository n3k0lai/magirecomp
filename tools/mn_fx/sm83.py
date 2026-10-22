# SM83 instruction decoder: returns (length, mnemonic tuple) and M-cycle timing.
R8 = ['b','c','d','e','h','l','(hl)','a']
R16 = ['bc','de','hl','sp']
R16S = ['bc','de','hl','af']
CC = ['nz','z','nc','c']
ALU = ['add','adc','sub','sbc','and','xor','or','cp']
ROT = ['rlc','rrc','rl','rr','sla','sra','swap','srl']

def decode(rd, pc):
    """rd(addr)->byte. returns dict(op, args, len, cyc, cyc_taken)"""
    o = rd(pc)
    def u8(): return rd(pc+1)
    def u16(): return rd(pc+1) | rd(pc+2) << 8
    def s8():
        v = rd(pc+1); return v-256 if v > 127 else v
    I = lambda op, ln, cyc, *args, taken=None: dict(op=op, args=args, len=ln, cyc=cyc, taken=taken if taken is not None else cyc)
    if o == 0x00: return I('nop',1,1)
    if o == 0x10: return I('stop',2,1)
    if o == 0x76: return I('halt',1,1)
    if o == 0xF3: return I('di',1,1)
    if o == 0xFB: return I('ei',1,1)
    if o == 0xCB:
        p = rd(pc+1); r = R8[p & 7]; hl = (p & 7) == 6
        if p < 0x40: return I(ROT[p >> 3],2,4 if hl else 2,r)
        n = (p >> 3) & 7
        if p < 0x80: return I('bit',2,3 if hl else 2,n,r)
        if p < 0xC0: return I('res',2,4 if hl else 2,n,r)
        return I('set',2,4 if hl else 2,n,r)
    if 0x40 <= o < 0x80:
        d, s = R8[(o >> 3) & 7], R8[o & 7]
        return I('ld8',1,2 if '(hl)' in (d, s) else 1,d,s)
    if 0x80 <= o < 0xC0:
        s = R8[o & 7]; return I(ALU[(o >> 3) & 7],1,2 if s == '(hl)' else 1,s)
    x = o
    if x & 0xC7 == 0x06: d = R8[(x >> 3) & 7]; return I('ld8',2,3 if d == '(hl)' else 2,d,('imm',u8()))
    if x & 0xC7 == 0x04: d = R8[(x >> 3) & 7]; return I('inc8',1,3 if d == '(hl)' else 1,d)
    if x & 0xC7 == 0x05: d = R8[(x >> 3) & 7]; return I('dec8',1,3 if d == '(hl)' else 1,d)
    if x & 0xCF == 0x01: return I('ld16',3,3,R16[x >> 4],u16())
    if x & 0xCF == 0x03: return I('inc16',1,2,R16[x >> 4])
    if x & 0xCF == 0x0B: return I('dec16',1,2,R16[x >> 4])
    if x & 0xCF == 0x09: return I('addhl',1,2,R16[x >> 4])
    if x & 0xCF == 0xC5: return I('push',1,4,R16S[(x >> 4) & 3])
    if x & 0xCF == 0xC1: return I('pop',1,3,R16S[(x >> 4) & 3])
    if x & 0xC7 == 0xC6: return I(ALU[(x >> 3) & 7],2,2,('imm',u8()))
    if x & 0xC7 == 0xC7: return I('rst',1,4,x & 0x38)
    tbl = {
        0x02: ('st_ind',1,2,'bc'), 0x12: ('st_ind',1,2,'de'), 0x22: ('st_hli',1,2), 0x32: ('st_hld',1,2),
        0x0A: ('ld_ind',1,2,'bc'), 0x1A: ('ld_ind',1,2,'de'), 0x2A: ('ld_hli',1,2), 0x3A: ('ld_hld',1,2),
        0x07: ('rlca',1,1), 0x0F: ('rrca',1,1), 0x17: ('rla',1,1), 0x1F: ('rra',1,1),
        0x27: ('daa',1,1), 0x2F: ('cpl',1,1), 0x37: ('scf',1,1), 0x3F: ('ccf',1,1),
        0xE9: ('jphl',1,1), 0xF9: ('ldsphl',1,2), 0xC9: ('ret',1,4), 0xD9: ('reti',1,4),
        0xE2: ('ldh_c_a',1,2), 0xF2: ('ldh_a_c',1,2),
    }
    if x in tbl: t = tbl[x]; return I(t[0],t[1],t[2],*t[3:])
    if x == 0x08: return I('st_sp',3,5,u16())
    if x == 0x18: return I('jr',2,3,pc+2+s8())
    if x in (0x20,0x28,0x30,0x38): return I('jrcc',2,2,CC[(x >> 3) & 3],pc+2+s8(),taken=3)
    if x == 0xC3: return I('jp',3,4,u16())
    if x in (0xC2,0xCA,0xD2,0xDA): return I('jpcc',3,3,CC[(x >> 3) & 3],u16(),taken=4)
    if x == 0xCD: return I('call',3,6,u16())
    if x in (0xC4,0xCC,0xD4,0xDC): return I('callcc',3,3,CC[(x >> 3) & 3],u16(),taken=6)
    if x in (0xC0,0xC8,0xD0,0xD8): return I('retcc',1,2,CC[(x >> 3) & 3],taken=5)
    if x == 0xE0: return I('ldh_n_a',2,3,u8())
    if x == 0xF0: return I('ldh_a_n',2,3,u8())
    if x == 0xEA: return I('st_abs',3,4,u16())
    if x == 0xFA: return I('ld_abs',3,4,u16())
    if x == 0xE8: return I('addsp',2,4,s8())
    if x == 0xF8: return I('ldhlsp',2,3,s8())
    return I('invalid',1,1,x)
