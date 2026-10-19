; Bank 2 at $5BEC.
;
; A arrives from the caller. Bit 0 is set and the other bits stay as they
; were, then that byte is stored at $D389. SpendMeasureHundred then runs
; on $D110 once per [$D069]. A count of 0 wraps and runs 256 times. With
; bit 0 of $D389 set, those passes leave the measure word at record+5
; unchanged. SpendMeasureHundred is already source.

SetD389Bit0SpendD069::
    set 0, a
    ld [$D389], a
    ld a, [$D069]
.spend:
    ld hl, $D110
    push af
    call SpendMeasureHundred
    pop af
    dec a
    jr nz, .spend
    ret
