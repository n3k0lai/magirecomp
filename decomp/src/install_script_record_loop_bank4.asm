; Reads three script bytes at [BC] into $C9E4, $C9E0, and $C9E1, then
; sets $C9C5 to 1. BC is stored as hScriptPtr. hScriptDest is pointed at
; wScriptRecord ($C706) and hScriptHandler becomes INITIAL_SCRIPT_HANDLER
; ($0A66). CopyScriptBytes writes the seven HRAM script bytes there.
;
; The LCD is turned off, the timer is armed, and WriteQuadRecords runs.
; ROM bank 4 is mapped and $722E in that bank is called. RunScriptRecord
; then runs the record just stored. TurnOnLCDIfOff turns the LCD on when
; wLCDC is still zero.
;
; Control never returns. The tail maps bank 4 again and calls $71A6, then
; $734D, then jumps back to that map. What $C9E0, $C9E1, $C9C5, and the
; three bank 4 calls mean is still unknown. $C9E4 is the index used by
; stage_c9e4_then_call_704b.asm. hScriptPtr, hScriptHandler,
; INITIAL_SCRIPT_HANDLER, wCurrentROMBank, and rROMB0 are the names from
; reset.asm. wScriptRecord and hScriptDest are the names from
; finish_startup.asm. Those two DEFs come later in the scaffold, so the
; stores below use the addresses. Every HRAM store is the 3-byte form.

; ROM bank mapped before each of the three calls in the $4000 window.
DEF SCRIPT_LOOP_BANK EQU $04

InstallScriptRecordLoopBank4::
    ld a, [bc]
    ld [$C9E4], a
    inc bc
    ld a, [bc]
    ld [$C9E0], a
    inc bc
    ld a, [bc]
    ld [$C9E1], a
    inc bc
    ld a, $01
    ld [$C9C5], a
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld a, LOW($C706)
    ld [$FF9F], a
    ld a, HIGH($C706)
    ld [$FFA0], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler + 1], a
    call CopyScriptBytes
    call TurnOffLCD
    call SetTimerModulo
    call WriteQuadRecords
    ld a, SCRIPT_LOOP_BANK
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call $722E
    call RunScriptRecord
    call TurnOnLCDIfOff
.bank4:
    ld a, SCRIPT_LOOP_BANK
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call $71A6
    call $734D
    jr .bank4
