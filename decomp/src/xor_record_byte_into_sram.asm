; Bank 0 at $26AB. BranchRecordBitsWhenLCDOn lands here when wLCDC is
; nonzero and B AND C is nonzero. PlantScriptPtrReadSramByte left DE as
; the record word, C as the SRAM byte at that word, and B as the
; record's third byte.
;
; SRAM is enabled, B XOR C replaces that SRAM byte, then SRAM is
; disabled. Execution falls into StageBytePastFour at $26B7.
;
; rRAMG is the name from reset.asm. SRAM_ENABLE is the name from
; handle_start_press.asm, which is included later.

XorRecordByteIntoSram::
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, b
    xor c
    ld [de], a
    xor a
    ld [rRAMG], a
