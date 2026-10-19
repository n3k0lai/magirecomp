; Queue one sprite, blinking tile $81 unless a flag forces tile $82.
;
; $CCA8 is the tile id written into the OAM record. It starts as $82.
; When $CD80 is 1, or $CCB9 is 0, that tile stays and the sprite is always
; queued. Otherwise the tile becomes $81 and $CD7F counts up, wrapping from
; $1E back to 0. Counts below $0F return without a sprite, so the $81 tile
; is hidden for fifteen steps and shown for the next sixteen.
;
; The record is Y, X, tile, attributes, appended by $05FD into the $C000
; buffer. X is ($CD82 + 1) * 8. Y is ($CD83 + 2) * 8. Attributes are $09
; (OBP1, tile data from VRAM bank 1). $05FD is still INCBIN.

QueueBlinkSprite::
    ld a, $82
    ld [$cca8], a
    ld a, [$cd80]
    cp $01
    jr z, .queue

    ld a, [$ccb9]
    cp $00
    jr z, .queue

    ld a, $81
    ld [$cca8], a
    ld hl, $cd7f
    ld a, [hl]
    inc a
    cp $1f
    jr nz, .storeCount

    xor a

.storeCount
    ld [hl], a
    cp $0f
    ret c

.queue
    ld a, [$cd82]
    inc a
    add a
    add a
    add a
    ld b, a
    ld a, [$cd83]
    inc a
    inc a
    add a
    add a
    add a
    ld c, a
    ld a, [$cca8]
    ld d, a
    ld e, $09
    call $05fd
    ret
