; Bank 2 at $6DE7. FinishLowD103Refresh calls here when $D0B4 is zero
; and $D073 is not. This routine does not write rROMB0.
;
; $D105 at or above $05 returns immediately. Otherwise bits of $D125,
; gated by $D106 and $D0EF, either force $D076 and $D077 or clear a bit
; of $D125. Two of those paths also plant a slot record and a $C71B
; script, then wait until that script's pointer high byte clears.
;
; Bit 1 with bit 0 of $D106 set stores D = $41 and BC = $70B6 for slot
; $D103, then sets $D076 = 1 and $D077 = $FF. Bit 1 with that bit clear
; stores the same record and sets $D076 = 1, with $D077 equal to half of
; $D073, or 1 when that half is zero.
;
; Bit 4 with bit 5 set forces the same $D076 = 1, $D077 = $FF pair and
; returns. Bit 4 alone clears bit 4 and continues.
;
; Bit 0, with bit 1 of $D106 set and bit 0 of $D0EF clear, stores
; D = $41 and BC = $7089 for slot $D103, copies $D112 to $CD8C, points
; $CD8F at $C949, and calls bank 6 at $5A60. $FC is stored at $C953,
; $49 $C9 is planted at $C93D, and $4C $26 $48 $66 $0A is written at
; $C71B. Bank 5 at $5A1A runs, StoreSlotPairs0214 runs for $D103, and
; bit 0 of $D125 is cleared.
;
; Bit 2, with bit 3 of $D106 set, copies $D112 the same way, calls bank
; 6 at $5A60, stores $FC at $CD9B, plants $49 $C9, writes
; $4C $2B $44 $66 $0A at $C71B, runs bank 5 at $5A1A, and clears bit 2
; of $D125. What $4826 and $442B do is still unknown.
;
; Bit 6 clears itself when [$D0D9] masked with [$D110] is nonzero.
;
; StoreIndexedSlotRecord, StoreSlotPairs0214, CallBankedHL,
; CopyIndexedName, and WaitUntilC71DClears are already source.

ApplyD125WhenD105Below5::
    ld a, [$D105]
    cp $05
    jp nc, .d105AtLeast5
    ld a, [$D125]
    and $02
    jr z, .bit1Clear
    ld a, [$D106]
    and $01
    jr z, .halfD073
    ld a, [$D103]
    ld d, $41
    ld bc, $70B6
    call StoreIndexedSlotRecord
    ld a, $01
    ld [$D076], a
    ld a, $FF
    ld [$D077], a
    ret

.halfD073:
    ld a, [$D103]
    ld d, $41
    ld bc, $70B6
    call StoreIndexedSlotRecord
    ld a, $01
    ld [$D076], a
    ld a, [$D073]
    srl a
    jr nz, .storeHalf
    ld a, $01
.storeHalf:
    ld [$D077], a
    ret

.bit1Clear:
    ld a, [$D125]
    and $10
    jr z, .afterBit4
    ld a, [$D125]
    and $20
    jr z, .clearBit4
    ld a, $01
    ld [$D076], a
    ld a, $FF
    ld [$D077], a
    ret

.clearBit4:
    ld a, [$D125]
    xor $10
    ld [$D125], a

.afterBit4:
    ld a, [$D125]
    and $01
    jr z, .afterBit0
    ld a, [$D106]
    and $02
    jr z, .afterBit0
    ld a, [$D0EF]
    and $01
    jr nz, .afterBit0
    ld a, [$D103]
    ld d, $41
    ld bc, $7089
    call StoreIndexedSlotRecord
    ld a, [$D112]
    ld [$CD8C], a
    ld bc, $C949
    ld hl, $CD8F
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, $5A60
    ld e, $06
    call CallBankedHL
    ld a, $FC
    ld [$C953], a
    ld a, $49
    ld [$C93D], a
    ld a, $C9
    ld [$C93E], a
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $26
    ld [hl+], a
    ld a, $48
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
    ld hl, $5A1A
    ld e, $05
    call CallBankedHL
    ld a, [$D103]
    call StoreSlotPairs0214
    ld a, [$D125]
    xor $01
    ld [$D125], a

.afterBit0:
    ld a, [$D125]
    and $04
    jr z, .afterBit2
    ld a, [$D106]
    and $08
    jr z, .afterBit2
    ld a, [$D112]
    ld [$CD8C], a
    ld bc, $C949
    ld hl, $CD8F
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, $5A60
    ld e, $06
    call CallBankedHL
    ld a, $FC
    ld [$CD9B], a
    ld a, $49
    ld [$C93D], a
    ld a, $C9
    ld [$C93E], a
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $2B
    ld [hl+], a
    ld a, $44
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
    ld hl, $5A1A
    ld e, $05
    call CallBankedHL
    ld a, [$D125]
    xor $04
    ld [$D125], a

.afterBit2:
    ld a, [$D125]
    and $40
    jr z, .done
    ld a, [$D110]
    ld b, a
    ld a, [$D0D9]
    and b
    jr z, .done
    ld a, [$D125]
    xor $40
    ld [$D125], a

.done:
    ret

.d105AtLeast5:
    ret
