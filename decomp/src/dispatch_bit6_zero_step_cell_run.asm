; Bank 1 at $526A. The path at $5456 calls this when bit 6 of $c9a3
; is set and the signed vertical step at $C6D3 is zero, after $4C6E
; and before $575E. rROMB0 is left alone, so every call and jump stays
; in this bank. Bit 6 is the up direction on the copy of $c931 written
; by FinishFrame.
;
; $526E, the target that PlantDownIdleScript stores as hScriptPtr, is
; the `and a` below. CountCellRun returns a cell-run count in C. A
; count of zero returns, and the caller continues on to $575E. Any
; other count pops that return address. A count of one jumps to $528C.
; If the byte at $C9A6 is below 3, this jumps to
; CommitScriptAndRecordHead. A count of two jumps to $5299. If $C9A6
; is below 5, this jumps to CommitScriptAndRecordHead. Otherwise it
; jumps to $50D2. $C9A6 has no name. $528C, $5299, and $50D2 are still
; INCBIN.
;
; CountCellRun is the name from count_cell_run.asm.
; CommitScriptAndRecordHead is the name from plant_handler_and_head_word.asm.

DispatchBit6ZeroStepCellRun::
    call CountCellRun
    ld a, c
    and a
    ret z

    pop af
    dec c
    jp z, $528c

    ld a, [$c9a6]
    sub $03
    jp c, CommitScriptAndRecordHead

    dec c
    jp z, $5299

    ld a, [$c9a6]
    sub $05
    jp c, CommitScriptAndRecordHead

    jp $50d2
