; Pointer planted at wUnknownCCB0 by HandleStartPress.
;
; Drops the return address and jumps to LoadBothVRAMBanks. That routine
; does not return here. LoadBothVRAMBanks is already source in this bank.
; wUnknownCCB0 is the name from handle_start_press.asm.

DropStackedWordThenLoadVRAM::
    pop de
    jp LoadBothVRAMBanks
