; Bank 1 at $5D2E. PlantLeftIntoHead01 stores this address as
; hScriptPtr. rROMB0 is left alone. The bytes just before this address
; are still INCBIN. They are the up-held planter at $5D1B, and this
; address is the $A2 operand of its `ldh [hScriptPtr], a`. Entering
; here therefore runs `and d`, which discards A, then joins that
; planter's tail.
;
; The tail stores $5B at hScriptPtr + 1 and leaves the low byte alone.
; The record-head word at hRecordHead + 1 becomes
; ResumeOtherLeftCellScript ($5D3E). Control then jumps to
; CommitScriptRecord, which copies the script bytes and writes the
; record head.
;
; hScriptPtr is the name from reset.asm. hRecordHead is the name from
; write_record_head.asm. ResumeOtherLeftCellScript is the label in
; resume_other_left_cell_script.asm. CommitScriptAndRecordHead is the
; EQU in plant_handler_and_head_word.asm. PlantLeftIntoHead01 is the
; label in resume_head03_record.asm.

PlantLeftScriptHighAndHead::
    and d
    ld a, $5b
    ldh [hScriptPtr + 1], a
    ld a, LOW(ResumeOtherLeftCellScript)
    ldh [hRecordHead + 1], a
    ld a, HIGH(ResumeOtherLeftCellScript)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead
