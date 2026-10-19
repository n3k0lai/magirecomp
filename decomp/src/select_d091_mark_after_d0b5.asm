; Bank 5 at $44F4. RefreshSlotForLowD103 calls this after it writes $D0B5.
;
; The ten mark bytes run from $D091 through $D09A. [$D103] below 5 walks
; backward from $D095. A value of 5 or more walks forward from $D096.
;
; A zero at $D0B5 keeps the first nonzero mark. Its distance from $D091 is
; stored in $D103.
;
; A nonzero $D0B5 skips a mark whose distance equals the old [$D103]. The
; forward walk returns unchanged when HL reaches $D09B. The backward walk
; has no end test.

SelectD091MarkAfterD0B5::
    ld a, [$D0B5]
    cp $00
    jr z, .anyMark
    ld a, [$D103]
    cp $05
    jr c, .skipLow
    ld d, a
    ld bc, $0005
    ld hl, $D091
    add hl, bc
.skipHigh:
    push hl
    ld bc, $D09B
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    add hl, bc
    ld a, h
    or l
    pop hl
    ret z
    ld a, [hl+]
    and a
    jr z, .skipHigh
    ld bc, $D091
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    push hl
    add hl, bc
    ld a, l
    dec a
    cp d
    pop hl
    jr z, .skipHigh
    ld [$D103], a
    ret
.skipLow:
    ld d, a
    ld bc, $0004
    ld hl, $D091
    add hl, bc
.skipLowLoop:
    ld a, [hl-]
    and a
    jr z, .skipLowLoop
    ld bc, $D091
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    push hl
    add hl, bc
    ld a, l
    inc a
    cp d
    pop hl
    jr z, .skipLowLoop
    ld [$D103], a
    ret
.anyMark:
    ld a, [$D103]
    cp $05
    jr c, .anyLow
    ld bc, $0005
    ld hl, $D091
    add hl, bc
.anyHigh:
    ld a, [hl+]
    and a
    jr z, .anyHigh
    ld bc, $D091
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    add hl, bc
    ld a, l
    dec a
    ld [$D103], a
    ret
.anyLow:
    ld bc, $0004
    ld hl, $D091
    add hl, bc
.anyLowLoop:
    ld a, [hl-]
    and a
    jr z, .anyLowLoop
    ld bc, $D091
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    add hl, bc
    ld a, l
    inc a
    ld [$D103], a
    ret
