; Bank 5 at $5A45. ClearMarksAndWalkSlots calls this through CallBankedHL
; once $D017 passes 9, then increments the word at $D06D.
;
; HL walks the eight countdown bytes at $D07E. $D074 counts from 8 down
; to 1, so the slot index is 9 minus $D074 (1 through 8). A zero byte is
; left alone. A byte above 1 is decremented and skipped. A byte of 1 is
; decremented to 0 and the slot runs:
;
; StoreSlotPairs0214 gets that index. [$D338] is copied to $D0C2, with
; $D0C0 = 0 and $D0C1 = $0C, and ApplyIndexedIdRecord runs. The byte at
; $D149 plus the index times $37 (offset 2 of the $37-byte record that
; starts at $D147) is stored at $D112 and at $C9D8. The index minus one
; is stored at $C9D9. CountdownPanelCallbacks in bank 4 then runs.
;
; The index is stored at $D103. MarkD075BitAndD091 ORs its bit into
; $D075 and stores 1 at $D091 plus that index. $D384 is incremented.
; WriteIndexedNamesAndCount runs, and $49 $C9 is planted at $C93D.
; A nonzero [$D09A] plants $4C $F5 $4A $66 $0A at $C71B. Zero plants
; $4C $0A $4B $66 $0A. WaitUntilC71DClears runs, and the walk continues.
;
; After the eight bytes, each set bit of [$D075] stores 1 at the matching
; byte from $D092. A clear bit is left unchanged. The walk stops when the
; remaining bits are zero or eight bits have been visited.
;
; Then ten bytes at $D0A5 are paired with $D091. A nonzero mark clears
; the paired byte. A zero mark leaves it. The tenth `dec d` returns.
;
; StoreSlotPairs0214, ApplyIndexedIdRecord, MulCByB, CallBankedHL,
; CountdownPanelCallbacks, MarkD075BitAndD091, WriteIndexedNamesAndCount,
; and WaitUntilC71DClears are already source.

ExpireD07ECountdowns::
    ld hl, $D07E
    ld a, $08
    ld [$D074], a
.slot:
    ld a, [hl]
    and a
    jp z, .advance
    dec a
    ld [hl], a
    and a
    jp nz, .advance
    push hl
    ld a, [$D074]
    ld b, a
    ld a, $09
    sub b
    push af
    call StoreSlotPairs0214
    ld a, [$D338]
    ld [$D0C2], a
    ld a, $00
    ld [$D0C0], a
    ld a, $0C
    ld [$D0C1], a
    ld hl, ApplyIndexedIdRecord
    ld e, $05
    call CallBankedHL
    pop af
    push af
    ld b, a
    ld c, $37
    call MulCByB
    ld bc, $D149
    add hl, bc
    ld d, [hl]
    ld a, d
    ld [$D112], a
    pop bc
    push bc
    dec b
    ld a, d
    ld [$C9D8], a
    ld a, b
    ld [$C9D9], a
    ld hl, CountdownPanelCallbacks
    ld e, $04
    call CallBankedHL
    pop af
    ld [$D103], a
    call MarkD075BitAndD091
    ld hl, $D384
    inc [hl]
    ld hl, WriteIndexedNamesAndCount
    ld e, $05
    call CallBankedHL
    ld a, $49
    ld [$C93D], a
    ld a, $C9
    ld [$C93E], a
    ld a, [$D09A]
    and a
    jr z, .plantZeroD09A
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $F5
    ld [hl+], a
    ld a, $4A
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
    jr .waitScript
.plantZeroD09A:
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
    ld a, $4B
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
.waitScript:
    ld hl, WaitUntilC71DClears
    ld e, $05
    call CallBankedHL
    pop hl
.advance:
    inc hl
    ld a, [$D074]
    dec a
    ld [$D074], a
    jp nz, .slot
    ld a, [$D075]
    ld b, $08
    ld c, $01
    ld hl, $D092
.bit:
    bit 0, a
    jr z, .shiftBit
    ld [hl], c
.shiftBit:
    srl a
    jr z, .clearMarked
    dec b
    jr z, .clearMarked
    inc hl
    jr .bit
.clearMarked:
    ld hl, $D0A5
    ld bc, $D091
    ld d, $0A
.mark:
    ld a, [hl+]
    and a
    jr z, .nextMark
    xor a
    ld [bc], a
.nextMark:
    dec d
    ret z
    inc bc
    jr .mark
