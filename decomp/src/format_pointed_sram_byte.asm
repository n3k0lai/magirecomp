; Three little-endian words, then a script step.
;
; A later reader, still INCBIN, loads HL with $2252 and adds [$C6EC]
; times 2. Index 0 is $8A40 and index 1 is $8BD0. Those words are stored
; at $C6E9. Which bank they belong to is still unknown. The word at
; $2250 is outside that lookup. What reads it is still unknown.
;
; FormatPointedSRAMByteThenResume selects SRAM bank wSRAMBank with
; `add a, $00`, which keeps that bank byte and its flags. Nothing reads
; them. SRAM is enabled. The little-endian word at BC is loaded into HL
; and BC advances past it. BC is saved. $2C33, still INCBIN, reads the
; byte at HL, formats it as three ASCII digits at $C949, and returns.
; BC is restored, SRAM is disabled, and control jumps to
; INITIAL_SCRIPT_HANDLER ($0A66).
;
; wSRAMBank, rRAMB, and SRAM_ENABLE are the names from
; handle_start_press.asm. rRAMG and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm.

PointedByteWords::
    INCBIN "roms/magination.gbc", $2250, $6

FormatPointedSRAMByteThenResume::
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [bc]
    ld h, a
    inc bc
    push bc
    call FormatHLByteThreeDigits
    pop bc
    xor a
    ld [rRAMG], a
    jp INITIAL_SCRIPT_HANDLER
