; Bank 4 at $64EB. PlantIndexedPanelCallback maps bank 4 and calls
; here after copying the panel index at $C9D9 into $C9B2. This routine
; reads the index from $C9D9, not from $C9B2.
;
; Index 0 through 6 copies that byte of wPanelBytes ($C9B3-$C9B9) into
; wUnknownC9D8. An index past 6 copies the eighth byte at $C9BA.
; Returns with bank 4 still mapped.
;
; wPanelBytes and wPanelSlot are the names from
; stage_panel_glyph_dest.asm. wUnknownC9D8 is the name from
; indexed_tail_07.asm.

LoadSelectedPanelByte::
    ld a, [wPanelSlot]
    cp $00
    jr nz, .slot1
    ld a, [wPanelBytes + 0]
    ld [wUnknownC9D8], a
    ret

.slot1:
    cp $01
    jr nz, .slot2
    ld a, [wPanelBytes + 1]
    ld [wUnknownC9D8], a
    ret

.slot2:
    cp $02
    jr nz, .slot3
    ld a, [wPanelBytes + 2]
    ld [wUnknownC9D8], a
    ret

.slot3:
    cp $03
    jr nz, .slot4
    ld a, [wPanelBytes + 3]
    ld [wUnknownC9D8], a
    ret

.slot4:
    cp $04
    jr nz, .slot5
    ld a, [wPanelBytes + 4]
    ld [wUnknownC9D8], a
    ret

.slot5:
    cp $05
    jr nz, .slot6
    ld a, [wPanelBytes + 5]
    ld [wUnknownC9D8], a
    ret

.slot6:
    cp $06
    jr nz, .slot7
    ld a, [wPanelBytes + 6]
    ld [wUnknownC9D8], a
    ret

.slot7:
    ld a, [wPanelBytes + 7]
    ld [wUnknownC9D8], a
    ret
