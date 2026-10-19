; Four 24-bit sound countdowns. UpdateSoundTick calls this at $57FC
; after the channel walk.
;
; Returns at once unless bit 7 of $DFA6 is set. Otherwise BC is the
; 16-bit step at $DFAA, and $58AF then $5921 run with that step.
;
; $DFF9 walks slots 0-3. Slot N runs only when bit N of $DFA6 is set
; (masks $01, $02, $04, $08 at $58A7). The 24-bit count at
; $DFBF + N * 3 loses BC. A still-positive result moves on. A negative
; or zero result reads the action byte at $DFBB + N:
;   $FF  clears bit N of $DFA6
;   $FE  calls $3E78 with A = N
;   else calls $596A with C = that byte, then $3E3A with A = N
; The $FE and other paths repeat while that 24-bit count stays
; negative or zero. $DFF9 is scratch for the slot index.

DEF wCountdownFlags EQU $DFA6
DEF wCountdownStep EQU $DFAA
DEF wCountdownAction EQU $DFBB
DEF wCountdownValue EQU $DFBF
DEF wCountdownSlot EQU $DFF9

StepSoundCountdowns:
    ld a, [wCountdownFlags]
    bit 7, a
    ret z

    ld a, [wCountdownStep]
    ld c, a
    ld a, [wCountdownStep + 1]
    ld b, a
    call $58af
    call $5921
    ld hl, wCountdownValue
    xor a

.slot:
    ld [wCountdownSlot], a
    ld de, CountdownMasks
    add e
    ld e, a
    ld a, d
    adc $00
    ld d, a
    ld a, [de]
    ld e, a
    ld a, [wCountdownFlags]
    and e
    jr z, .skip_slot

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
    jr nz, .fire

    or d
    or e
    jr nz, .next_slot

.fire:
    push hl
    push bc
    ld hl, wCountdownAction
    ld a, [wCountdownSlot]
    ld c, a
    ld b, $00
    add hl, bc
    ld a, [hl]
    cp $fe
    jr z, .call_3e78

    cp $ff
    jr z, .disable_slot

    ld c, a
    ld a, [wCountdownSlot]
    call $596a
    ld a, [wCountdownSlot]
    call $3e3a
    jr .after_fire

.call_3e78:
    ld a, [wCountdownSlot]
    call $3e78

.after_fire:
    pop bc
    pop hl
    ld d, h
    ld e, l
    dec de
    ld a, [de]
    bit 7, a
    jr nz, .fire

    and a
    jr nz, .next_slot

    dec de
    ld a, [de]
    and a
    jr nz, .next_slot

    dec de
    ld a, [de]
    and a
    jr nz, .next_slot

    jr .fire

.disable_slot:
    ld a, [wCountdownSlot]
    ld c, a
    ld b, $00
    ld hl, CountdownMasks
    add hl, bc
    ld a, [hl]
    cpl
    ld b, a
    ld a, [wCountdownFlags]
    and b
    ld [wCountdownFlags], a
    jr .pop_and_next

.pop_and_next:
    pop bc
    pop hl
    jr .next_slot

.skip_slot:
    ld de, $0003
    add hl, de

.next_slot:
    ld a, [wCountdownSlot]
    inc a
    cp $04
    jp nz, .slot

    ret
