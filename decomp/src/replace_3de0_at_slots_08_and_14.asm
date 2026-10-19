; Bank 7 at $5D32. WriteC9E5WordAtSlots00And0C calls this with
; HL = $C72B and BC still the word from $C9E5.
;
; $C9E2 and $C9E3 are cleared. The word at slot $08 (HL + $10) is compared
; with $3DE0. A match sets $C9E2 and WriteWordAtTwiceEStride8 writes BC
; once at that slot. The word at slot $14 (HL + $28) is compared the same
; way: a match sets $C9E3 and writes BC once at that slot.
;
; $C72B, $C9E2, $C9E3, $C9E5, and $C9E6 are still unnamed.

DEF SENTINEL_WORD_3DE0 EQU $3DE0

Replace3DE0AtSlots08And14::
    push bc
    push hl
    xor a
    ld [$C9E2], a
    ld [$C9E3], a
    ld bc, SENTINEL_WORD_3DE0
    ld de, $0010
    add hl, de
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, h
    cp b
    jr nz, .checkSlot14

    ld a, l
    cp c
    jr nz, .checkSlot14

    pop hl
    pop bc
    push bc
    push hl
    ld e, $08
    ld a, $01
    ld [$C9E2], a
    call WriteWordAtTwiceEStride8

.checkSlot14:
    ld bc, SENTINEL_WORD_3DE0
    pop hl
    push hl
    ld de, $0028
    add hl, de
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, h
    cp b
    jr nz, .done

    ld a, l
    cp c
    jr nz, .done

    pop hl
    pop bc
    ld e, $14
    ld a, $01
    ld [$C9E3], a
    call WriteWordAtTwiceEStride8
    ret

.done:
    pop hl
    pop bc
    ret
