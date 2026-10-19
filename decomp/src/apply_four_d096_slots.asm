; Bank 2 at $6A01. LoopWhileD0D5 calls here once [$D0D5] is zero.
;
; WRAM bank 7 is stored in wCurrentWRAMBank and selected with rSVBK.
; $D0B1 is set to $84. $D079 points at $D25A. Four bytes at $D096 are
; walked. Each pass increments $D0B1 (so the stored values are $85-$88)
; and, after a pass that is not the last, adds $37 to the pointer at
; $D079. A zero byte skips the copy. A nonzero byte copies the $37-byte
; record at [$D079] into $D0D9 and clears $D0FF.
;
; Bit 6 of $D0EE clears $CCA7 and calls bank 5 at $56AF. AddDividerStep
; and DivideCByB then pick a remainder in L. [$D091+L] is read in bank 7.
; A zero byte retries the pick. A nonzero byte stores L at $D103.
; StoreIndexedSlotRecord runs with A = [$D0B1] (the `res 7, a` is undone
; by `ld a, a`, so bit 7 stays set), D = $41, and BC = $6ECC. Bank 5 at
; $5575 runs. $C93D and $C93E become $49 and $C9. The five bytes $4C $D3
; $41 $66 $0A are written at $C71B, bank 5 at $5A1A runs, and
; StoreSlotPairs0214 runs with that same A.
;
; Bit 6 clear loads the word at $6FD7 plus twice [$D0F0] and calls it
; through JumpHL, then clears $D0FF again. Either path copies $D0D9 back
; over the record at [$D079].
;
; The first `res 7, a` in the loop is overwritten by the following
; `ld a, [hl+]`. The `ret` after the jump back to the loop is unreachable.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; Copy37ByteRecord, CallBankedHL, JumpHL, AddDividerStep, DivideCByB,
; StoreIndexedSlotRecord, and StoreSlotPairs0214 are already source.
; Bank 5's $56AF, $5575, and $5A1A, and the $6FD7 table, are still INCBIN.

ApplyFourD096Slots::
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, $04
    set 7, a
    ld [$D0B1], a
    ld de, $D25A
    ld hl, $D079
    ld a, e
    ld [hl+], a
    ld [hl], d
    ld hl, $D096
    ld b, $04

.slot:
    ld a, [$D0B1]
    inc a
    ld [$D0B1], a
    res 7, a
    ld a, [hl+]
    cp $00
    push hl
    push bc
    jp z, .afterCopy

    ld hl, $D079
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, $D0D9
    call Copy37ByteRecord
    xor a
    ld [$D0FF], a
    ld a, [$D0EE]
    and $40
    jr z, .callIndexed

    xor a
    ld [$CCA7], a
    ld hl, $56AF
    ld e, $05
    call CallBankedHL

.pick:
    call AddDividerStep
    ld c, a
    ld b, $0A
    call DivideCByB
    ld h, $00
    ld bc, $D091
    push hl
    add hl, bc
    ld a, [hl]
    and a
    pop hl
    jr z, .pick

    ld a, l
    ld [$D103], a
    ld a, [$D0B1]
    res 7, a
    ld a, a
    ld d, $41
    ld bc, $6ECC
    call StoreIndexedSlotRecord
    ld hl, $5575
    ld e, $05
    call CallBankedHL
    ld a, $49
    ld [$C93D], a
    ld a, $C9
    ld [$C93E], a
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $D3
    ld [hl+], a
    ld a, $41
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
    ld hl, $5A1A
    ld e, $05
    call CallBankedHL
    ld a, [$D0B1]
    res 7, a
    ld a, a
    call StoreSlotPairs0214
    jr .copyBack

.callIndexed:
    ld a, [$D0F0]
    ld c, a
    ld b, $00
    ld hl, $6FD7
    add hl, bc
    add hl, bc
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call JumpHL
    xor a
    ld [$D0FF], a

.copyBack:
    ld bc, $D0D9
    ld hl, $D079
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call Copy37ByteRecord

.afterCopy:
    pop bc
    dec b
    jr nz, .advancePointer

    pop hl
    ret

.advancePointer:
    ld hl, $D079
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld de, $0037
    add hl, de
    ld a, h
    ld [$D07A], a
    ld a, l
    ld [$D079], a
    pop hl
    jp .slot

    ret
