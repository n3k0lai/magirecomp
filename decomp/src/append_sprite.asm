; Append one sprite at the shadow-OAM cursor.
;
; C is Y, B is X, D is the tile, and E is the attributes. HL is $C000
; (wShadowOAM) plus the low byte in $C728, the same cursor HideLeftoverSprites
; reads. The four bytes are stored in OAM order, then that new low byte is
; written back to $C728.
;
; $0604, $0605, $0607, and $060A are entries inside this routine. $0604 stores
; A as Y and continues with X, tile, and attributes. $0605 stores B, then D
; and E. $0607 stores D and E. $060A stores E, then every entry commits the
; cursor. QueueBlinkSprite calls $05FD with Y in C, X in B, the tile in D,
; and attributes $09 in E.

AppendSprite::
    ld h, HIGH(wShadowOAM)
    ld a, [$c728]
    ld l, a
    ld a, c
; $0604. A is the Y byte. HL points at the free slot.
.y:
    ld [hli], a
; $0605. B is X.
.x:
    ld a, b
    ld [hli], a
; $0607. D is the tile.
.tile:
    ld a, d
    ld [hli], a
    ld a, e
; $060A. E is the attributes. The cursor then advances by four.
.attr:
    ld [hli], a
    ld a, l
    ld [$c728], a
    ret
