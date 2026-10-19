; Bank 0 at $340B. PresentEntryRecordByPanelSlot calls this when
; wPanelSlot ($C9D9) is nonzero, after $7069 has copied eleven record
; bytes into $C9CD–$C9D7.
;
; The saved ROM bank is restored on the way out. rVBK starts at 1.
; UnpackBytes copies $800 bytes to $9000 from the pointer at $C9CD
; in the bank at $C9CF. ROM bank 4 then runs $6F79. rVBK becomes 0
; and bank 4 runs $6F9E.
;
; A is loaded from $C9D2 and stored to wCurrentROMBank and rROMB0.
; HL is the map at $9C00. DE comes from $C9D3. A is 1. $3635 is
; called with that HL, DE, and A, then $2DC3 is called with BC from
; $C9D0. ROM bank 4 runs $718B. A is loaded from $C9D7, that bank is
; mapped, and $35AD is called with BC from $C9D5. The saved ROM bank
; is popped and restored.
;
; $6F79, $6F9E, $3635, $2DC3, $718B, and $35AD are still INCBIN.
; $2DC3 is the still-included copy of the map unpack at $2DAA.
; wEntryGfxPtr, wEntryGfxBank, wEntryMapPtr, wEntryMapBank,
; wEntryRowPtr, wEntryTailPtr, and wEntryTailBank are the names from
; draw_entry_fields_vram0.asm. wCurrentROMBank and rROMB0 are the
; names from reset.asm. rVBK is the name from setup_window.asm.
; UnpackBytes is the name from unpack_bytes.asm.

; Background map used when the panel slot is nonzero.
DEF ENTRY_MAP_9C00 EQU $9C00

DrawEntryFieldsVRAM1::
    ld a, [wCurrentROMBank]
    push af
    ld a, $01
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
    call $6F79
    xor a
    ld [rVBK], a
    ld a, $04
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call $6F9E
    ld a, [wEntryMapBank]
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld hl, ENTRY_MAP_9C00
    ld a, [wEntryRowPtr]
    ld e, a
    ld a, [wEntryRowPtr + 1]
    ld d, a
    ld a, $01
    call $3635
    ld a, [wEntryMapPtr + 1]
    ld b, a
    ld a, [wEntryMapPtr]
    ld c, a
    call $2DC3
    ld a, $04
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call $718B
    ld a, [wEntryTailBank]
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld a, [wEntryTailPtr + 1]
    ld b, a
    ld a, [wEntryTailPtr]
    ld c, a
    call $35AD
    pop af
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ret
