; Bank 2 at $6F30. HL is a record base. A selects the edit.
;
; A = 0 (ApplyMarkedSlotFlags, HL = $D0D9): the low nibble of the byte at
; HL+1 is decremented when it is not already 1, and $4C $E2 $47 $66 $0A
; is staged at $C71B. A low nibble of 1 instead toggles bit 5 of the byte
; at HL+$15 and stages $4C $AF $47 $66 $0A.
;
; A nonzero (RefreshSlotForLowD103, HL = $D110, A = 1) skips the nibble
; and takes that bit-5 toggle.
;
; Both paths copy the byte at HL+2 to $CD8C, point $CD8F at $C949, run
; bank 6 at $5A60, store $FC at $C953, plant $49 $C9 at $C93D, and run
; bank 5 at $5A1A.
;
; CallBankedHL and CopyIndexedName are already source. Bank 5's $5A1A is
; still INCBIN.

AdjustLowNibbleOrToggleBit5::
    and a
    jr z, .nibble
    push hl
    ld bc, $0001
    add hl, bc
    push hl
    jr .toggleBit5
.nibble:
    push hl
    ld bc, $0001
    add hl, bc
    push hl
    ld a, [hl]
    ld b, a
    and $0F
    dec a
    jr z, .toggleBit5
    ld c, a
    ld a, b
    and $F0
    add c
    pop hl
    ld [hl], a
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $E2
    ld [hl+], a
    ld a, $47
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
    jr .runName
.toggleBit5:
    pop hl
    ld a, $20
    pop hl
    push hl
    ld bc, $0015
    add hl, bc
    xor [hl]
    ld [hl], a
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $AF
    ld [hl+], a
    ld a, $47
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
.runName:
    pop hl
    ld bc, $0002
    add hl, bc
    ld a, [hl]
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
    ld hl, $5A1A
    ld e, $05
    call CallBankedHL
    ret
