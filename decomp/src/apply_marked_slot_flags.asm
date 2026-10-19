; Apply bits 0, 3, and 5 of $D0EE to the slot selected by $D0B6.
;
; A nonzero $D0B7 returns at once. The caller uses that byte as "already
; handled": the paths that finish here store 2 there before returning, and
; the walk then continues into the mark step instead of advancing $D017.
;
; Bit 0 stores the $41 $7089 record through StoreIndexedSlotRecord. $D0E1
; minus $0A is written back when the difference is still positive. That
; path calls bank 5 at $5575, writes $C949 to $C93D, stages $4C $42 $48
; $66 $0A at $C71B, calls bank 5 at $5A1A, then StoreSlotPairs0214. A
; difference of 0 or a borrow clears the $D0E0 pair, sets $D0B7, stages
; $4C $60 $48 $66 $0A, and returns.
;
; Bit 3 stores the $41 $6EF5 record. The high nibble of $D0DA is treated
; as $0F when it is 0, then decremented. A nonzero result is swapped back
; into the high nibble and the same bank 5 pair runs with $4C $20 $43
; $66 $0A at $C71B. A zero result divides the $D0E0 pair by 3, negates
; (quotient + 1) into $D0C3, clears the pair, and adds that signed word
; to four big-endian words. The first word is at $D14E plus
; ([$D0D9] * 4 + 1) * $37, and each later word is $37 bytes after the
; previous one. A sum that does not stay positive becomes $0001. $D0B7
; is set and $4C $E7 $42 $66 $0A is staged at $C71B.
;
; Bit 5 stores the $41 $7035 record, calls $6F30 with HL = $D0D9 and
; A = 0, then StoreSlotPairs0214.
;
; StoreIndexedSlotRecord, StoreSlotPairs0214, DivideHLByA, and
; CallBankedHL are already source. $5575, $5A1A, and $6F30 are still
; INCBIN.

ApplyMarkedSlotFlags::
    ld a, [$D0B7]
    and a
    ret nz
    ld a, [$D0EE]
    and $01
    jr z, .bit3
    ld a, [$D0B6]
    ld d, $41
    ld bc, $7089
    call StoreIndexedSlotRecord
    ld a, [$D0E1]
    sub $0A
    jr c, .clearPairBit0
    jr z, .clearPairBit0
    ld [$D0E1], a
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
    ld a, $42
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
    ld a, [$D0B6]
    call StoreSlotPairs0214
    jr .bit3
.clearPairBit0:
    xor a
    ld hl, $D0E0
    ld [hl+], a
    ld [hl+], a
    ld a, $02
    ld [$D0B7], a
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $60
    ld [hl+], a
    ld a, $48
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
    ret
.bit3:
    ld a, [$D0EE]
    and $08
    jp z, .bit5
    ld a, [$D0B6]
    ld d, $41
    ld bc, $6EF5
    call StoreIndexedSlotRecord
    ld a, [$D0DA]
    ld b, a
    and $F0
    swap a
    and a
    jr nz, .decHighNibble
    ld a, $0F
.decHighNibble:
    dec a
    jr z, .scaleFourWords
    swap a
    ld c, a
    ld a, b
    and $0F
    add c
    ld [$D0DA], a
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
    ld a, $20
    ld [hl+], a
    ld a, $43
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
    ld hl, $5A1A
    ld e, $05
    call CallBankedHL
    ld a, [$D0B6]
    call StoreSlotPairs0214
    jr .bit5
.scaleFourWords:
    ld a, [$D0E0]
    ld h, a
    ld a, [$D0E1]
    ld l, a
    push hl
    xor a
    ld hl, $D0E0
    ld [hl+], a
    ld [hl+], a
    pop hl
    ld a, $03
    call DivideHLByA
    inc a
    ld c, a
    ld b, $00
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    ld hl, $D0C3
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, [$D0D9]
    sla a
    sla a
    inc a
    ld hl, $D14E
    ld bc, $0037
.stepRecord:
    add hl, bc
    dec a
    jr nz, .stepRecord
    ld d, $04
.adjustWord:
    ld a, [$D0C4]
    ld b, a
    ld a, [$D0C3]
    ld c, a
    push hl
    ld a, [hl+]
    ld l, [hl]
    ld h, a
    add hl, bc
    jr c, .storeWord
    ld hl, $0001
.storeWord:
    ld b, h
    ld c, l
    pop hl
    ld a, b
    ld [hl+], a
    ld a, c
    ld [hl+], a
    dec d
    jr z, .markScaled
    ld bc, $0035
    add hl, bc
    jr .adjustWord
.markScaled:
    ld a, $02
    ld [$D0B7], a
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $E7
    ld [hl+], a
    ld a, $42
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
    ret
.bit5:
    ld a, [$D0EE]
    and $20
    jr z, .done
    ld a, [$D0B6]
    ld d, $41
    ld bc, $7035
    call StoreIndexedSlotRecord
    ld hl, $D0D9
    xor a
    call $6F30
    ld a, [$D0B6]
    call StoreSlotPairs0214
.done:
    ret
