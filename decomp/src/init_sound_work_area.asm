; Initialise the sound work area. A is the value kept in $DF04 and C the one
; kept in $DF01. Clears 255 bytes from $DF00, stores C at $DF01, runs $449D,
; then sets $DF11 = $FF, $DF04 = A, $DF00 = $30, $DF03 = $DE, $DFF8 = $FF and
; $DF02 = $F5. What those defaults mean is still unknown.

InitSoundWorkArea::
    push af
    ld hl, $DF00
    ld de, $00FF
.clear:
    ld a, d
    or e
    jr z, .cleared
    xor a
    ld [hl+], a
    dec de
    jr .clear
.cleared:
    ld a, c
    ld [$DF01], a
    call $449D
    ld a, $FF
    ld [$DF11], a
    pop af
    ld [$DF04], a
    ld a, $30
    ld [$DF00], a
    ld a, $DE
    ld [$DF03], a
    ld a, $FF
    ld [$DFF8], a
    ld a, $F5
    ld [$DF02], a
    ret
