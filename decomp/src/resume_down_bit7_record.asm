; Bank 1 at $5BEB. The planter at $5BC8, still INCBIN, writes this
; address as the record-head word and $5B4C as hScriptPtr, then commits.
; rROMB0 is left alone. $5BFF is the immediate high byte of the store
; below. The past-two bit-6 path at $50D2 also plants $5BFF as
; hScriptPtr. What the script engine does with that address is still
; unknown.
;
; StepCell82EveryFourthFrame runs, then ReloadRecordRunScriptPointCell.
; A is the copy of wButtonsHeld at $c9a3. Bit 7 is down.
;
; Down still held jumps to $5C06, still INCBIN. Down clear plants
; hScriptPtr with $5BCF using the 3-byte form (low at $FFA2, high at
; $FFA3). $5BCF is the $A4 operand inside that same $5BC8 planter.
; Control then jumps to $5B5B, still INCBIN, which installs the initial
; handler and the record head $5B6E before committing.
;
; hScriptPtr is the name from reset.asm. wButtonsHeld is the name from
; read_joypad.asm. StepCell82EveryFourthFrame is the name from
; step_cell82_every_fourth_frame.asm. ReloadRecordRunScriptPointCell is
; the name from reload_record_run_script_point_cell.asm.

; Script planted when down is clear. The $A4 byte inside the $5BC8 planter.
DEF DownClearScript EQU $5BCF

; Installs the handler and record head $5B6E, then commits. Still INCBIN.
DEF PlantHeadAfterDownClear EQU $5B5B

ResumeDownBit7Record::
    call StepCell82EveryFourthFrame
    call ReloadRecordRunScriptPointCell
    ld a, [$c9a3]
    bit 7, a
    jp nz, ResumeDownHeldDirection
    ld a, LOW(DownClearScript)
    ld [hScriptPtr], a
    ld a, HIGH(DownClearScript)
    ld [hScriptPtr + 1], a
    jp PlantHeadAfterDownClear
