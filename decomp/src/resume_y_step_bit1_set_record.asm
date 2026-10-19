; Bank 1 at $52C5. PlantScriptOnYStepBit1Set stores this address as
; the record-head word when bit 1 of $c9a3 is set. rROMB0 is left alone.
;
; ReloadRecordRunScriptPointCell runs first. A is the $c9a3 byte, the
; copy of wButtonsHeld FinishFrame writes. Bit 7 is down, bit 5 is left,
; and bit 4 is right, from the high nibble ReadJoypad stores. What bit 1
; means is still unknown.
;
; Down clear plants hScriptPtr with $50B5 (3-byte form, low at $FFA2)
; and jumps to PlantDownClearRecordHead. Left while down is held jumps
; to $5313. Right while down is held jumps to $53A5. Both of those are
; still INCBIN. $50B5 is still INCBIN in this bank.
;
; Otherwise this calls bank 5 at $682D through CallBankedHL and falls
; into FinishYStepAfterCameraNudge.
;
; hScriptPtr is the name from reset.asm. wButtonsHeld is the name from
; read_joypad.asm. CallBankedHL is the name from call_hl_in_bank.asm.
; ScriptPtr50B5 is the EQU in resume_y_step_bit1_clear_record.asm.

ResumeYStepBit1SetRecord::
    call ReloadRecordRunScriptPointCell
    ld a, [$c9a3]
    bit 7, a
    jr nz, .downHeld
    ld a, LOW(ScriptPtr50B5)
    ld [hScriptPtr], a
    ld a, HIGH(ScriptPtr50B5)
    ld [hScriptPtr + 1], a
    jp PlantDownClearRecordHead

.downHeld:
    bit 5, a
    jp nz, PlantScriptOnLeftWhileDownBit1
    bit 4, a
    jp nz, PlantScriptOnRightWhileDownBit1
    ld hl, $682d
    ld e, $05
    call CallBankedHL
