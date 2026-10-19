; Bank 5 at $5A1A. Callers write a five-byte script record at $C71B
; (bank, pointer, handler) and then call here. $C71D is the high byte of
; that pointer. FinishFrame, at $08BB, loads the record, runs it, and
; stores it back. This spins until the stored high byte is zero.
;
; FinishFrame is the name from finish_frame.asm.

WaitUntilC71DClears::
    call FinishFrame
    ld a, [$C71D]
    and a
    jr nz, WaitUntilC71DClears
    ret
