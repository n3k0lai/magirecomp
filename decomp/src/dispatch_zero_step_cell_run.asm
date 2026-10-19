; Bank 1 at $51B6. FinishYStepAfterCameraNudge calls this when the
; signed vertical step at $C6D3 is zero, after $4B7B and before $570D.
; rROMB0 is left alone, so every call and jump stays in this bank.
;
; $517C, still INCBIN, returns a cell-run count in C. A count of zero
; returns, and the caller continues on to $570D. Any other count pops
; that return address. A count of one jumps to $51D8. If the byte at
; $C9A6 is below 3, this jumps to $5D9B. A count of two jumps to $51E5.
; If $C9A6 is below 5, this jumps to $5D9B. Otherwise it jumps to $4ED4.
; $C9A6 has no name. $517C, $51D8, $51E5, $4ED4, and $5D9B are still INCBIN.

DispatchZeroStepCellRun::
    call $517c
    ld a, c
    and a
    ret z

    pop af
    dec c
    jp z, $51d8

    ld a, [$c9a6]
    sub $03
    jp c, $5d9b

    dec c
    jp z, $51e5

    ld a, [$c9a6]
    sub $05
    jp c, $5d9b

    jp $4ed4
