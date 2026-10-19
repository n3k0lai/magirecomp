; Walk four $D092 flags and update the $37-byte records from $D17E.
;
; Called once each pass of the $D0D5 loop. WRAM bank 7 is stored in
; wCurrentWRAMBank and selected with rSVBK, so the $D000 accesses below
; are in that bank. Both names come from timer_overflow.asm.
;
; $D079 is set to $D17E. B counts four flags at $D092. Every flag, zero
; or not, increments $D0B1. A zero flag only advances the pointer.
;
; A nonzero flag copies that record into $D0D9 through Copy37ByteRecord,
; then tests $D0EE.
;
; Bit 1 stores the $41 $70B6 record through StoreIndexedSlotRecord, calls
; bank 5 at $5575, writes $C949 to $C93D, stages $4C $C1 $4A $66 $0A at
; $C71B, calls bank 5 at $5A1A, then StoreSlotPairs0214 with A = [$D0B1].
;
; Bit 1 clear stores the $41 $6EC2 record. Bit 6 set clears $CCA7, calls
; bank 5 at $56AF, and picks a remainder: AddDividerStep, then DivideCByB
; with B = $0A. L is kept when [$D091+L] is nonzero, and that L is stored
; in $D103. The $41 $6ECC record is stored, the same bank 5 pair runs
; with $4C $D3 $41 $66 $0A at $C71B, and StoreSlotPairs0214 follows.
;
; Bit 6 clear calls $5FDF and StoreSlotPairs0214. A nonzero [$D0D5]
; drops the saved flag pointer and counter and returns without writing
; the record back. Zero falls through to the write-back.
;
; The write-back copies $D0D9 onto the pointer at $D079. The counter is
; popped and decremented. Zero returns. Otherwise the pointer advances
; by $37 and the next $D092 flag is read.
;
; Copy37ByteRecord, StoreIndexedSlotRecord, StoreSlotPairs0214,
; CallBankedHL, AddDividerStep, and DivideCByB are already source.
; $5575, $5A1A, $56AF, and $5FDF are still INCBIN.

WalkFourD092Records::
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld de, $D17E
    ld hl, $D079
    ld a, e
    ld [hl+], a
    ld [hl], d
    ld hl, $D092
    ld b, $04
.flag:
    ld a, [$D0B1]
    inc a
    ld [$D0B1], a
    ld a, [hl+]
    and a
    push hl
    push bc
    jp z, .nextFlag
    ld hl, $D079
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, $D0D9
    call Copy37ByteRecord
    ld a, [$D0EE]
    and $02
    jr z, .bit1Clear
    ld a, [$D0B1]
    ld d, $41
    ld bc, $70B6
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
    ld a, $C1
    ld [hl+], a
    ld a, $4A
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
    ld hl, $5A1A
    ld e, $05
    call CallBankedHL
    ld a, [$D0B1]
    call StoreSlotPairs0214
    jp .writeBack
.bit1Clear:
    ld a, [$D0B1]
    ld d, $41
    ld bc, $6EC2
    call StoreIndexedSlotRecord
    ld a, [$D0EE]
    and $40
    jr z, .bit6Clear
    xor a
    ld [$CCA7], a
    ld hl, $56AF
    ld e, $05
    call CallBankedHL
.pickMark:
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
    jr z, .pickMark
    ld a, l
    ld [$D103], a
    ld a, [$D0B1]
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
    call StoreSlotPairs0214
    jr .writeBack
.bit6Clear:
    call $5FDF
    ld a, [$D0B1]
    call StoreSlotPairs0214
    ld a, [$D0D5]
    and a
    jr z, .writeBack
    pop hl
    pop hl
    ret
.writeBack:
    ld bc, $D0D9
    ld hl, $D079
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call Copy37ByteRecord
.nextFlag:
    pop bc
    dec b
    jr nz, .advance
    pop hl
    ret
.advance:
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
    jp .flag
