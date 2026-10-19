; Bank 3 at $6213. ResolveShortListChoice jumps here when the choice is
; $09 (ShortListChoiceNine). This bank stays mapped. The routine writes
; rRAMB and leaves rROMB0 alone.
;
; SRAM bank [$C727] is enabled and the ten bytes at $A118 are copied to
; $CD6A. A byte of $FF is an empty slot. That copy has already stored the
; $FF and advanced HL, so the empty path steps HL back, writes LIST_KEY
; into the slot, saves $FF at LIST_SAVED_KEY, disables SRAM, stores 1 at
; $CD69, and returns.
;
; A full list disables SRAM and calls RefreshFrameBlankSavedChoiceRows.
; Two strip blocks follow. Both point $C93D at $C949 and store 1 at
; $C6EB. The tile pointer is written at $C6E9 and again at $C941. The
; map cells are $9DA1 and $9DC1. The first tile of each row is stored at
; $C944 and $C946, $8F sits between them at $C945, and the tile just past
; the row is stored at $C947. $C93B points at $48A4, then $48B5. The pass
; count is the row length plus one, via `inc a`: $11 becomes $12, and
; $10 becomes $11. $C939 points at $2B8F. Bank 3 at $4260 runs after
; each block.
;
; $CC89 is the cursor, the same byte as sShortRecordIndex. It starts at
; 0. Each pass reads the copied key, subtracts one, and treats that as a
; record index. Records are CHOICE_RECORD_STRIDE ($25) bytes from
; sChoiceRecord ($A025). SRAM bank [$C727] plus one is enabled and the
; first byte of that record is stored at $CD8C. $CD8F is pointed at
; $CD91. CopyIndexedName in bank 6 copies the ten-byte name there. A
; third strip block then uses that buffer as its text: map cell $9E05,
; tiles $9040, first tile $04, tile past the row $0E, pass count $0A
; plus one.
;
; The wait polls wButtonsPressed with mask $F3 (A, B, and the d-pad).
; Bit 0 (A) writes LIST_KEY over the SRAM byte at $A118 plus the cursor,
; saves the old byte at LIST_SAVED_KEY, disables SRAM, stores 1 at
; $CD69, and returns. Bit 1 (B) leaves through $5EDB, the result-3
; return just before ResolveShortListChoice. Otherwise bits 4 or 7
; (Right or Down) step the cursor backward, wrapping $FF to 9. Left or
; Up step it forward,
; wrapping 10 to 0. Either step paints the selected name again.
;
; LIST_KEY, LIST_SAVED_KEY, LIST_SRAM, LIST_LEN, LIST_SRAM_BANK,
; LIST_SRAM_BANK_REG, LIST_SRAM_ENABLE, and open_list_sram are the names
; from resolve_armed_list_choice.asm. LIST_SRAM_BANK_NEXT is the name
; from resolve_short_list_choice.asm. WIN_RESULT and WIN_RESULT_ONE, and
; plant_window_strip, are the names from service_window_choice.asm.
; wUnknownCD8C, wUnknownCD8F, and wUnknownCD91 are the names from
; indexed_tail_07.asm. sChoiceRecord and CHOICE_RECORD_STRIDE are the
; names from load_paged_sram_choice_pairs.asm, which is included later.
; wButtonsPressed is the name from main_loop.asm. rRAMG is the name from
; reset.asm. RefreshFrameBlankSavedChoiceRows, MulCByB, CopyIndexedName,
; and CallBankedHL are already source.

; Ten copied list bytes. Index $CC89 selects one of them.
DEF LIST_SLOT_KEYS EQU $CD6A
DEF LIST_SLOT_CURSOR EQU $CC89

; wButtonsPressed bits kept while choosing a slot: A, B, and the d-pad.
DEF LIST_SLOT_NAV EQU $F3

; Right or Down. Those bits step the cursor backward.
DEF LIST_SLOT_BACK EQU $90

; Bank passed to CallBankedHL for CopyIndexedName.
DEF NAME_BANK EQU $06

ChooseShortListSlot::
    open_list_sram
    ld hl, LIST_SRAM
    ld bc, LIST_SLOT_KEYS
    ld d, LIST_LEN
.copyKey:
    ld a, [hl+]
    ld [bc], a
    inc bc
    cp $FF
    jp z, .emptySlot
    dec d
    jr nz, .copyKey
    xor a
    ld [rRAMG], a
    call RefreshFrameBlankSavedChoiceRows
    plant_window_strip $8DD0, $9DA1, $DD, $EE, $48A4, $11
    plant_window_strip $8F40, $9DC1, $F4, $04, $48B5, $10
    xor a
    ld [LIST_SLOT_CURSOR], a
.paintName:
    ld a, [LIST_SLOT_CURSOR]
    ld c, a
    ld b, $00
    ld hl, LIST_SLOT_KEYS
    add hl, bc
    ld a, [hl]
    dec a
    ld c, a
    ld b, CHOICE_RECORD_STRIDE
    call MulCByB
    ld bc, sChoiceRecord
    add hl, bc
    ld a, [LIST_SRAM_BANK]
    add LIST_SRAM_BANK_NEXT
    ld [LIST_SRAM_BANK_REG], a
    ld a, LIST_SRAM_ENABLE
    ld [rRAMG], a
    ld a, [hl]
    ld [wUnknownCD8C], a
    xor a
    ld [rRAMG], a
    ld bc, wUnknownCD91
    ld hl, wUnknownCD8F
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, CopyIndexedName
    ld e, NAME_BANK
    call CallBankedHL
    plant_window_strip $9040, $9E05, $04, $0E, wUnknownCD91, $0A
.waitNav:
    ld a, [wButtonsPressed]
    and LIST_SLOT_NAV
    jr z, .waitNav
    bit 0, a
    jr nz, .writeKey
    bit 1, a
    jp nz, $5EDB
    and LIST_SLOT_BACK
    jr z, .cursorForward
    ld hl, LIST_SLOT_CURSOR
    dec [hl]
    ld a, $FF
    cp [hl]
    jp nz, .paintName
    ld [hl], LIST_LEN - 1
    jp .paintName
.cursorForward:
    ld hl, LIST_SLOT_CURSOR
    inc [hl]
    ld a, LIST_LEN
    cp [hl]
    jp nz, .paintName
    ld [hl], $00
    jp .paintName
.writeKey:
    ld a, [LIST_SLOT_CURSOR]
    ld c, a
    ld b, $00
    ld hl, LIST_SRAM
    add hl, bc
    open_list_sram
    ld a, [hl]
    ld [LIST_SAVED_KEY], a
    ld a, [LIST_KEY]
    ld [hl], a
    xor a
    ld [rRAMG], a
    ld a, WIN_RESULT_ONE
    ld [WIN_RESULT], a
    ret
.emptySlot:
    ld a, $FF
    ld [LIST_SAVED_KEY], a
    dec hl
    ld a, [LIST_KEY]
    ld [hl], a
    xor a
    ld [rRAMG], a
    ld a, WIN_RESULT_ONE
    ld [WIN_RESULT], a
    ret
