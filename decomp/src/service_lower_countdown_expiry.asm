; StepLowerSoundCountdowns and StartLowerSoundCountdown call this at
; $599D with A = slot 0-3, while that slot's 24-bit count at $DFD4 is
; zero or negative. ROM bank $30 stays mapped. Callers repeat $3F7D
; and this routine while it returns Z.
;
; A still-positive count returns NZ. An expired count calls $3F0E.
; Bit 7 of D and bit 7 of A then pick the exit:
;   D.7 set, A.7 clear: clear this slot's bit in $DFD3 (mask at $58A7)
;     and return. Z is set only when $DFD3 is then zero.
;   D.7 set, A.7 set: if A & $7F is below 2, clear bit 6 of $DFA6.
;     $3FB0's A is stored at $DFAD + N and this returns Z.
;   D.7 clear: the A.7 path does that same store, then both paths
;     copy $DFE4 + N into $DFE0 + N, write D there, and load the upper
;     count at $DFE8 + N * 3 from the BC those calls left (low byte 0).
;     Bit N+4 of $DFD3 is set from the mask at $58AB. $5632 runs with
;     the saved E and the low nibble of $DFF8, then $4F1A runs with the
;     $DFAD byte. C is merged into $DFAC through the mask at $5A75 + N
;     (bit 1 of N swaps C, bit 0 shifts it left twice). Returns Z.
;
; $DFFD is scratch. What $3F0E, $3FB0, $5632, and $4F1A return is unknown.

DEF wExpirySlotByte EQU $DFAD
DEF wExpirySavedE EQU $DFFD
DEF wExpirySlotHigh EQU $DFE4
DEF wExpirySlotHighPrev EQU $DFE0
DEF wExpiryMix EQU $DFF8

ServiceLowerCountdownExpiry:
    ld c, a
    ld e, a
    sla e
    add e
    ld e, a
    ld d, $00
    ld hl, wLowerCountdownValue + 2
    add hl, de
    ld a, [hl-]
    bit 7, a
    jr nz, .expired

    ld b, a
    ld a, [hl-]
    or b
    ld b, a
    ld a, [hl]
    or b
    ret nz

.expired:
    ld b, $00
    push bc
    ld a, c
    call $3f0e
    bit 7, d
    jr z, .arm_upper

    bit 7, a
    jr nz, .store_and_yield

    pop bc
    ld hl, CountdownMasks
    add hl, bc
    ld a, [hl]
    cpl
    ld e, a
    ld a, [wLowerCountdownFlags]
    and e
    ld [wLowerCountdownFlags], a
    rlca
    ret

.store_and_yield:
    and $7f
    cp $02
    jr nc, .yield_call

    ld hl, wCountdownFlags
    res 6, [hl]

.yield_call:
    call $3fb0
    ld hl, wExpirySlotByte
    pop bc
    add hl, bc
    ld [hl], a
    xor a
    ret

.arm_upper:
    bit 7, a
    jr z, .load_upper

    and $7f
    cp $02
    jr nc, .arm_call

    ld hl, wCountdownFlags
    res 6, [hl]

.arm_call:
    call $3fb0
    pop hl
    push hl
    push bc
    ld bc, wExpirySlotByte
    add hl, bc
    ld [hl], a
    pop bc

.load_upper:
    pop hl
    push bc
    ld c, l
    ld b, h
    ld a, e
    ld [wExpirySavedE], a
    ld hl, wExpirySlotHigh
    add hl, bc
    ld a, [hl]
    ld [hl], d
    ld hl, wExpirySlotHighPrev
    add hl, bc
    ld [hl], a
    ld hl, wUpperCountdownValue
    pop de
    push bc
    ld a, c
    sla c
    add c
    ld c, a
    add hl, bc
    xor a
    ld [hl+], a
    ld a, e
    ld [hl+], a
    ld [hl], d
    pop bc
    ld hl, UpperCountdownMasks
    add hl, bc
    ld a, [wLowerCountdownFlags]
    or [hl]
    ld [wLowerCountdownFlags], a
    ld a, [wExpiryMix]
    and $0f
    ld e, a
    ld a, [wExpirySavedE]
    call $5632
    ld e, a
    ld hl, wExpirySlotHigh
    add hl, bc
    ld d, [hl]
    ld hl, wExpirySlotByte
    add hl, bc
    ld a, c
    ld [wExpirySavedE], a
    ld a, [hl]
    call $4f1a
    ld a, [wExpirySavedE]
    ld e, a
    ld d, $00
    ld hl, SoundDataLead
    add hl, de
    ld a, [wUpperCountdownPack]
    and [hl]
    bit 1, e
    jr z, .pack_bit0

    swap c

.pack_bit0:
    bit 0, e
    jr z, .store_pack

    sla c
    sla c

.store_pack:
    or c
    ld [wUpperCountdownPack], a
    xor a
    ret

ServiceLowerCountdownExpiryEnd:
