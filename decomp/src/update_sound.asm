; Sound-driver tick. TimerOverflow calls this as UpdateSound ($4356)
; after mapping ROM bank $30 and WRAM bank 1.
;
; Returns at once unless $DF02 holds $F5, the signature stored when the
; driver is set up. Otherwise clears the three words at $DF1D (channels
; 0-2), runs the same-bank passes at $56CB (only if bit 7 of $DF74 is
; set), $5006, $53DE, $551E, and $43E0 (only if bit 0 of $DF74 is set).
;
; Then walks C from 3 down through 0. The entry jump skips the $DF09 test
; for C = 3, so that test covers channels 0-2 only. Bit 5 of [$DF09 + C]
; is cleared and bit 6 is set, and $5184 is called with HL equal to the
; sum of the words at $DF15, $DF1D, and $DF23, each indexed by C * 2.
; Bit 5 of [$DF0D + C] covers all four values of C: it is cleared, A is
; loaded from [$DFF4 + C], E from [$DF70 + C], and $5632 then $5070 run.
; BC is the channel index again for both calls.
;
; After the walk, bit 0 of $DF04 calls $4524. $57FC always runs. Those
; callees are still INCBIN in this bank.

DEF wSoundSignature EQU $DF02
DEF SOUND_DRIVER_READY EQU $F5

UpdateSoundTick:
    ld a, [wSoundSignature]
    cp SOUND_DRIVER_READY
    ret nz

    ld hl, $DF1D
    xor a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ld a, [$DF74]
    bit 7, a
    call nz, $56cb
    call $5006
    call $53de
    call $551e
    ld a, [$DF74]
    bit 0, a
    call nz, $43e0
    ld bc, $0003
    jr .channel_flags

.next_channel:
    ld hl, $DF09
    add hl, bc
    bit 5, [hl]
    jr z, .channel_flags

    res 5, [hl]
    set 6, [hl]
    push bc
    sla c
    ld d, $00
    ld e, c
    ld hl, $DF15
    add hl, de
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, $DF1D
    add hl, de
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, $DF23
    add hl, de
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    pop bc
    call $5184

.channel_flags:
    ld hl, $DF0D
    add hl, bc
    bit 5, [hl]
    jr z, .advance

    res 5, [hl]
    ld hl, $DFF4
    add hl, bc
    ld a, [hl]
    ld hl, $DF70
    add hl, bc
    ld e, [hl]
    call $5632
    push bc
    call $5070
    pop bc

.advance:
    dec c
    bit 7, c
    jr z, .next_channel

    ld a, [$DF04]
    bit 0, a
    call nz, $4524
    call $57fc
    ret
