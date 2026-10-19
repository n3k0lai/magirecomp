; Bank 5's $57BA. Called after $D0C0, $D0C1, and $D0C2 are written.
;
; [$D0C2] of $6C or above returns at once. A smaller value is reduced by
; $58, wrapping when it is below $58, then doubled. That index selects a
; word from the table at $5CF1. MulCByB multiplies [$D0C0] by 3, and that
; offset is added to the selected word.
;
; D receives the byte at the sum. BC receives the word that follows it.
; A is [$D0C1]. $38F0, still INCBIN in bank 0, is called with those
; registers, and this routine returns.
;
; MulCByB is already source. The word table at $5CF1 is still INCBIN.

ApplyIndexedIdRecord::
    ld a, [$D0C2]
    cp $6C
    ret nc
    sub $58
    add a
    ld c, a
    ld b, $00
    ld hl, $5CF1
    add hl, bc
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld a, [$D0C0]
    ld b, a
    ld c, $03
    call MulCByB
    pop bc
    add hl, bc
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld a, [$D0C1]
    call $38F0
    ret
