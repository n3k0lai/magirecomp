; Clear $D017, $D075, and the ten bytes at $D0A5, then walk $D017 from 0 to 9.
;
; Each pass clears $D0B7 and picks a record pointer into the word at $D079.
; Index 0 uses $D147 and stores 0 at $D0B6. Index 1 uses $D336 and stores 9.
; A later index reads [$D006 + index]. $FF, or a zero byte at $D091 plus
; that value, skips to the index step. Otherwise $D0B6 keeps the value and
; the pointer is $D147 plus that value times $37.
;
; $5BDC, still INCBIN, is called with that pointer and with $D0D9. Bit 2 of
; $D0EE can take the bank 5 $5575 path and skip the $D0E0 compare. The
; compare treats $D0E0/$D0E1 as a high byte then a low byte. $D017 below 2
; stores 0 at $D0B1; a higher index stores 1, and may store $FF at $D0FF
; when [$D105] with bit 7 clear is at least 5. Bank 5's $56AF then runs.
; [$D0CE] below $0A is written back to $D103. Otherwise a zero at $D0D9
; scans $D096 for a nonzero byte and stores its distance from $D091, and a
; nonzero byte calls $72FD.
;
; [$D103] below $14 clears $D01A and calls $5CDD. A higher value sets $D01A
; and, unless $D0B6 is 0 or 9, calls bank 5's $5657. Both paths can reach
; bank 5's $407C. A nonzero $D0C5 folds ($D0C6 * [$D073]) >> 5 into the
; $D0E0 pair, clamped by the high/low pair at $D0E2.
;
; After another $5BDC, index 0 or 1 skips $6C7D. A zero $D0B7 advances the
; index. $D0B6 of 0 calls $657B and may return with $D016 = 3. $D0B6 of 9
; calls $6FB2 and may return with $D016 = 2. Any other value clears the
; byte at $D091 + $D0B6, sets the byte at $D0A5 + $D0B6, and for $D0B6
; below 5 updates $D37A and clears one word at $D36E. It then waits in
; FinishFrame until $C722 is nonzero.
;
; The index step reads the little-endian word at $D06D. Zero, or a low byte
; of 1, skips $62C1. A nonzero $D016 returns. Otherwise $D017 increments.
; A value of 9 or less runs the walk again. Past that, bank 5's $5A45 runs
; and the word at $D06D increments.
;
; MulCByB, MaskDivByC, MulLByBShift5, CallBankedHL, and FinishFrame are
; already source. $5BDC, $53FB, $38F0, $38C7, $72FD, $5CDD, $6C7D, $657B,
; $6FB2, and $62C1 are still INCBIN.

ClearMarksAndWalkSlots::
    xor a
    ld [$D017], a
    ld [$D075], a
    ld hl, $D0A5
    ld d, $0A
.clearMarks:
    ld [hl+], a
    dec d
    jr nz, .clearMarks
.walk:
    xor a
    ld [$D0B7], a
    ld a, [$D017]
    cp $02
    jr nc, .indexFromTable
    and a
    jr nz, .indexOne
    xor a
    ld [$D0B6], a
    ld bc, $D147
    jr .storePointer
.indexOne:
    ld a, $09
    ld [$D0B6], a
    ld bc, $D336
    jr .storePointer
.indexFromTable:
    ld hl, $D006
    ld c, a
    add l
    ld l, a
    ld c, [hl]
    ld a, $FF
    cp c
    jp z, .advanceIndex
    ld b, $00
    ld hl, $D091
    add hl, bc
    ld a, [hl]
    and a
    jp z, .advanceIndex
    ld a, c
    ld [$D0B6], a
    ld b, $37
    call MulCByB
    ld bc, $D147
    add hl, bc
    ld b, h
    ld c, l
.storePointer:
    ld hl, $D079
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, $D0D9
    call $5BDC
    ld a, [$D0EE]
    and $04
    jr z, .comparePair
    ld a, [$D0E9]
    ld b, a
    ld a, $12
    call $53FB
    ld b, a
    ld c, $20
    call MaskDivByC
    add b
    ld b, a
    ld a, [$D0E6]
    cpl
    add b
    jr nc, .comparePair
    ld a, [$D0B6]
    ld d, $41
    ld bc, $6FF7
    call $38F0
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
    ld a, $1C
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
    ld a, [$D0B6]
    call $38C7
    jp .afterRecord
.comparePair:
    ld b, $00
    ld a, [$D102]
    ld c, a
    ld a, [$D0E0]
    ld h, a
    ld a, [$D0E1]
    ld l, a
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    add hl, bc
    jr nc, .pairFit
    ld a, h
    or l
    jr nz, .storeComparedPair
.pairFit:
    ld a, b
    or c
    jr z, .storeComparedPair
    ld a, [$D017]
    cp $02
    jr nc, .markHigherIndex
    ld a, $00
    ld [$D0B1], a
    jr .callBank5_56AF
.markHigherIndex:
    ld a, $01
    ld [$D0B1], a
    ld a, [$D105]
    res 7, a
    cp $05
    jr c, .callBank5_56AF
    ld a, $FF
    ld [$D0FF], a
.callBank5_56AF:
    xor a
    ld [$CCA7], a
    ld a, [$D103]
    ld [$D0CE], a
    ld hl, $56AF
    ld e, $05
    call CallBankedHL
    ld a, [$D0CE]
    cp $0A
    jr c, .storeD103
    ld a, [$D0D9]
    and a
    jr z, .scanD096
    call $72FD
    jr .copyBack
.scanD096:
    ld hl, $D096
.skipZero:
    ld a, [hl+]
    and a
    jr z, .skipZero
    dec hl
    ld bc, $D091
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    add hl, bc
    ld a, l
.storeD103:
    ld [$D103], a
    jr .copyBack
.storeComparedPair:
    ld a, h
    ld [$D0E0], a
    ld a, l
    ld [$D0E1], a
.copyBack:
    ld hl, $D079
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld bc, $D0D9
    call $5BDC
    ld a, [$D103]
    cp $14
    jr nc, .highD103
    xor a
    ld [$D01A], a
    call $5CDD
    jr .applyC5
.highD103:
    xor a
    ld [$D019], a
    ld a, $01
    ld [$D01A], a
    ld a, [$D0B6]
    and a
    jr z, .callBank5_407C
    cp $09
    jr z, .callBank5_407C
    ld hl, $5657
    ld e, $05
    call CallBankedHL
    ld a, $49
    ld [$C93D], a
    ld a, $C9
    ld [$C93E], a
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $1A
    ld [hl+], a
    ld a, $4B
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
    ld a, [$D0B6]
    ld d, $41
    ld bc, $6EC2
    call $38F0
    ld hl, $5A1A
    ld e, $05
    call CallBankedHL
    ld a, [$D0B6]
    call $38C7
.callBank5_407C:
    ld hl, $407C
    ld e, $05
    call CallBankedHL
.applyC5:
    ld hl, $D079
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, $D0D9
    call $5BDC
    ld a, [$D0C5]
    and a
    jr z, .afterRecord
    ld a, [$D0C6]
    ld l, a
    ld a, [$D073]
    ld b, a
    call MulLByBShift5
    ld c, a
    ld b, $00
    ld a, [$D0E0]
    ld h, a
    ld a, [$D0E1]
    ld l, a
    add hl, bc
    push hl
    ld a, [$D0E2]
    ld b, a
    ld a, [$D0E3]
    ld c, a
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    add hl, bc
    pop hl
    jr nc, .storeShiftedPair
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    ld h, b
    ld l, c
.storeShiftedPair:
    ld a, h
    ld [$D0E0], a
    ld a, l
    ld [$D0E1], a
.afterRecord:
    ld a, [$D017]
    cp $00
    jr z, .reloadPointer
    cp $01
    jr z, .reloadPointer
    call $6C7D
.reloadPointer:
    ld hl, $D079
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld bc, $D0D9
    call $5BDC
    ld a, [$D0B7]
    and a
    jp z, .advanceIndex
    ld a, [$D0B6]
    and a
    jr nz, .notMarkZero
    call $657B
    and a
    jp nz, .advanceIndex
    ld a, $03
    ld [$D016], a
    ret
.notMarkZero:
    cp $09
    jr nz, .clearSelectedMark
    call $6FB2
    and a
    jp nz, .advanceIndex
    ld a, $02
    ld [$D016], a
    ret
.clearSelectedMark:
    ld a, [$D0B6]
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
    ld a, [$D0B6]
    cp $05
    jr nc, .callBank5_5575
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
    ld a, [$D0B6]
    dec a
    add a
    ld c, a
    ld b, $00
    ld hl, $D36E
    add hl, bc
    xor a
    ld [hl+], a
    ld [hl], a
.callBank5_5575:
    ld hl, $5575
    ld e, $05
    call CallBankedHL
    ld a, $49
    ld [$C93D], a
    ld a, $C9
    ld [$C93E], a
    ld a, [$D0B7]
    cp $01
    jr nz, .callBank5_5A1A
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $4B
    ld [hl+], a
    ld a, $43
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
.callBank5_5A1A:
    ld hl, $5A1A
    ld e, $05
    call CallBankedHL
    ld a, [$D0B6]
    call $38C7
    xor a
    ld [$C722], a
    ld a, [$D0B6]
    ld d, $41
    ld bc, $6F5E
    call $38F0
    ld a, [$D0B6]
    dec a
    ld b, a
    ld a, $F0
    ld [$C9D8], a
    ld a, b
    ld [$C9D9], a
    ld hl, $61EB
    ld e, $04
    call CallBankedHL
.waitC722:
    call FinishFrame
    ld a, [$C722]
    and a
    jr z, .waitC722
.advanceIndex:
    ld hl, $D06D
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, h
    or l
    jr z, .checkD016
    ld a, $01
    cp l
    jr z, .checkD016
    call $62C1
.checkD016:
    ld a, [$D016]
    and a
    ret nz
    ld hl, $D017
    inc [hl]
    ld a, $09
    cp [hl]
    jp nc, .walk
    ld hl, $5A45
    ld e, $05
    call CallBankedHL
    ld hl, $D06D
    ld a, [hl+]
    ld d, [hl]
    ld e, a
    inc de
    ld a, d
    ld [hl-], a
    ld [hl], e
    ret
