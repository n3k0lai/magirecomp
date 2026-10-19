; Bank 2 at $4140. RefreshSlotForLowD103 calls here on its finish path.
;
; WRAM bank 7 is stored in wCurrentWRAMBank and selected with rSVBK. Both
; names are from timer_overflow.asm. $D073, $D071, $D070, $D0B2, $D0B4,
; $D076, $D0C5, and $D0D2 are cleared.
;
; The script block below runs only when $D01A is zero, $D0B6 is neither
; zero nor $09, $D0FF is zero, and $D103 is below $0A. $D103 compared with
; $D0B6, and the word at $D100 compared with $517D, pick one of three
; five-byte sequences at $C71B. Bank 5 at $5657 runs, $49 $C9 is planted
; at $C93D, StoreIndexedSlotRecord writes D = $41 and BC = $6EC2 for slot
; $D0B6, bank 5 at $5A1A runs, and StoreSlotPairs0214 runs for that slot.
;
; The word at $D100 is then called through JumpHL with A = [$D073].
; Nonzero $D0FD and $D0FE each copy that id to $CD8C, point $CD8F at
; $CD91, and call bank 7 at $68F8, then call the word it leaves at $CD95.
;
; $D122 masked with $D106 subtracts a quarter of $D073 from itself, with a
; floor of 1, and writes $4C $A8 $42 $66 $0A at $C71B between bank 5 calls
; at $5575 and $5A1A. $D123 masked the same way adds that quarter and
; saturates at $FF, with $4C $C3 $42 $66 $0A. Nonzero $D136 halves $D073
; and increments it. $D076 of 2 clears $D073; any other nonzero value
; copies $D077 over it.
;
; A zero $D0B4 with a nonzero $D073 calls $6DE7. $D070 chooses whether
; that value is added to or subtracted from the word at $D117. The subtract
; path bails to $43BB when that add does not carry or the result is zero,
; and to $4522 when $D0B4 is still zero. The add path keeps the sum while
; it is at or below the word at $D119 and clamps to that word past it.
;
; $43BB copies half of [$D118], plus one, to $D0D2 and clears the word at
; $D117. The word at $D07B equal to $D147 calls $657B; a nonzero return
; forces HL to 0 and joins $4522, and a zero return stores 3 at $D016 and
; joins $452A. Otherwise the same pointer compared with $D336 calls $6FB2,
; with the zero return storing 2 at $D016.
;
; The remaining path sets $D0B2, clears $D091 plus [$D103], and sets $D0A5
; plus that index. Indexes below 5 write $D0C0 = 1, $D0C1 = $0C, and
; $D0C2 = [$D338], call bank 5 at $57BA, and clear the word at $D36E plus
; twice (index minus one) along with $D0D2. Index 5 and above adds $D114
; to $D06C (saturating at $FF). A nonzero $D0D9, or a zero $D0B6, skips
; the clamp of the word at $D14E by the word at $D150 plus $D0D2. [$D112]
; is written into the first mismatch in the eight bytes at $D0B8. A zero
; $D09A calls $6FB2 and returns to the $D016 = 2 path when that returns
; zero. Bank 5 at $5575 runs, $49 $C9 is planted at $C93D, and $D071 is
; set. A zero $D0B4 writes $4C $35 $42 $66 $0A at $C71B; otherwise
; $4C $5A $44 $66 $0A.
;
; $452A tests $D071 and $D073. Both tails, and the plant that follows the
; bank 5 call at $5575, continue in the next INCBIN at $4540. This slice
; stops after `ld a, $49`, the last full instruction inside 1024 bytes.
;
; CallBankedHL, JumpHL, StoreIndexedSlotRecord, and StoreSlotPairs0214 are
; already source. $539D, $53CC, $5420, $657B, $6DE7, $6FB2, bank 5's
; $5657 and $57BA, and bank 7's $68F8 are still INCBIN. Bank 5's $5575
; and $5A1A are already listed.

FinishLowD103Refresh::
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    xor a
    ld [$D073], a
    ld [$D071], a
    ld [$D070], a
    ld [$D0B2], a
    ld [$D0B4], a
    ld [$D076], a
    ld [$D0C5], a
    ld [$D0D2], a
    ld a, [$D01A]
    and a
    jp nz, .afterSlotScript
    ld a, [$D0B6]
    and a
    jp z, .afterSlotScript
    cp $09
    jp z, .afterSlotScript
    ld a, [$D0FF]
    and a
    jp nz, .afterSlotScript
    ld a, [$D103]
    cp $0A
    jp nc, .afterSlotScript
    ld hl, $D0B6
    cp [hl]
    jr z, .sameSlotScript
    ld hl, $D100
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld bc, $517D
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    add hl, bc
    ld a, h
    or l
    jr z, .scriptAt517D
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $32
    ld [hl+], a
    ld a, $4B
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
    jr .runSlotScript

.scriptAt517D:
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $43
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
    jr .runSlotScript

.sameSlotScript:
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $44
    ld [hl+], a
    ld a, $4B
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a

.runSlotScript:
    ld hl, $5657
    ld e, $05
    call CallBankedHL
    ld a, $49
    ld [$C93D], a
    ld a, $C9
    ld [$C93E], a
    ld a, [$D0B6]
    ld d, $41
    ld bc, $6EC2
    call StoreIndexedSlotRecord
    ld hl, $5A1A
    ld e, $05
    call CallBankedHL
    ld a, [$D0B6]
    call StoreSlotPairs0214

.afterSlotScript:
    ld a, [$D107]
    and a
    jr z, .callD100

    ld a, [$D11D]
    ld b, a
    ld a, [$D108]
    ld c, a
    call $5420
    and a
    jr z, .callD100
    ld hl, $D100
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld bc, $517D
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    add hl, bc
    ld a, h
    or l
    jr nz, .d100Not517D

.d100Is517D:
    call $539D
    jr .applyD107

.d100Not517D:
    ld a, [$D105]
    bit 7, a
    jr nz, .d100Is517D
    call $53CC

.applyD107:
    ld b, a
    ld a, [$D107]
    ld c, a
    call MulCByB
    ld a, $FF
    call DivideHLByA
    inc a
    ld [$D073], a

.callD100:
    ld hl, $D100
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, [$D073]
    and a
    call JumpHL
    ld a, [$D0FD]
    and a
    jr z, .checkD0FE
    ld a, [$D0FD]
    ld [$CD8C], a
    ld bc, $CD91
    ld hl, $CD8F
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, $68F8
    ld e, $07
    call CallBankedHL
    ld hl, $CD95
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld e, $07
    call CallBankedHL

.checkD0FE:
    ld a, [$D0FE]
    and a
    jr z, .scaleD073
    ld a, [$D0FE]
    ld [$CD8C], a
    ld bc, $CD91
    ld hl, $CD8F
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, $68F8
    ld e, $07
    call CallBankedHL
    ld hl, $CD95
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld e, $07
    call CallBankedHL

.scaleD073:
    ld a, [$D073]
    and a
    jp z, .applyD076
    ld hl, $D073
    ld a, [$D106]
    ld b, a
    ld a, [$D122]
    and b
    jr z, .addQuarter
    ld a, [hl]
    ld b, a
    srl b
    srl b
    sub b
    jr c, .floorOne
    jr nz, .storeReduced

.floorOne:
    ld a, $01

.storeReduced:
    ld [hl], a
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
    ld a, $A8
    ld [hl+], a
    ld a, $42
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
    ld hl, $5A1A
    ld e, $05
    call CallBankedHL

.addQuarter:
    ld hl, $D073
    ld a, [$D106]
    ld b, a
    ld a, [$D123]
    and b
    jr z, .halveIfD136
    ld a, [hl]
    ld b, a
    srl b
    srl b
    add b
    jr nc, .storeIncreased
    ld a, $FF

.storeIncreased:
    ld [hl], a
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
    ld a, $C3
    ld [hl+], a
    ld a, $42
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
    ld hl, $5A1A
    ld e, $05
    call CallBankedHL

.halveIfD136:
    ld hl, $D073
    ld a, [$D136]
    and a
    jr z, .applyD076
    ld hl, $D073
    srl [hl]
    inc [hl]

.applyD076:
    ld a, [$D076]
    and a
    jr z, .adjustD117
    cp $02
    jr nz, .copyD077
    xor a
    ld [$D073], a
    jr .adjustD117

.copyD077:
    ld a, [$D077]
    ld [$D073], a

.adjustD117:
    ld a, [$D0B4]
    and a
    jr nz, .copyHalfD118
    ld a, [$D073]
    and a
    jp z, .testD071
    call $6DE7
    ld a, [$D0B4]
    and a
    jr nz, .copyHalfD118
    ld a, [$D073]
    and a
    jp z, .testD071
    ld c, a
    ld b, $00
    ld a, [$D117]
    ld h, a
    ld a, [$D118]
    ld l, a
    ld a, [$D070]
    and a
    jr nz, .addD073ToD117
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    add hl, bc
    jr .subBorrowed

.addD073ToD117:
    add hl, bc
    ld a, [$D119]
    ld b, a
    ld a, [$D11A]
    ld c, a
    ld a, c
    sub l
    ld a, b
    sbc h
    jp nc, .storeHLAtD117
    ld h, b
    ld l, c
    jp .storeHLAtD117

.subBorrowed:
    jr nc, .copyHalfD118
    ld a, h
    or l
    jp z, .copyHalfD118
    ld a, [$D0B4]
    and a
    jp z, .storeHLAtD117

.copyHalfD118:
    ld a, [$D118]
    srl a
    inc a
    ld [$D0D2], a
    ld bc, $0000
    ld hl, $D117
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, $D07B
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, $D147
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    add hl, bc
    ld a, h
    or l
    jr nz, .compareD336
    call $657B
    and a
    jr z, .setD016To3
    ld hl, $0000
    jp .storeHLAtD117

.setD016To3:
    ld a, $03
    ld [$D016], a
    jp .testD071

.compareD336:
    ld hl, $D07B
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, $D336
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    add hl, bc
    ld a, h
    or l
    jr nz, .markD0B2
    call $6FB2
    and a
    jr z, .setD016To2
    ld hl, $0000
    jp .storeHLAtD117

.setD016To2:
    ld a, $02
    ld [$D016], a
    jp .testD071

.markD0B2:
    ld a, $01
    ld [$D0B2], a
    ld a, [$D103]
    ld c, a
    ld b, $00
    ld hl, $D091
    add hl, bc
    xor a
    ld [hl], a
    ld hl, $D0A5
    add hl, bc
    ld a, $01
    ld [hl], a
    ld a, [$D103]
    cp $05
    jr nc, .addD114
    dec a
    ld c, a
    ld b, $00
    ld hl, $D376
    add hl, bc
    ld c, [hl]
    ld hl, $D37A
    add hl, bc
    ld a, $01
    ld [hl], a
    ld a, [$D103]
    dec a
    ld c, a
    ld b, $00
    ld hl, $D36E
    add hl, bc
    add hl, bc
    push hl
    ld a, [$D338]
    ld [$D0C2], a
    ld a, $01
    ld [$D0C0], a
    ld a, $0C
    ld [$D0C1], a
    ld hl, $57BA
    ld e, $05
    call CallBankedHL
    pop hl
    xor a
    ld [hl+], a
    ld [hl], a
    ld [$D0D2], a
    jr .run5575

.addD114:
    ld a, [$D114]
    ld hl, $D06C
    add [hl]
    jr nc, .storeD06C
    ld a, $FF

.storeD06C:
    ld [hl], a
    ld a, [$D0D9]
    and a
    jp nz, .scanD0B8
    ld a, [$D0B6]
    and a
    jr z, .scanD0B8
    ld a, [$D0D2]
    ld e, a
    ld d, $00
    ld a, [$D14E]
    ld h, a
    ld a, [$D14F]
    ld l, a
    add hl, de
    ld a, [$D150]
    ld b, a
    ld a, [$D151]
    ld c, a
    ld a, c
    sub l
    ld a, b
    sbc h
    jp nc, .storeD14E
    ld h, b
    ld l, c

.storeD14E:
    ld a, h
    ld [$D14E], a
    ld a, l
    ld [$D14F], a

.scanD0B8:
    ld a, [$D112]
    ld hl, $D0B8
    ld d, $08

.scanNext:
    cp [hl]
    jr nz, .storeScan
    dec d
    jr z, .afterScan
    inc hl
    jr .scanNext

.storeScan:
    ld [hl], a

.afterScan:
    ld hl, $D09A
    ld a, [hl]
    and a
    jr nz, .run5575
    call $6FB2
    and a
    jp z, .setD016To2

.run5575:
    ld hl, $5575
    ld e, $05
    call CallBankedHL
    ld a, $49
    ld [$C93D], a
    ld a, $C9
    ld [$C93E], a
    ld a, [$D0B4]
    and a
    jr z, .script4235
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $5A
    ld [hl+], a
    ld a, $44
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
    jr .setD071

.script4235:
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $35
    ld [hl+], a
    ld a, $42
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a

.setD071:
    ld a, $01
    ld [$D071], a
    jr .testD071

.storeHLAtD117:
    ld a, h
    ld [$D117], a
    ld a, l
    ld [$D118], a

.testD071:
    ld a, [$D071]
    and a
    jr nz, $458C
    ld a, [$D073]
    and a
    jr nz, $455C
    ld hl, $5575
    ld e, $05
    call CallBankedHL
    ld a, $49
