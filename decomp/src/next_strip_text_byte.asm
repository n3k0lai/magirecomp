; Bank 0 at $2BE4. StepMapStripGlyph and the pass at $2B61 call this once
; per glyph. Callers know the address as NextStripTextByte.
;
; The word at wStripText is the strip text pointer. A byte below $F7 returns
; in E with D cleared. $FC swaps that pointer with the saved pointer at
; wUnknownC93D and reads again. $FB scans the saved stream for the next $FC,
; stores the address after that mark, and reads again from wStripText. Any
; other byte at or above $F7 returns in D and E so the caller can stop.
; A $FB scan that walks $FF bytes without $FC jumps to ResetAtStack.
;
; wStripText is the name from run_d0b1_map_strips.asm. wUnknownC93D is the
; name from setup_command_4d.asm. ResetAtStack is the name from read_joypad.asm.

LoadNextStripTextByte::
    ld hl, wStripText
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, [hl+]
    ld d, a
    ld e, a
    ld a, h
    ld [wStripText + 1], a
    ld a, l
    ld [wStripText], a
    ld a, d
    add $09
    jr c, .control

    ld d, $00
    ret

.control:
    ld a, d
    cp $fc
    jr nz, .notSwitch

    ld b, h
    ld c, l
    ld hl, wUnknownC93D
    ld a, [hl+]
    ld [wStripText], a
    ld a, [hl]
    ld [wStripText + 1], a
    ld a, b
    ld [hl-], a
    ld [hl], c
    jr LoadNextStripTextByte

.notSwitch:
    cp $fb
    ret nz

    ld hl, wUnknownC93D
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld e, $ff

.scanForMark:
    dec e
    jp z, ResetAtStack

    ld a, [hl+]
    cp $fc
    jr nz, .scanForMark

    ld a, h
    ld [wUnknownC93D + 1], a
    ld a, l
    ld [wUnknownC93D], a
    jp LoadNextStripTextByte
