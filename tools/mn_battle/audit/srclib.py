"""Read routines from the matching Magi-Nation decomp source (not ROM bytes)."""
import re, os
class Src:
    def __init__(self, root):
        self.root = root
        self.secs = {}  # bank -> list of (addr, file)
        cur = None
        for line in open(os.path.join(root, "src/scaffold.asm")):
            m = re.match(r'SECTION "[^"]*", (ROM0|ROMX)\[\$([0-9A-Fa-f]+)\](?:, BANK\[\$?([0-9A-Fa-f]+)\])?', line)
            if m:
                bank = 0 if m.group(1) == "ROM0" else int(m.group(3), 16) if line.find("BANK[$") >= 0 else int(m.group(3))
                cur = (bank, int(m.group(2), 16)); continue
            m = re.match(r'\s*INCLUDE "src/([^"]+)"', line)
            if m and cur:
                self.secs.setdefault(cur[0], []).append((cur[1], m.group(1))); cur = None
        for b in self.secs: self.secs[b].sort()
    def labels(self):
        if hasattr(self, "_lab"): return self._lab
        self._lab = {}
        for b, lst in self.secs.items():
            for a, f in lst:
                for k, l in self.lines(f):
                    if k == "label":
                        self._lab.setdefault(l.rstrip(":"), (b, a))
                        break
        return self._lab
    def lines(self, f):
        out = []
        for l in open(os.path.join(self.root, "src", f)):
            l = l.split(";")[0].strip()
            if not l: continue
            if re.match(r'^[\w.]+::?$', l) or re.match(r'^\.[\w]+:?$', l):
                out.append(("label", l.rstrip(":"))); continue
            out.append(("ins", re.sub(r"\s+", " ", l)))
        return out
    def file_at(self, bank, addr):
        for a, f in self.secs.get(bank, []):
            if a == addr: return f
        return None
    def routine(self, bank, addr, follow=True, limit=400):
        """instructions from addr until an unconditional ret/jp/jr/reti, falling through sections"""
        lst = self.secs[bank]; idx = [a for a, _ in lst].index(addr)
        ins = []
        while idx < len(lst):
            for k, l in self.lines(lst[idx][1]):
                if k == "ins":
                    ins.append(l)
                    if re.match(r'^(ret|reti|jp|jr)( [^,]*)?$', l) and not re.match(r'^(ret|jp|jr) (z|nz|c|nc)\b', l):
                        return ins
                    if len(ins) > limit: return ins
            if not follow: return ins
            idx += 1
        return ins
