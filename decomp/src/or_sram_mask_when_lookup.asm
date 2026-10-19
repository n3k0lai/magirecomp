; Script tail at $2747. BC points at a little-endian SRAM address, a
; mask byte, then the index byte that LookupWordAt1234 consumes.
;
; HL becomes the SRAM address and E the mask. SRAM bank wSRAMBank is
; selected with `add a, $00` (the flags are unused) and enabled. The
; lookup at $1397 reads the next script byte and returns a word in DE.
; A nonzero word ORs the saved mask into the SRAM byte at HL, disables
; SRAM, and jumps to DispatchScriptOpcode ($0A66).
;
; A zero word jumps to $2772, still INCBIN. That tail complements the
; mask, ANDs it into the same SRAM byte, and also jumps to $0A66.
;
; rRAMG is the name from reset.asm. rRAMB, wSRAMBank, and SRAM_ENABLE are
; the names from handle_start_press.asm. LookupWordAt1234 is the name
; from sram_lookup_install_script.asm.

OrSramMaskWhenLookup::
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [bc]
    ld h, a
    inc bc
    ld a, [bc]
    ld e, a
    inc bc
    push hl
    push de
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    call LookupWordAt1234
    ld a, e
    or d
    pop de
    pop hl
    jr z, AndComplementedMaskIntoSram
    ld a, [hl]
    or e
    ld [hl], a
    xor a
    ld [rRAMG], a
    jp DispatchScriptOpcode
