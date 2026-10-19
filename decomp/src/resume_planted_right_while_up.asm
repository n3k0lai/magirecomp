; Bank 1 at $62AF. PlantRightWhileUpRecord writes this address as the
; record-head word. rROMB0 is left alone.
;
; ReloadRecordRunScriptPointCell runs the script already in the record
; and points HL at the map cell. A then becomes the $c9a3 copy of
; wButtonsHeld that FinishFrame writes. Bit 4 is right and bit 6 is up,
; from the high nibble ReadJoypad stores.
;
; Right clear plants hScriptPtr with $785E (3-byte absolute stores, low
; at $FFA2) and jumps to PlantHandlerAndHead6167. $785E is a script
; address. What it runs is still unknown.
;
; Right held on an even hMainLoopCounter (bit 0 clear) skips the
; vertical store and jumps to $62E4, the apply entry of
; StoreVerticalStepThenRightCell. On an odd count, A is reloaded from
; $c9a3 and bit 6 is tested. That test falls into
; StoreVerticalStepThenRightCell at $62D2, which stores the Y step and
; jumps to CommitScriptRecord.
;
; hScriptPtr is the name from reset.asm. hMainLoopCounter is the name
; from main_loop.asm. wButtonsHeld is the name from read_joypad.asm.
; ReloadRecordRunScriptPointCell is the routine at $5DE1.
; PlantHandlerAndHead6167 is the label in
; plant_handler_and_head_6167.asm. PlantRightWhileUpRecord is the label
; in plant_right_while_up_record.asm. StoreVerticalStepThenRightCell is
; the label in store_vertical_step_then_right_cell.asm. $c9a3 has no
; name.

; Script planted at hScriptPtr when right is no longer held.
DEF ScriptPtr785E EQU $785E

; Apply entry inside StoreVerticalStepThenRightCell. Its .apply label
; is local to that file.
DEF RightWhileUpApply EQU $62E4

ResumePlantedRightWhileUp::
    call ReloadRecordRunScriptPointCell
    ld a, [$c9a3]
    bit 4, a
    jr nz, .rightHeld
    ld a, LOW(ScriptPtr785E)
    ld [hScriptPtr], a
    ld a, HIGH(ScriptPtr785E)
    ld [hScriptPtr + 1], a
    jp PlantHandlerAndHead6167

.rightHeld:
    ldh a, [hMainLoopCounter]
    and $01
    jp z, RightWhileUpApply
    ld a, [$c9a3]
    bit 6, a

ResumePlantedRightWhileUpEnd:
