; Bank 0 at $2718. BranchWhenLCDOff calls here with HL = 9. Other
; tails in the following INCBIN call here with HL = 7 or HL = 9.
; BC is already a pointer to a 3-byte record.
;
; BC + HL is stored as hScriptPtr (high byte first, 3-byte form) and
; hScriptHandler becomes INITIAL_SCRIPT_HANDLER ($0A66). Those stores
; are the 3-byte form. The record itself is not skipped by that add:
; the read still starts at the original BC.
;
; wSRAMBank ($C727) is written to rRAMB with `add a, $00` in between,
; which keeps the bank byte and sets flags nobody reads. SRAM is enabled
; for the read and disabled before the return. rRAMG is the name from
; reset.asm. wSRAMBank, rRAMB, and SRAM_ENABLE are the names from
; handle_start_press.asm, which is included later.
;
; The record is a little-endian word, then one byte. DE is that word.
; C is the byte at DE while SRAM is enabled. B is the third record byte.
; HL returns as BC + 3. A is 0.
;
; hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm.

PlantScriptPtrReadSramByte::
    add hl, bc
    ld a, h
    ld [hScriptPtr + 1], a
    ld a, l
    ld [hScriptPtr], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler + 1], a
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld l, c
    ld h, b
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    ld a, [de]
    ld c, a
    ld a, [hl+]
    ld b, a
    xor a
    ld [rRAMG], a
    ret
