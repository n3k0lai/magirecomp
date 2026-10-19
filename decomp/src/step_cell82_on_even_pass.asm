; Bank 1 at $4221, the first byte after StepCell82EveryFourthFrame.
;
; $C6D8 is the enable byte opcode $32 stores as $01 and the startup tail
; clears. Zero returns. hMainLoopCounter is incremented once per main-loop
; pass. When its low bit is set, this returns. Otherwise it jumps to
; AdvanceCell82Countdown, so that countdown runs on every even pass while
; the enable byte is nonzero.
;
; hMainLoopCounter is the name from main_loop.asm. AdvanceCell82Countdown
; is the name from advance_cell82_countdown.asm. $C6D8 still has no name.

StepCell82OnEvenPass::
    ld a, [$c6d8]
    and a
    ret z
    ldh a, [hMainLoopCounter]
    and $01
    ret nz
    jp AdvanceCell82Countdown
