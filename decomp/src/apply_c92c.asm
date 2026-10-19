; Pass the byte at $C92C to $4320 and return.
;
; $0655 is a second entry. A is already the argument there. This routine
; does not write rROMB0, so $4320 runs in whatever bank the caller mapped.
; handle_start_press.asm names the byte wUnknownC92C and stores 6 there.
; Callers after this ret, still INCBIN, load or update that byte and call
; here.

ApplyC92C::
    ld a, [$C92C]
; $0655. A is the argument for $4320.
.with_a:
    call $4320
    ret
