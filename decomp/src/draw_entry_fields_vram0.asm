; Bank 0 at $338D. PresentEntryRecordByPanelSlot calls this when
; wPanelSlot ($C9D9) is zero, after $7069 has copied eleven record
; bytes into $C9CD–$C9D7.
;
; The saved ROM bank is restored on the way out. rVBK starts at 0.
; UnpackBytes copies $800 bytes to $9000 from the pointer at $C9CD
; in the bank at $C9CF. ROM bank 4 then runs $6F47. rVBK becomes 1
; and bank 4 runs $6F60.
;
; A is loaded from $C9D2. The `ld a, a` is the byte in the ROM; A is
; still that bank. $33CE stores it to wCurrentROMBank and rROMB0,
; points HL at the map row $99E0, and loads DE from $C9D3. A is
; cleared. $33E0 calls $3635 with that HL, DE, and A, then calls
; $2DAA with BC from $C9D0. A is loaded from $C9D7 (again followed
; by `ld a, a`), that bank is mapped, and $358E is called with BC
; from $C9D5. $3403 pops the saved ROM bank and returns.
;
; $6F47, $6F60, $3635, $2DAA, and $358E are still INCBIN. $2DAA
; unpacks a map source into WRAM bank 6 and copies it to both VRAM
; banks. wCurrentROMBank and rROMB0 are the names from reset.asm.
; rVBK is the name from setup_window.asm. UnpackBytes is the name
; from unpack_bytes.asm. wPanelSlot is the name from
; stage_panel_glyph_dest.asm.

; Little-endian pointer and bank of the packed tiles copied to $9000.
DEF wEntryGfxPtr EQU $C9CD
DEF wEntryGfxBank EQU $C9CF

; Little-endian pointer and bank passed to $2DAA.
DEF wEntryMapPtr EQU $C9D0
DEF wEntryMapBank EQU $C9D2

; Little-endian pointer passed in DE to $3635. The destination is $99E0.
DEF wEntryRowPtr EQU $C9D3

; Little-endian pointer and bank passed to $358E.
DEF wEntryTailPtr EQU $C9D5
DEF wEntryTailBank EQU $C9D7

; Background map row used when the panel slot is zero.
DEF ENTRY_MAP_ROW EQU $99E0

DrawEntryFieldsVRAM0::
    ld a, [wCurrentROMBank]
    push af
    xor a
    ld [rVBK], a
    ld a, [wEntryGfxBank]
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld a, [wEntryGfxPtr + 1]
    ld h, a
    ld a, [wEntryGfxPtr]
    ld l, a
    ld de, $9000
    ld bc, $0800
    call UnpackBytes
    ld a, $04
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call $6F47
    ld a, $01
    ld [rVBK], a
    ld a, $04
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call $6F60
    ld a, [wEntryMapBank]
    ld a, a
; $33CE. A is the ROM bank for the map copy.
.storeMapBank:
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld hl, ENTRY_MAP_ROW
    ld a, [wEntryRowPtr]
    ld e, a
    ld a, [wEntryRowPtr + 1]
    ld d, a
    xor a
; $33E0. A is 0. $3635 reads it with HL and DE.
.placeRow:
    call $3635
    ld a, [wEntryMapPtr + 1]
    ld b, a
    ld a, [wEntryMapPtr]
    ld c, a
    call $2DAA
    ld a, [wEntryTailBank]
    ld a, a
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld a, [wEntryTailPtr + 1]
    ld b, a
    ld a, [wEntryTailPtr]
    ld c, a
    call $358E
; $3403. Restores the ROM bank pushed at the start.
.restoreBank:
    pop af
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ret
