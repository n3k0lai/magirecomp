; Bank 7 entry at $74C2. The caller already holds the minuend in A, the
; subtrahend in C, and the SRAM destination in HL. SRAM is already enabled.
;
; A loses C. A borrow stores zero. The result is written to [HL], SRAM is
; disabled, and the tail returns. Nothing reads the flags from `sub`.
;
; rRAMG is the name from reset.asm.

FloorAMinusCDisableSRAM::
    sub c
    jr nc, .store

    xor a
.store:
    ld [hl], a
    xor a
    ld [rRAMG], a
    ret
