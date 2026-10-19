; Bank 5's $5E62. DrawIndexedSlots stores a record word at $CDD1, the
; buffer pointer $CD91 at $CDD3, and $01 at $CDD5, then calls here.
;
; A zero word writes seven $20 bytes at that pointer. A nonzero word copies
; seven bytes from word+$09. When $CDD5 is zero, that is the whole write.
; Otherwise the nonzero path appends $20 and the byte at word+$02, which
; lands at $CD99 for FormatStartDigits. The zero path appends four $00
; bytes, so that same $CD99 byte stays zero and the caller draws blanks.
;
; wIndexedWordLow ($CDD1), wIndexedTilePtr ($CDD3), and wIndexedCallFlag
; ($CDD5) are the names from indexed_tail_08.asm. $5E85 and $5E92 also fall
; inside this routine.

DEF INDEXED_FIELD_SKIP EQU $09
DEF INDEXED_COPY_LEN EQU $07
DEF INDEXED_SPACE EQU $20
FillIndexedSlot::
    ld hl, $cdd1
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld a, b
    or c
    jr z, .zeroWord

    ld hl, INDEXED_FIELD_SKIP
    add hl, bc
    ld b, h
    ld c, l
    ld hl, $cdd3
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld d, INDEXED_COPY_LEN

.copyField:
    ld a, [bc]
    ld [hl+], a
    inc bc
    dec d
    jr nz, .copyField

    ld a, [$cdd5]
    and a
    ret z

    ld a, INDEXED_SPACE
    ld [hl+], a
    ld a, [$cdd2]
    ld b, a
    ld a, [$cdd1]
    ld c, a
    inc bc
    inc bc

.storeWordByte:
    ld a, [bc]
    ld [hl], a
    ret

.zeroWord:
    ld hl, $cdd3
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, INDEXED_SPACE
    ld d, INDEXED_COPY_LEN

.fillSpaces:
    ld [hl+], a
    dec d
    jr nz, .fillSpaces

    ld a, [$cdd5]
    and a
    ret z

    xor a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ret
