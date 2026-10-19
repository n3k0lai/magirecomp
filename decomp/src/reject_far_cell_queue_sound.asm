; Bank 1 at $4D33. The four two-cell walks that follow this in the
; hole jump here when the far cell is not $81. Each walk has pushed
; the near-cell pointer.
;
; $0B is queued in $C921. That address is wSoundSlotA, defined in
; select_sound_command.asm. pop af drops the near-cell pointer so the
; later ret in CommitScriptRecord returns to the walk's caller.
; CommitScriptRecord copies the HRAM script bytes and the record head.

RejectFarCellQueueSound::
    ld a, $0b
    ld [$c921], a
    pop af
    jp CommitScriptRecord
