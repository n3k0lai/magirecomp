; RaiseStoredMeasure. Called from RaiseEntriesBelow100, which compares
; the returned HL with 100.
;
; SRAM is enabled and the bank one past wSRAMBank is mapped. The pointer
; at $D0CF/$D0D0 (low byte first) addresses a record in that bank. The
; byte at offset 2 is compared with $D36D plus one.
;
; When that byte is at most the reference, the gap selects a step:
; under 8 is 20, under 12 is 10, under 18 is 5, under 24 is 2, and any
; wider gap is 1. When the byte is above the reference, the step is 20,
; 10, 5, 2, or 1 for gaps under 3, 5, 7, 12, or wider.
;
; $D384 is added to the step and $D385 is subtracted. A borrow floors
; the result at 1, then it is incremented and stored at $D0D1, so the
; added amount is at least 2. That amount is added to the big-endian
; word at offset 3. The new word is written back, SRAM is disabled, and
; HL returns it.
;
; rRAMG is the name from reset.asm. rRAMB, wSRAMBank, and SRAM_ENABLE
; are the names from handle_start_press.asm.

RaiseStoredMeasure::
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [wSRAMBank]
    add a, $01
    ld [rRAMB], a
    ld bc, $0002
    ld hl, $D0CF
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld a, [hl]
    ld b, a
    ld a, [$D36D]
    inc a
    sub b
    jr c, .aboveReference
    ld b, $14
    cp $08
    jr c, .adjustStep
    ld b, $0A
    cp $0C
    jr c, .adjustStep
    ld b, $05
    cp $12
    jr c, .adjustStep
    ld b, $02
    cp $18
    jr c, .adjustStep
    ld b, $01
    jr .adjustStep

.aboveReference:
    cpl
    inc a
    ld b, $14
    cp $03
    jr c, .adjustStep
    ld b, $0A
    cp $05
    jr c, .adjustStep
    ld b, $05
    cp $07
    jr c, .adjustStep
    ld b, $02
    cp $0C
    jr c, .adjustStep
    ld b, $01

.adjustStep:
    ld a, b
    ld hl, $D384
    add [hl]
    ld hl, $D385
    sub [hl]
    jr nc, .storeAddend
    ld a, $01

.storeAddend:
    inc a
    ld [$D0D1], a
    ld hl, $D0CF
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld bc, $0003
    add hl, bc
    ld a, [hl+]
    ld l, [hl]
    ld h, a
    ld a, [$D0D1]
    ld c, a
    ld b, $00
    add hl, bc
    push hl
    ld b, h
    ld c, l
    ld hl, $D0CF
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld de, $0003
    add hl, de
    ld a, b
    ld [hl+], a
    ld a, c
    ld [hl], a
    xor a
    ld [rRAMG], a
    pop hl
    ret
