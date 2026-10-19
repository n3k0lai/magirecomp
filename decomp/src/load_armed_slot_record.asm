; Bank 3 at $417C. Called after the choice block is filled, including from
; the $6110 path once the $CC4D record is armed.
;
; BC is zero. That clears the words at $CCBB and $CCBD. $CCA8 is set to $81.
; [$CCB4] indexes the word table at $4524 in this bank. The word is stored
; at $CCAE/$CCAF, the base CopyIndexedSlot uses. $CD7F and $CD80 are cleared,
; then the slot selected by $CD81 is copied into $CD82 onward.
;
; $CCB8 is copied to $C937 and to rSVBK, so the probe uses that WRAM bank.
; rSVBK is the name from timer_overflow.asm. $CCB6/$CCB7 is a pointer. When
; it is nonzero and the byte at that base plus $CD81 is zero, $CD81 becomes
; [$CD84] and the slot is copied again. A nonzero byte, or a null pointer,
; leaves the loop.
;
; $CCBA must be $02 or the routine returns. Otherwise ReloadSlotPosition
; writes the position bytes from $CD82 and $CD83. $4524 is still INCBIN.

LoadArmedSlotRecord::
    ld bc, $0000
    ld hl, $ccbb
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, $ccbd
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, $81
    ld [$cca8], a
    ld a, [$ccb4]
    ld c, a
    ld b, $00
    ld hl, $4524
    add hl, bc
    add hl, bc
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, h
    ld [$ccaf], a
    ld a, l
    ld [$ccae], a
    xor a
    ld [$cd7f], a
    ld [$cd80], a
    call CopyIndexedSlot

.probe:
    ld a, [$ccb8]
    ld [$c937], a
    ldh [rSVBK], a
    ld hl, $ccb6
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, h
    or l
    jr z, .finish

    ld a, [$cd81]
    ld c, a
    ld b, $00
    add hl, bc
    ld a, [hl]
    cp $00
    jr nz, .finish

    ld a, [$cd84]
    ld [$cd81], a
    call CopyIndexedSlot
    jr .probe

.finish:
    ld a, [$ccba]
    cp $02
    ret nz

    call ReloadSlotPosition
    ret
