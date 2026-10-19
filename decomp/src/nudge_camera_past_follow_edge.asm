; Bank 1 at $4AF0. $C6D2 and $C6D3 are a signed pixel step. Bit 7
; marks the negative direction. hSpriteScreenX and hSpriteScreenY
; are the names from queue_sprite_list.asm.
;
; A negative X step is added to the horizontal camera delta at $C843
; only when the screen X is below $54. A non-negative X step is added
; only when the screen X is at least $5C. Y uses $C844 the same way:
; a negative step applies below screen Y $58, and a non-negative step
; applies at screen Y $60 or above. Either miss leaves that axis alone.
; The early `ret` is the negative-Y miss. $4B20 is the non-negative Y
; test, and its `ret nz` is that miss.

NudgeCameraPastFollowEdge::
    ld a, [$c6d2]
    ld e, a
    bit 7, a
    ldh a, [hSpriteScreenX]
    jr z, .x_nonneg

    sub $54
    bit 7, a
    jr nz, .add_x

    jr .y

.x_nonneg:
    sub $5c
    bit 7, a
    jr nz, .y

.add_x:
    ld a, [$c843]
    add e
    ld [$c843], a

.y:
    ld a, [$c6d3]
    ld e, a
    bit 7, a
    ldh a, [hSpriteScreenY]
    jr z, .y_nonneg

    sub $58
    bit 7, a
    jr nz, .add_y

    ret

.y_nonneg:
    sub $60
    bit 7, a
    ret nz

.add_y:
    ld a, [$c844]
    add e
    ld [$c844], a
    ret
