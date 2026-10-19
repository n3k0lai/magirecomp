; Queue a sprite list using the map cell as the raw X and Y bases.
;
; $0610 loads hSpriteScreenY. $0612 stores that value in hPrevSpriteScreenY
; and writes $FF to hSpriteScreenY, the same sentinel QueueSpriteList plants
; before it decides the object is on screen. $0618 then copies hObjectCellX
; into D and hSpriteScreenX, copies hObjectCellY into E, and jumps to
; QueueSpriteList's copy loop at $05DB. Those two cell reads use the
; three-byte `ld a, [nn]` form. E is the Y addend for the list and is not
; written back to hSpriteScreenY, which stays $FF.
;
; Names for the HRAM bytes come from queue_sprite_list.asm.

QueueSpriteListAtCell::
    ldh a, [hSpriteScreenY]
; $0612. A is already the screen Y to remember.
.haveScreenY:
    ldh [hPrevSpriteScreenY], a
    ld a, $ff
    ldh [hSpriteScreenY], a
; $0618. D and E become the cell bytes, then the list is copied.
.useCell:
    ld a, [hObjectCellX]
    ld d, a
    ldh [hSpriteScreenX], a
    ld a, [hObjectCellY]
    ld e, a
    jp $05DB
