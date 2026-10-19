; Bank 2 at $72FD. Called when [$D0D9] is nonzero and [$D0CE] is at least $0A.
;
; $7366, still INCBIN, runs first. A nonzero byte at $D0C9 returns.
; Otherwise bit 7 of [$D105] is cleared and the rest is compared with 5.
; AddDividerStep returns a byte; its bit 0 chooses the scan.
;
; Below 5, bit 0 set walks backward from $D095 until a nonzero byte.
; Bit 0 clear walks forward from $D092 for at most four bytes and keeps
; the first nonzero, or $D091 when those four are zero.
;
; At least 5, bit 0 set walks forward from $D096 until a nonzero byte.
; Bit 0 clear walks backward from $D099 for at most four bytes and keeps
; the first nonzero, or $D09A when those four are zero.
;
; The kept address minus $D091 is stored in [$D103].
; AddDividerStep is already source.

PickD091MarkIntoD103::
    call $7366
    ld a, [$D0C9]
    and a
    ret nz
    ld a, [$D105]
    res 7, a
    cp $05
    jr nc, .highHalf
    call AddDividerStep
    bit 0, a
    jr z, .scanLowForward
    ld hl, $D095
.walkBackFromD095:
    ld a, [hl-]
    and a
    jr z, .walkBackFromD095
    inc hl
.storeOffsetFromD091:
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
    ld [$D103], a
    ret
.scanLowForward:
    ld hl, $D092
    ld d, $04
.lowForward:
    ld a, [hl+]
    and a
    jr nz, .keepPrevious
    dec d
    jr nz, .lowForward
    ld hl, $D091
    jr .storeOffsetFromD091
.keepPrevious:
    dec hl
    jr .storeOffsetFromD091
.highHalf:
    call AddDividerStep
    bit 0, a
    jr z, .scanHighBackward
    ld hl, $D096
.walkForwardFromD096:
    ld a, [hl+]
    and a
    jr z, .walkForwardFromD096
    dec hl
    jr .storeOffsetFromD091
.scanHighBackward:
    ld hl, $D099
    ld d, $04
.highBackward:
    ld a, [hl-]
    and a
    jr nz, .keepNext
    dec d
    jr nz, .highBackward
    ld hl, $D09A
    jr .storeOffsetFromD091
.keepNext:
    inc hl
    jr .storeOffsetFromD091
