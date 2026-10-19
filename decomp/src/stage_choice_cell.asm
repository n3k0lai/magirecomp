; Bank 3 at $4075. RefreshChoiceCursor calls this when [$CCBA] is
; neither $00 nor $02.
;
; $CCBD/$CCBE is the current BG-map address. Those two bytes are copied to
; $CCBB/$CCBC first. $C6E4/$C6E5/$C6E6 is then set to $40E2 in bank 3, the
; routine that follows this one. That routine is still INCBIN.
;
; $CCA8 is the tile written into the cell. It starts as $82. When $CD80 is
; 1, or $CCB9 is 0, that tile stays. Otherwise the tile becomes $81 and
; $CD7F counts up, wrapping from $1E back to 0. Counts below $0F store tile
; $80 and return, leaving the map address where it was. Counts of $0F and
; above, and the two forced paths, store a new address:
; $9C00 + ($CD83 - $0D) * 32 + $CD82. $CD82 is the column and $CD83 is the
; row, the same pair ReloadSlotPosition scales into sprite coordinates.
; The high byte lands in $CCBE and the low byte in $CCBD.

StageChoiceCell::
    ld hl, $ccbb
    ld bc, $ccbd
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, $e2
    ld [$c6e4], a
    ld a, $40
    ld [$c6e5], a
    ld a, $03
    ld [$c6e6], a
    ld a, $82
    ld [$cca8], a
    ld a, [$cd80]
    cp $01
    jr z, .place

    ld a, [$ccb9]
    cp $00
    jr z, .place

    ld a, $81
    ld [$cca8], a
    ld hl, $cd7f
    ld a, [hl]
    inc a
    cp $1f
    jr nz, .storeCount

    xor a

.storeCount
    ld [hl], a
    cp $0f
    jr nc, .place

    ld a, $80
    ld [$cca8], a
    ret

.place
    ld a, [$cd83]
    sub $0d
    ld l, a
    ld h, $00
    ld a, $05

.shiftRow
    sla l
    rl h
    dec a
    jr nz, .shiftRow

    ld a, [$cd82]
    ld c, a
    ld b, $00
    add hl, bc
    ld bc, $9c00
    add hl, bc
    ld a, h
    ld [$ccbe], a
    ld a, l
    ld [$ccbd], a
    ret
