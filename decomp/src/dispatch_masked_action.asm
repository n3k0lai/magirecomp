; Run one action from the flags in $CCA9, masked by $C932.
;
; $C932 is cleared at startup. Its role is still unknown. The masked byte
; is tested in this order:
;
; Bit 2 jumps to the pointer at $CCB2 (low) and $CCB3 (high). That jump
; does not return here.
; Bit 0 and bit 1 each take an index, $CD88 or $CD89, double it, and call
; the word at $42A9 plus that offset. $42A9 is still INCBIN in this bank.
; JumpHL at $0789 is how the call is made.
; When $CD80 is 1 the rest is skipped. QueueBlinkSprite treats that same
; byte as the steady-sprite flag.
; Bits 4, 5, 6, and 7 each call $4000 in this bank. That routine reads the
; high nibble itself, so the four calls are separate even though the
; address is the same. $4000 is still INCBIN.
; Bit 3 calls the pointer at $CCB0 through JumpHL. Any other mask returns.

DispatchMaskedAction::
    ld a, [$c932]
    ld b, a
    ld a, [$cca9]
    and b
    ld b, a
    bit 2, a
    jr z, .notBit2

    ld a, [$ccb3]
    ld h, a
    ld a, [$ccb2]
    ld l, a
    jp hl

.notBit2
    bit 0, a
    jr z, .notBit0

    ld a, [$cd88]
    add a
    ld e, a
    ld d, $00
    ld hl, $42a9
    add hl, de
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call JumpHL
    jr .done

.notBit0
    bit 1, a
    jr z, .notBit1

    ld a, [$cd89]
    add a
    ld e, a
    ld d, $00
    ld hl, $42a9
    add hl, de
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call JumpHL
    jr .done

.notBit1
    ld b, a
    ld a, [$cd80]
    cp $01
    ret z

    ld a, b
    bit 4, a
    jr z, .notBit4

    call $4000
    jr .done

.notBit4
    bit 5, a
    jr z, .notBit5

    call $4000
    jr .done

.notBit5
    bit 6, a
    jr z, .notBit6

    call $4000
    jr .done

.notBit6
    bit 7, a
    jr z, .notBit7

    call $4000
    jr .done

.notBit7
    bit 3, a
    ret z

    ld hl, $ccb0
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call JumpHL

.done
    ret
