; Bank 5 at $57E5. The $19 bytes that follow ApplyIndexedIdRecord.
;
; [$D0C0] is multiplied by 3 with MulCByB. That offset is added to the
; fixed base $5E2D, which is still INCBIN. D receives the byte at the
; sum. BC receives the word that follows it, low byte then high byte.
; A is [$D0C1]. StoreIndexedSlotRecord writes those fields into the
; slot A selects, then this routine returns.
;
; Unlike ApplyIndexedIdRecord, there is no [$D0C2] gate and no lookup
; through the word table at $5CF1.

ApplyFixedIdRecord5E2D::
    ld a, [$D0C0]
    ld b, a
    ld c, $03
    call MulCByB
    ld bc, $5E2D
    add hl, bc
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld a, [$D0C1]
    call StoreIndexedSlotRecord
    ret
