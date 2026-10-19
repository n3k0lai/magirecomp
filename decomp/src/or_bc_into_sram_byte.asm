; Bank 0 at $2689. BranchRecordBitsWhenLCDOn lands here when wLCDC is
; nonzero and B AND C is zero. PlantScriptPtrReadSramByte has just
; returned: DE is the record word, C is the SRAM byte at that word, and
; B is the record's third byte.
;
; SRAM is enabled, B OR C is written over the byte at DE, and SRAM is
; disabled. There is no return. Execution falls into PlantScriptPastRecord
; at $2695.
;
; rRAMG is the name from reset.asm. SRAM_ENABLE is the name from
; handle_start_press.asm, which is included later.

OrBCIntoSramByte::
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, b
    or c
    ld [de], a
    xor a
    ld [rRAMG], a
