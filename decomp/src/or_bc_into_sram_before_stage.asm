; Bank 0 at $2674. BranchParkedScriptWhenLCDOn lands here when wLCDC
; is nonzero and B AND C is zero. PlantScriptPtrReadSramByte has just
; returned: DE is the record word, C is the SRAM byte at that word, B
; is the record's third byte, and HL is three bytes past the record.
;
; SRAM is enabled, B OR C is written over the byte at DE, and SRAM is
; disabled. There is no return. Execution falls into StageBytePastThree
; at $2680.
;
; rRAMG is the name from reset.asm. SRAM_ENABLE is the name from
; handle_start_press.asm, which is included later.

OrBCIntoSramBeforeStage::
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, b
    or c
    ld [de], a
    xor a
    ld [rRAMG], a
