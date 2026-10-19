; Pick a slot index from the high nibble of A and copy that slot.
;
; A is the masked action byte. Four shifts leave bits 4-7 in the low nibble.
; $CD84 through $CD87 are four candidate indexes, one per bit. The loop
; keeps the first set bit among bits 4, 5, and 6. If none of those is set
; it uses $CD87, the bit 7 entry.
;
; That index is stored at $CD81. CopyIndexedSlot then fills $CD82 onward
; from the 8-byte record. $CCB8 is copied to $C937 and to rSVBK, so the
; following read uses that WRAM bank. rSVBK is the name from timer_overflow.asm.
;
; $CCB6/$CCB7 is a pointer. When it is nonzero, the byte at that base plus
; the new $CD81 is tested. A zero byte selects the same table entry again.
; A nonzero byte, or a null pointer, continues.
;
; $CCBA must be $02 or the routine returns. Otherwise it calls $405F, which
; reloads the position from $CD82 and $CD83. $405F is still INCBIN.

SelectSlotFromHighNibble::
    srl a
    srl a
    srl a
    srl a
    ld hl, $cd84
    ld c, $03

.scan
    bit 0, a
    jr nz, .useSlot

    inc hl
    srl a
    dec c
    jr nz, .scan

.useSlot
    ld a, [hl]
    ld [$cd81], a
    push hl
    call CopyIndexedSlot
    pop de
    ld a, [$ccb8]
    ld [$c937], a
    ldh [rSVBK], a
    ld hl, $ccb6
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, h
    or l
    jr z, .afterProbe

    ld a, [$cd81]
    ld c, a
    ld b, $00
    add hl, bc
    ld a, [hl]
    cp $00
    jr nz, .afterProbe

    ld h, d
    ld l, e
    jr .useSlot

.afterProbe
    ld a, [$ccba]
    cp $02
    ret nz

    call $405f
    ret

SelectSlotFromHighNibbleEnd:
