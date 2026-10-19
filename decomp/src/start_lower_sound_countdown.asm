; StepSoundCountdowns calls this at $596A when a slot's action byte is
; neither $FE nor $FF. A is the slot (0-3). C is that action byte and is
; left for $3ED4. ROM bank $30 stays mapped.
;
; ORs mask N from $58A7 into $DFD3 and clears the 24-bit count at
; $DFD4 + N * 3. $3ED4 runs once with A = N and C = the action. Then
; $3F7D and $599D repeat while $599D returns Z.

DEF wArmedCountdownSlot EQU $DFFB

StartLowerSoundCountdown:
    ld [wArmedCountdownSlot], a
    ld hl, CountdownMasks
    ld e, a
    ld d, $00
    add hl, de
    ld a, [wLowerCountdownFlags]
    or [hl]
    ld [wLowerCountdownFlags], a
    ld a, e
    sla e
    add e
    ld e, a
    ld hl, wLowerCountdownValue
    add hl, de
    xor a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ld a, [wArmedCountdownSlot]
    call $3ed4

.pump:
    ld a, [wArmedCountdownSlot]
    call $3f7d
    ld a, [wArmedCountdownSlot]
    call $599d
    jr z, .pump

    ret

StartLowerSoundCountdownEnd:
