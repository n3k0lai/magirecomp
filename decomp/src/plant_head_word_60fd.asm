; Bank 1 at $60F2. ResumePlantedDownRecord jumps here when bit 7 of
; $c9a3 is clear. Bit 7 is down on the copy of wButtonsHeld. The same
; tail is also reached from still-INCBIN resumes in this hole when
; their direction bit is clear. rROMB0 is left alone.
;
; The little-endian word $60FD is written at hRecordHead + 1. $60FD is
; the next code in this hole and is still INCBIN. What the record uses
; that word for is still unknown. This routine does not store
; hRecordHead, hScriptHandler, or hScriptBank.
;
; Control then jumps to CommitScriptRecord at $5D9B. That tail calls
; CopyScriptBytes and WriteRecordHead, then returns.
;
; hRecordHead is the name from write_record_head.asm.
; CommitScriptAndRecordHead is the EQU in plant_handler_and_head_word.asm.
; wButtonsHeld is the name from read_joypad.asm. ResumePlantedDownRecord
; is the label in resume_planted_down_record.asm.

; Next code in this hole. Still INCBIN. Planted in the record head.
DEF HeadWord60FD EQU $60FD

PlantHeadWord60FD::
    ld a, LOW(HeadWord60FD)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord60FD)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead

PlantHeadWord60FDEnd:
