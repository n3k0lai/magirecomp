; Loop while [$D0D5] is nonzero, then run the setup calls and repeat.
;
; Each pass calls $6AED and $65B7. A nonzero [$D0D5] runs that pair again.
; Zero continues with $6A01, $6BBA, and $6BE7, waits until $D3C2 clears,
; then clears marks and walks the ten slots. A nonzero [$D016] leaves for
; $6316. Zero jumps back to the top of the loop.
;
; WaitUntilD3C2Clears and ClearMarksAndWalkSlots are already source.
; $6AED, $65B7, $6A01, $6BBA, $6BE7, and $6316 are still INCBIN.

LoopWhileD0D5::
.again:
    call $6AED
    call $65B7
    ld a, [$D0D5]
    and a
    jr nz, .again
    call $6A01
    call $6BBA
    call $6BE7
    call WaitUntilD3C2Clears
    call ClearMarksAndWalkSlots
    ld a, [$D016]
    cp $00
    jp nz, $6316
    jp .again
