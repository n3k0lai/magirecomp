; Taken when BranchBank1OnScriptByte sees a nonzero script byte.
;
; SRAM bank wSRAMBank is selected with `add a, $00`, then SRAM is enabled.
; FillBytes writes $00 across $0581 bytes at $A123, the byte after the
; ten-byte span at $A118. That span ends at $A6A4, the same address as
; the longer zero fill from $A019. SRAM is disabled and this routine
; returns. Bank 1 stays mapped.
;
; wSRAMBank, rRAMB, and SRAM_ENABLE are defined later in
; handle_start_press.asm, so the addresses are written here. rRAMG is the
; name from reset.asm. FillBytes is the name from fill_bytes.asm.

FillSRAMAfterNonzeroScriptByte::
    ld a, [$c727]
    add $00
    ld [$4000], a
    ld a, $0a
    ld [rRAMG], a
    ld hl, $a123
    ld bc, $0581
    ld e, $00
    call FillBytes
    xor a
    ld [rRAMG], a
    ret
