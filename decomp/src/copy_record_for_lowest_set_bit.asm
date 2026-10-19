; Bank 7 at $68B4.
;
; [$CD93] is shifted right until bit 0 is set. B counts those shifts, the
; index of the lowest set bit. A value of $00 never leaves the loop.
;
; MulCByB multiplies that index by nine. Adding $646D, still INCBIN in this
; bank, selects a nine-byte record. Those bytes are copied to $C95F, and
; $FC is stored in the next byte.
;
; MulCByB is the name from multiply.asm. The caller StageNameTextAndScript41C1
; writes the selector to $CD93 before this call.

DEF wLowestBitSelect EQU $CD93
DEF LOWEST_BIT_RECORD_BASE EQU $646D
DEF LOWEST_BIT_RECORD_DEST EQU $C95F
DEF LOWEST_BIT_RECORD_LEN EQU 9
DEF LOWEST_BIT_RECORD_END EQU $FC

CopyRecordForLowestSetBit::
    ld a, [wLowestBitSelect]
    ld b, $ff
.shift:
    inc b
    bit 0, a
    jr nz, .copy
    srl a
    jr .shift
.copy:
    ld c, LOWEST_BIT_RECORD_LEN
    call MulCByB
    ld bc, LOWEST_BIT_RECORD_BASE
    add hl, bc
    ld bc, LOWEST_BIT_RECORD_DEST
    ld d, LOWEST_BIT_RECORD_LEN
.byte:
    ld a, [hl+]
    ld [bc], a
    inc bc
    dec d
    jr nz, .byte
    ld a, LOWEST_BIT_RECORD_END
    ld [bc], a
    ret
