; Bank 1 at $5B4C. PlantDownRecordAndBank stores this address as
; hScriptPtr (low at $FFA2, high at $FFA3) when bit 7 of $c9a3 is set.
; Bit 7 is down on the copy of wButtonsHeld. rROMB0 is left alone.
;
; The two bytes at $5B4C are nops on this entry. They are also the
; address operand of `ld [rRAMG], a` in the still-INCBIN bytes at
; $5B41, which select the SRAM bank at $C727 and enable SRAM before
; falling through here. What enables SRAM when the script engine
; starts at this pointer is still unknown.
;
; [$A3A3] is copied to $C9A6. $C9A6 has no name. XOR A then the 3-byte
; store to rRAMG disables SRAM. Control joins ResumeDownClearHead.
;
; hScriptPtr is the name from reset.asm. rRAMG is the name from
; reset.asm. wButtonsHeld is the name from read_joypad.asm.

CopySRAMMarkThenResumeDown::
    nop
    nop
    ld a, [$a3a3]
    ld [$c9a6], a
    xor a
    ld [rRAMG], a
    jp ResumeDownClearHead
