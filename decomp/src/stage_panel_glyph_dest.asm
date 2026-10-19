; Bank 4's $6542. ApplyC9B3Bytes calls this once for each byte at
; $C9B3-$C9BA, after mapping bank $04. The byte is in wUnknownC9D8 and
; the slot index 0 through 7 is in $C9D9.
;
; The byte is written back to that slot. The slot then picks a glyph
; destination and a VRAM bank for CopyGlyph:
;   0 and 4 -> $9300,  1 and 5 -> $9440
;   2 and 6 -> $9580,  3 and 7 -> $96C0
; Slots 0-3 store VRAM bank 0. Slots 4-7 store VRAM bank 1.
; An index past 6 takes the slot 7 path.
;
; wUnknownC9D8 is the name from indexed_tail_07.asm. wGlyphDest and
; wGlyphVRAMBank are the names from draw_cgb_notice.asm. $C9D9 and
; $C9B3-$C9BA are still unnamed.

; Eight panel bytes. ClearMapScrollBytes fills them with $F0.
DEF wPanelBytes EQU $C9B3

; Which of those eight bytes this call is staging.
DEF wPanelSlot EQU $C9D9

; Four destinations, $0140 bytes apart. Used once in each VRAM bank.
DEF PANEL_DEST_0 EQU $9300
DEF PANEL_DEST_1 EQU $9440
DEF PANEL_DEST_2 EQU $9580
DEF PANEL_DEST_3 EQU $96C0

StagePanelGlyphDest::
    ld a, [wPanelSlot]
    cp $00
    jr nz, .slot1
    ld bc, PANEL_DEST_0
    ld a, [wUnknownC9D8]
    ld [wPanelBytes + 0], a
    xor a
    jr .store

.slot1:
    cp $01
    jr nz, .slot2
    ld bc, PANEL_DEST_1
    ld a, [wUnknownC9D8]
    ld [wPanelBytes + 1], a
    xor a
    jr .store

.slot2:
    cp $02
    jr nz, .slot3
    ld bc, PANEL_DEST_2
    ld a, [wUnknownC9D8]
    ld [wPanelBytes + 2], a
    xor a
    jr .store

.slot3:
    cp $03
    jr nz, .slot4
    ld bc, PANEL_DEST_3
    ld a, [wUnknownC9D8]
    ld [wPanelBytes + 3], a
    xor a
    jr .store

.slot4:
    cp $04
    jr nz, .slot5
    ld bc, PANEL_DEST_0
    ld a, [wUnknownC9D8]
    ld [wPanelBytes + 4], a
    ld a, $01
    jr .store

.slot5:
    cp $05
    jr nz, .slot6
    ld bc, PANEL_DEST_1
    ld a, [wUnknownC9D8]
    ld [wPanelBytes + 5], a
    ld a, $01
    jr .store

.slot6:
    cp $06
    jr nz, .slot7
    ld bc, PANEL_DEST_2
    ld a, [wUnknownC9D8]
    ld [wPanelBytes + 6], a
    ld a, $01
    jr .store

.slot7:
    ld bc, PANEL_DEST_3
    ld a, [wUnknownC9D8]
    ld [wPanelBytes + 7], a
    ld a, $01

.store:
    ld [wGlyphVRAMBank], a
    ld a, b
    ld [wGlyphDest + 1], a
    ld a, c
    ld [wGlyphDest], a
    ret
