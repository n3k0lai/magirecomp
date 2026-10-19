; LCD STAT interrupt. The vector at $0048 jumps here.
;
; The handler pointer is little-endian in HRAM. This saves AF and HL, then
; jumps through that pointer. The handler pops both and reti. The default-state
; setup at $082D stores $2AB7, whose body is only that pop and reti.
;
; Both HRAM reads are the 2-byte form.

DEF hSTATHandler EQU $FF99

LCDStat::
    push af
    push hl
    ldh a, [hSTATHandler]
    ld l, a
    ldh a, [hSTATHandler + 1]
    ld h, a
    jp hl
