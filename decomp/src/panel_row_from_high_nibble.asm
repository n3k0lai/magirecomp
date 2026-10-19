; Bank 7 at $47DD. RunPanelIndexThrough2EB6 calls this after clearing $C831.
;
; HL returns $C72B plus eight times the high nibble of wUnknownC9D8.
; The caller keeps that pointer in BC and a second pointer $80 bytes later.
;
; wUnknownC9D8 is the name from indexed_tail_07.asm. $C72B is still unnamed.

PanelRowFromHighNibble::
    ld hl, $C72B
    ld a, [wUnknownC9D8]
    swap a
    and $0F
    ld b, $00
    ld c, a
    sla c
    rl b
    sla c
    rl b
    sla c
    rl b
    add hl, bc
    ret
