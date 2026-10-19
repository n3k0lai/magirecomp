; Store $0F at $C92C and $C92B, then return.
;
; $0659 calls $4307 with A = 7, then falls through. $065E is a second
; entry that skips that call. $4320 is the same callee ApplyC92C uses,
; with A already set to the value just stored at $C92C. $4339 is called
; with A = $0F after $C92B is stored. This routine does not write rROMB0,
; so those three calls run in whatever bank the caller mapped.

Store0FAtC92C::
    ld a, $07
    call $4307
; $065E. A is overwritten below.
.skip_4307:
    ld a, $0F
    ld [$C92C], a
    call $4320
    ld a, $0F
    ld [$C92B], a
    call $4339
    ret
