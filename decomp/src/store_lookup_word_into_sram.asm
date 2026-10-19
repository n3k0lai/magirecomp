; Script tail at $279E. BC points at a little-endian SRAM address, then
; the index byte that LookupWordAt1234 consumes.
;
; HL is that SRAM address. SRAM bank wSRAMBank is selected with
; `add a, $00` (the flags are unused) and enabled. The lookup at $1397
; returns a word in DE. Both bytes are stored at HL, low byte first.
; SRAM is disabled, and control jumps to DispatchScriptOpcode ($0A66).
;
; rRAMG is the name from reset.asm. rRAMB, wSRAMBank, and SRAM_ENABLE are
; the names from handle_start_press.asm. LookupWordAt1234 is the name
; from sram_lookup_install_script.asm.

StoreLookupWordIntoSram::
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [bc]
    ld h, a
    inc bc
    push hl
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    call LookupWordAt1234
    pop hl
    ld a, e
    ld [hl+], a
    ld [hl], d
    xor a
    ld [rRAMG], a
    jp DispatchScriptOpcode

StoreLookupWordIntoSramEnd:
