; Bank 1 at $56DC. PlantHandlerWhenUpClear writes this address as the
; record-head word when bit 6 of $c9a3 is clear. rROMB0 is left alone.
;
; ReloadRecordRunScriptPointCell runs the saved script and points HL at
; the marked cell. SetC12AAndClearC12B stores $FF at $C12A and $00 at
; $C12B. A is the $c9a3 byte, the copy of wButtonsHeld FinishFrame
; writes. Bit 4 is right and bit 5 is left, from the high nibble
; ReadJoypad stores.
;
; Right jumps to PlantRightRecordHead. Left jumps to PlantLeftRecordHead.
; Otherwise this falls into StageIdleScriptUnlessUpOrDown, which tests
; up (bit 6) and down (bit 7) on the same A.
;
; wButtonsHeld is the name from read_joypad.asm. $c9a3 has no name.

ResumeUpClearRecordHead::
    call ReloadRecordRunScriptPointCell
    call SetC12AAndClearC12B
    ld a, [$c9a3]
    bit 4, a
    jp nz, PlantRightRecordHead
    bit 5, a
    jp nz, PlantLeftRecordHead
