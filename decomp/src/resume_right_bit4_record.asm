; Bank 1 at $5CC8. PlantRightRecordAndBank stores this address as the
; record-head word. rROMB0 is left alone.
;
; StepCell82EveryFourthFrame runs, then ReloadRecordRunScriptPointCell.
; A is the copy of wButtonsHeld at $c9a3. Bit 4 is right.
;
; Right clear plants hScriptPtr with $5BEF using the 3-byte form (low
; at $FFA2, high at $FFA3). $5BEF is the low byte of
; `call ReloadRecordRunScriptPointCell` inside ResumeDownBit7Record.
; What the script engine does with that address is still unknown.
; Control then jumps to PlantDownBit7ClearHead.
;
; Right held reads hMainLoopCounter. An even pass (bit 0 clear) skips
; the vertical store and jumps to the shared step at $5D00, inside
; Head01ScriptSkipToStep. An odd pass reloads $c9a3. Bit 6 is up. Up
; stores $FF at the Y step, wClearedOnRecordLoad + 1, and falls into
; Head01ScriptSkipToStep. Up clear jumps to the bit-7 test at $5CF7,
; also inside that routine.
;
; hScriptPtr is the name from reset.asm. hMainLoopCounter is the name
; from main_loop.asm. wButtonsHeld is the name from read_joypad.asm.
; wClearedOnRecordLoad is the name from load_record_head.asm.
; PlantDownBit7ClearHead is the name from
; plant_down_bit7_clear_head.asm. Head01ScriptSkipToStep is the name
; from head01_script_skip_to_step.asm.

; Low byte of the reload call in ResumeDownBit7Record. Already source.
DEF RightBit4ClearScript EQU $5BEF

; Bit 7 test inside Head01ScriptSkipToStep. Already source.
DEF Head01DownTest EQU $5CF7

; Shared step tail inside Head01ScriptSkipToStep. Already source.
DEF Head01SharedStep EQU $5D00

ResumeRightBit4Record::
    call StepCell82EveryFourthFrame
    call ReloadRecordRunScriptPointCell
    ld a, [$c9a3]
    bit 4, a
    jr nz, .rightHeld
    ld a, LOW(RightBit4ClearScript)
    ld [hScriptPtr], a
    ld a, HIGH(RightBit4ClearScript)
    ld [hScriptPtr + 1], a
    jp PlantDownBit7ClearHead

.rightHeld:
    ldh a, [hMainLoopCounter]
    and $01
    jp z, Head01SharedStep
    ld a, [$c9a3]
    bit 6, a
    jr z, Head01DownTest
    ld a, $ff
    ld [wClearedOnRecordLoad + 1], a
