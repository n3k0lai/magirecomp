; Called from ClearMarksAndWalkSlots when the little-endian word at $D06D
; is nonzero and its low byte is not 1.
;
; A nonzero [$D016] returns immediately.
;
; Otherwise the word at $D14E is ORed with the four bytes at $D092 and the
; four bytes at $D07E. All of those clear stores 3 at $D016 and returns.
;
; A nonzero OR then ORs the four bytes at $D096. A nonzero result returns
; with $D016 still 0.
;
; Those four clear copies 0 into B and reads [$D09A]. Zero stores 2 at
; $D016. Nonzero ORs the four bytes at $D082 with the two bytes at $D33D.
; A nonzero OR returns. Zero stores 2 at $D016.

SetD016WhenSlotsClosed::
    ld a, [$D016]
    and a
    ret nz
    xor a
    ld hl, $D14E
    or [hl]
    inc hl
    or [hl]
    ld hl, $D092
    ld d, $04
.orD092:
    or [hl]
    inc hl
    dec d
    jr nz, .orD092
    ld hl, $D07E
    ld d, $04
.orD07E:
    or [hl]
    inc hl
    dec d
    jr nz, .orD07E
    and a
    jr nz, .orD096Start
    ld a, $03
    ld [$D016], a
    ret
.orD096Start:
    ld hl, $D096
    xor a
    ld d, $04
.orD096:
    or [hl]
    inc hl
    dec d
    jr nz, .orD096
    and a
    ret nz
    ld b, a
    ld a, [$D09A]
    and a
    jr z, .storeTwo
    ld hl, $D082
    ld d, $04
    ld a, b
.orD082:
    or [hl]
    inc hl
    dec d
    jr nz, .orD082
    ld hl, $D33D
    or [hl]
    inc hl
    or [hl]
    ret nz
.storeTwo:
    ld a, $02
    ld [$D016], a
    ret
