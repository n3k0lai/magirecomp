; Bank 1 at $5B13. ResumeLeftHeldRecord jumps here when bit 5 of
; $c9a3 is clear. ResumeRightHeldRecord jumps here when bit 4 is
; clear. The up record at $5AD6, still INCBIN, jumps here when bit 6
; is clear. Those bits are left, right, and up on the copy of
; wButtonsHeld written by FinishFrame. rROMB0 is left alone.
;
; The little-endian word $5B1E is written at hRecordHead + 1. $5B1E is
; the next routine in this bank and is still INCBIN. It dispatches on
; bits 4, 5, 6, and 7 of $c9a3. What the record uses that word for is
; still unknown.
;
; Control then jumps to CommitScriptRecord at $5D9B. That tail calls
; CopyScriptBytes and WriteRecordHead, then returns.
;
; hRecordHead is the name from write_record_head.asm. wButtonsHeld is
; the name from read_joypad.asm. CommitScriptAndRecordHead is the EQU
; in plant_handler_and_head_word.asm.

; Next routine in this bank. Still INCBIN. Planted in the record head.
DEF HeadWord5B1E EQU $5B1E

PlantDirectionDispatchHead::
    ld a, LOW(HeadWord5B1E)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord5B1E)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead
