; Bank 1 at $4212, the first byte after AdvanceCell82Countdown.
;
; $C6D8 is the enable byte opcode $32 stores as $01 and the startup tail
; clears. Zero returns. hMainLoopCounter is incremented once per main-loop
; pass. When its low two bits are not both set, this returns. Otherwise it
; jumps to AdvanceCell82Countdown, so that countdown runs on every fourth
; pass while the enable byte is nonzero.
;
; hMainLoopCounter is the name from main_loop.asm. AdvanceCell82Countdown
; is the name from advance_cell82_countdown.asm. $C6D8 still has no name.

StepCell82EveryFourthFrame::
    ld a, [$c6d8]
    and a
    ret z
    ldh a, [hMainLoopCounter]
    and $03
    cp $03
    ret nz
    jp AdvanceCell82Countdown
