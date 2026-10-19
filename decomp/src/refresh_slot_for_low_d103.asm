; Bank 2 at $5CDD. ClearMarksAndWalkSlots calls here after clearing $D01A
; when [$D103] is below $14.
;
; $D078 is cleared. [$D103] of $0A, or $0C and above, jumps to $5CBC.
; $0B skips to the finish call at $4140 and returns.
;
; For 0-9, a zero at $D091 plus the index (index 9 is exempt) reads
; $D0A5 plus that index. Zero takes the finish path. $D01A = 1 returns.
; Any other value clears $D0B5 and calls bank 5 at $44F4.
;
; The $37-byte record at $D147 + index * $37 is saved at $D07B and copied
; to $D110. [$D105] of 4 or 9, or $D01A = 1, then takes the finish path.
;
; Bit 7 of $D125 calls StoreIndexedSlotRecord with D = $41 and BC = $6EE5,
; runs bank 5 at $5575, plants $49 $C9 at $C93D, writes $4C $76 $42 $66 $0A
; at $C71B, runs bank 5 at $5A1A, writes the $02 $14 pairs for this index,
; sets $D0B5, runs bank 5 at $44F4, and copies the slot record to $D110 again.
;
; Bit 5 of $D125 uses BC = $7035, copies [$D112] to $CD8C, points $CD8F at
; $C949, runs bank 6 at $5A60, stores $FC at $C953, plants $49 $C9, writes
; $4C $C5 $47 $66 $0A at $C71B, runs bank 5 at $5A1A, calls $6F30 with
; HL = $D110 and A = 1, writes the pairs, copies $D110 back through $D07B,
; then replaces $D103 with [$D0B6] and loads that slot into $D110.
;
; Finish calls $4140. Unless [$D103] is $0B, $D110 is copied back through
; the pointer at $D07B.
;
; MulCByB, CallBankedHL, StoreIndexedSlotRecord, StoreSlotPairs0214, and
; Copy37ByteRecord are already source. $5CBC, $4140, $6F30, and bank 5's
; $44F4, $5575, and $5A1A are still INCBIN.

RefreshSlotForLowD103::
    xor a
    ld [$D078], a
    ld a, [$D103]
    cp $0A
    jp z, $5CBC
    cp $0B
    jp z, .finish
    cp $0C
    jp nc, $5CBC
    ld c, a
    ld b, $00
    ld hl, $D091
    add hl, bc
    xor a
    cp [hl]
    jr nz, .loadRecord
    ld a, [$D103]
    cp $09
    jr z, .loadRecord
    ld hl, $D0A5
    add hl, bc
    ld a, [hl]
    and a
    jp z, .finish
    ld a, [$D01A]
    cp $01
    ret z
    ld a, $00
    ld [$D0B5], a
    ld hl, $44F4
    ld e, $05
    call CallBankedHL
.loadRecord:
    ld a, [$D103]
    ld c, a
    ld b, $37
    call MulCByB
    ld bc, $D147
    add hl, bc
    ld b, h
    ld c, l
    ld hl, $D07B
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, $D110
    call Copy37ByteRecord
    ld a, [$D105]
    cp $04
    jp z, .finish
    cp $09
    jp z, .finish
    ld a, [$D01A]
    cp $01
    jp z, .finish
    ld a, [$D125]
    and $80
    jr z, .checkBit5
    ld a, [$D103]
    ld d, $41
    ld bc, $6EE5
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
    ld a, $76
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
    ld a, [$D103]
    call StoreSlotPairs0214
    ld a, $01
    ld [$D0B5], a
    ld hl, $44F4
    ld e, $05
    call CallBankedHL
    ld a, [$D103]
    ld c, a
    ld b, $37
    call MulCByB
    ld bc, $D147
    add hl, bc
    ld b, h
    ld c, l
    ld hl, $D07B
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, $D110
    call Copy37ByteRecord
.checkBit5:
    ld a, [$D125]
    and $20
    jp z, .finish
    ld a, [$D103]
    ld d, $41
    ld bc, $7035
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
    ld a, $C5
    ld [hl+], a
    ld a, $47
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
    ld hl, $5A1A
    ld e, $05
    call CallBankedHL
    ld hl, $D110
    ld a, $01
    call $6F30
    ld a, [$D103]
    call StoreSlotPairs0214
    ld hl, $D07B
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld bc, $D110
    call Copy37ByteRecord
    ld a, [$D0B6]
    ld [$D103], a
    ld c, a
    ld b, $37
    call MulCByB
    ld bc, $D147
    add hl, bc
    ld b, h
    ld c, l
    ld hl, $D07B
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, $D110
    call Copy37ByteRecord
.finish:
    call $4140
    ld a, [$D103]
    cp $0B
    ret z
    ld hl, $D07B
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld bc, $D110
    call Copy37ByteRecord
    ret
