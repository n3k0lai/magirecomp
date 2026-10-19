; Call the bank 5 word at $4054 indexed by [$D104].
;
; A is doubled, so each entry is a little-endian address. JumpHL is the
; call at $0789: jp hl enters that pointer, and the callee's ret returns
; here, then this ret returns to $5FDF. This routine does not write
; rROMB0. $5FDF calls it when [$D104] is nonzero. How many words sit at
; $4054 is still unknown; the first four look like addresses in this bank.

CallWordAt4054ForD104::
    ld a, [$d104]
    add a
    ld hl, $4054
    ld c, a
    ld b, $00
    add hl, bc
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call JumpHL
    ret

CallWordAt4054ForD104End:
