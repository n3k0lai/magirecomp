; Walk the sixteen pointer slots at $C154, then return.
;
; FinishFrame calls this with bank 1 mapped. InitPointerList, at $40D3, clears
; these words and leaves $C132 pointing at the free-pointer table at $C134.
; $4062, still INCBIN, pushes a slot address back through that cursor. An
; empty slot has a zero high byte and is skipped.
;
; An occupied word points at a record. Bit 7 of the record's first byte
; retires the slot: bit 6 is cleared, then $4062 returns the slot and clears
; its word. What the two bits mean is still unknown. Otherwise bytes 1 and 2
; are a code pointer, and JumpHL calls it.
;
; $FF97 and $FF98 both start at $FF. After the call, if $FF98 is below $FF97
; this slot's word is swapped with the word at DE. DE is the previous occupied
; slot that was not retired, and afterwards it is this slot. The callback is
; what writes the two HRAM bytes; this routine only compares them.
;
; The walk stops when the slot address reaches $C174. $4000 then runs. That
; routine, still INCBIN, copies $1B bytes from $C1A4 back to the pointer saved
; at $C174 when $C188 is 3.

DEF hSlotThreshold EQU $FF97
DEF hSlotMetric EQU $FF98
DEF POINTER_SLOTS EQU $C154
DEF POINTER_SLOTS_END EQU $C174

WalkPointerSlots::
    ld a, $ff
    ldh [hSlotThreshold], a
    ldh [hSlotMetric], a
    ld de, POINTER_SLOTS
    ld hl, POINTER_SLOTS
.slot:
    inc hl
    ld a, [hl-]
    and a
    jr z, .advance
    push de
    push hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld b, h
    ld c, l
    ld a, [hl+]
    bit 7, a
    jr nz, .retire
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call JumpHL
    pop hl
    pop de
    ldh a, [hSlotThreshold]
    ld b, a
    ldh a, [hSlotMetric]
    sub b
    jr nc, .keep
    ld a, [de]
    inc de
    ld c, a
    ld a, [de]
    dec de
    ld b, a
    ld a, [hl+]
    ld [de], a
    inc de
    ld a, [hl-]
    ld [de], a
    ld a, c
    ld [hl+], a
    ld a, b
    ld [hl-], a
    jr .keep
.retire:
    res 6, a
    dec hl
    ld [hl], a
    pop hl
    pop de
    call $4062
    jr .advance
.keep:
    ld d, h
    ld e, l
.advance:
    inc hl
    inc hl
    ld a, LOW(POINTER_SLOTS_END)
    cp l
    jr nz, .slot
    call $4000
    ret
