; StepSoundCountdowns calls this at $5921 with BC holding the 16-bit
; step from $DFAA. ROM bank $30 stays mapped. It runs after the upper
; countdowns at $58AF.
;
; $DFF9 walks slots 0-3. Slot N runs only when bit N of $DFD3 is set
; (masks $01, $02, $04, $08 at $58A7). The 24-bit count at $DFD4 + N * 3
; loses BC. A still-positive result moves on. A negative or zero result
; calls $599D with A = N. While that returns Z, $3F7D runs with A = N
; and $599D is tried again.

DEF wLowerCountdownFlags EQU $DFD3
DEF wLowerCountdownValue EQU $DFD4
DEF wLowerCountdownSlot EQU $DFF9

StepLowerSoundCountdowns:
    xor a

.slot:
    ld [wLowerCountdownSlot], a
    ld e, a
    ld d, $00
    ld hl, CountdownMasks
    add hl, de
    ld a, [wLowerCountdownFlags]
    and [hl]
    jr z, .skip_slot

    push bc
    ld a, e
    sla e
    add e
    ld e, a
    ld hl, wLowerCountdownValue
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
    ld a, [wLowerCountdownSlot]
    call $599d
    jr nz, .restore_step

    ld a, [wLowerCountdownSlot]
    call $3f7d
    jr .expire

.restore_step:
    pop bc

.skip_slot:
    ld a, [wLowerCountdownSlot]
    inc a
    cp $04
    jr nz, .slot

    ret
