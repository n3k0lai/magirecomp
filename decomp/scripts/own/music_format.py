"""Parser for the song format read by InstallSoundIndex and the bank 0
countdown routines (see scripts/own/music-format.md)."""
d=open('roms/magination.gbc','rb').read()
B30=0xC0000-0x4000
def r30(a): return d[B30+a]
def songs():
    out=[]
    for k in range(r30(0x5A87)):
        a=0x5A79+(r30(0x5A85)|r30(0x5A86)<<8)+3*k
        out.append((r30(a)+0x30, r30(a+1)|r30(a+2)<<8))
    return out
class Song:
    def __init__(s,bank,p):
        s.bank,s.p=bank,p; s.cov={}
        o=bank*0x4000-0x4000
        R=lambda a: d[o+a]
        BE=lambda a: R(a)<<8|R(a+1)
        s.R=R
        T=p+0x84; s.T=T
        trk=T+BE(T); pat=T+BE(T+2)
        s.trk_tab=trk; s.pat_tab=pat
        s.tracks=[]; acts=set()
        for n in range(4):
            w=BE(trk+2*n)
            if not w: s.tracks.append(None); continue
            a=T+w; start=a; recs=[]
            while True:
                act=R(a+2)
                if act==0xFF: recs.append(('end',a)); a+=7; break
                if act==0xFE: recs.append(('loop',a)); a+=7; break
                acts.add(act&0x7F); recs.append(('rec',a)); a+=3
            s.tracks.append((start,a,recs))
        s.acts=acts
        npat=max(acts)+1 if acts else 0
        s.pats=[]
        for i in range(npat):
            a=T+BE(pat+2*i); start=a; ev=[]
            while True:
                b0,b2=R(a),R(a+2); tag=b0>>4
                if b2==0xFF and tag==0xF: ev.append(('end',a,3)); a+=3; break
                n=3
                if b2&0x80 and tag==0: ev.append(('prog',a,3)); a+=3; continue
                if b2&0x80: n+=1
                n+= 2 if R(a+n)&0x80 else 1
                ev.append(('note',a,n)); a+=n
            s.pats.append((start,a,ev))
    def ranges(s):
        rg=[(s.p,s.p+0x84,'hdr'),(s.T,s.T+6,'tbl'),(s.trk_tab,s.trk_tab+8,'trk_tab'),(s.pat_tab,s.pat_tab+2*len(s.pats),'pat_tab')]
        for t in s.tracks:
            if t: rg.append((t[0],t[1],'track'))
        for p in s.pats: rg.append((p[0],p[1],'pat'))
        return rg
if __name__=='__main__':
    import collections
    S=songs(); print(len(S),sorted(set(b for b,_ in S)))
    byb=collections.defaultdict(list)
    for b,p in S: byb[b].append(p)
    for b in sorted(byb):
        cov=set()
        for p in sorted(set(byb[b])):
            s=Song(b,p)
            for a0,a1,k in s.ranges(): cov.update(range(a0,a1))
        x=d[b*0x4000:(b+1)*0x4000]; t=len(x.rstrip(b'\0'))+0x4000
        mx=max(cov); gaps=[a for a in range(0x4000,t) if a not in cov]
        print(hex(b),len(set(byb[b])),'songs cov',len(cov),'data',t-0x4000,'max',hex(mx+1),'gaps',len(gaps),hex(gaps[0]) if gaps else '')
