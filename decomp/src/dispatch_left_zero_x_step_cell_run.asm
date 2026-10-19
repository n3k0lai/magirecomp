; Bank 1 at $51F2. ResumeLeftWhileDownBit1Record calls this when the
; X step at wClearedOnRecordLoad ($C6D2) is zero, after
; DispatchCellLeftOnButtonA and before $5728. rROMB0 is left alone, so
; every call and jump stays in this bank.
;
; CountCellRun returns a cell-run count in C. A count of zero returns,
; and the caller continues on to $5728. Any other count pops that
; return address. A count of one jumps to $5214. If the byte at $C9A6
; is below 3, this jumps to CommitScriptAndRecordHead. A count of two
; jumps to $5221. If $C9A6 is below 5, this jumps to
; CommitScriptAndRecordHead. Otherwise it jumps to PlantScriptForHead01
; at $4F7E. $C9A6 has no name. $5214, $5221, and $5728 are still INCBIN.
;
; CountCellRun is the name from count_cell_run.asm.
; CommitScriptAndRecordHead is the EQU in plant_handler_and_head_word.asm.
; PlantScriptForHead01 is the name from resume_head03_record.asm.
; wClearedOnRecordLoad is the name from load_record_head.asm.
; DispatchCellLeftOnButtonA is the name from
; dispatch_cell_left_on_button_a.asm. ResumeLeftWhileDownBit1Record is
; the name from resume_left_while_down_bit1_record.asm.

DispatchLeftZeroXStepCellRun::
    call CountCellRun
    ld a, c
    and a
    ret z

    pop af
    dec c
    jp z, $5214

    ld a, [$c9a6]
    sub $03
    jp c, CommitScriptAndRecordHead

    dec c
    jp z, $5221

    ld a, [$c9a6]
    sub $05
    jp c, CommitScriptAndRecordHead

    jp PlantScriptForHead01
