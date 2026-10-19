; Bank 1 at $522E. RightHeldFromBit4 calls this when the X step at
; wClearedOnRecordLoad ($C6D2) is zero, after DispatchCellRightOnButtonA
; and before $5743. rROMB0 is left alone, so every call and jump stays
; in this bank.
;
; CountCellRun returns a cell-run count in C. A count of zero returns,
; and the caller continues on to $5743. Any other count pops that
; return address. A count of one jumps to $5250. If the byte at $C9A6
; is below 3, this jumps to CommitScriptAndRecordHead. A count of two
; jumps to $525D. If $C9A6 is below 5, this jumps to
; CommitScriptAndRecordHead. Otherwise it jumps to $5028. $C9A6 has no
; name. $5250, $525D, $5743, and $5028 are still INCBIN.
;
; CountCellRun is the name from count_cell_run.asm.
; CommitScriptAndRecordHead is the EQU in plant_handler_and_head_word.asm.
; wClearedOnRecordLoad is the name from load_record_head.asm.
; DispatchCellRightOnButtonA is the name from
; dispatch_cell_right_on_button_a.asm.

DispatchZeroXStepCellRun::
    call CountCellRun
    ld a, c
    and a
    ret z

    pop af
    dec c
    jp z, $5250

    ld a, [$c9a6]
    sub $03
    jp c, CommitScriptAndRecordHead

    dec c
    jp z, $525d

    ld a, [$c9a6]
    sub $05
    jp c, CommitScriptAndRecordHead

    jp $5028
