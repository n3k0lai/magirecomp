; Unused bytes between the timer vector and the serial vector.
; The CPU does not enter here. Five nops keep the next vector at $0058.

TimerPad::
    nop
    nop
    nop
    nop
    nop
