; StepSoundCountdowns calls this at $58AF with BC holding the 16-bit
; step from $DFAA. ROM bank $30 stays mapped.
;
; $DFF9 walks slots 0-3. Slot N runs only when bit N+4 of $DFD3 is set
; (masks $10, $20, $40, $80 at $58AB). The 24-bit count at $DFE8 + N * 3
; loses BC. A still-positive result moves on. A negative or zero result
; clears that bit of $DFD3, then picks two bits of $DFAC:
;   bit 1 of N swaps the nibbles
;   bit 0 of N shifts the byte right by 2
; The low two bits select a channel flag at $DF09. When bit 1 of that
; flag is clear, the index is stored at $DF9C and $48DD runs.

DEF wUpperCountdownFlags EQU $DFD3
DEF wUpperCountdownValue EQU $DFE8
DEF wUpperCountdownSlot EQU $DFF9
DEF wUpperCountdownPack EQU $DFAC
DEF wUpperCountdownChannel EQU $DF09
DEF wUpperCountdownIndex EQU $DF9C

StepUpperSoundCountdowns:
    xor a

.slot:
    ld [wUpperCountdownSlot], a
    ld e, a
    ld d, $00
    ld hl, UpperCountdownMasks
    add hl, de
    ld a, [wUpperCountdownFlags]
    and [hl]
    jr z, .skip_slot

    push bc
    ld a, e
    sla e
    add e
    ld e, a
    ld hl, wUpperCountdownValue
    add hl, de
    ld a, [hl]
    sub c
    ld [hl+], a
    ld d, a
    ld a, [hl]
    sbc b
    ld [hl+], a
    ld e, a
    ld a, [hl]
    sbc $00
    ld [hl+], a
    bit 7, a
    jr nz, .expire

    or d
    or e
    jr nz, .restore_step

.expire:
    ld a, [wUpperCountdownSlot]
    ld e, a
    ld d, $00
    ld hl, UpperCountdownMasks
    add hl, de
    ld a, [hl]
    cpl
    ld c, a
    ld a, [wUpperCountdownFlags]
    and c
    ld [wUpperCountdownFlags], a
    ld a, [wUpperCountdownPack]
    bit 1, e
    jr z, .test_low_bit

    swap a

.test_low_bit:
    bit 0, e
    jr z, .mask_index

    srl a
    srl a

.mask_index:
    and $03
    ld c, a
    ld b, $00
    ld hl, wUpperCountdownChannel
    add hl, bc
    bit 1, [hl]
    jr nz, .restore_step

    ld a, c
    ld [wUpperCountdownIndex], a
    call $48dd

.restore_step:
    pop bc

.skip_slot:
    ld a, [wUpperCountdownSlot]
    inc a
    cp $04
    jr nz, .slot

    ret
