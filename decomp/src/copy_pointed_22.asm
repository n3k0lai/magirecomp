; Bank 6 at $5A87. StageSramNameTiles stores a source pointer at $CD8D,
; points $CD8F at the buffer past a leading tile index, and calls here
; through CallBankedHL with bank 6. This routine does not write rROMB0.
;
; Both pointers are little-endian words. The destination word at $CD8F
; is loaded into BC and the source word at $CD8D into HL. $22 bytes are
; copied from the source to the destination, then this returns. The ten
; spaces of BlankIndexedName begin at the next byte, $5A9C.
;
; $CD8D and $CD8F are reused as scratch pointers; the names differ by
; caller, so this file leaves them as addresses.

DEF POINTED_22_LEN EQU $22

CopyPointed22::
    ld hl, $CD8F
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, $CD8D
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld d, POINTED_22_LEN
.copyByte:
    ld a, [hl+]
    ld [bc], a
    inc bc
    dec d
    jr nz, .copyByte
    ret
