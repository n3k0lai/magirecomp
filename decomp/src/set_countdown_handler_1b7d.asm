; Script entry at $1B70. The previous routine returns at $1B6F, so this
; is the next uncovered byte.
;
; hScriptHandler ($FFA4) is set to $1B7D, the countdown that follows the
; call. Those two stores are the 3-byte form. SavePtrAndSplitScriptByte
; ($1997) writes BC to hScriptPtr, splits [BC] into $FFA7 (low six bits)
; and $FFA6 (high two bits, swapped, plus one), then leaves BC on that
; same byte.
;
; $FFA6 is then decremented with ldh. A nonzero result returns. Zero falls
; through into the next byte, which stays INCBIN.
;
; hScriptHandler and hScriptPtr are the names from reset.asm.
; SavePtrAndSplitScriptByte is the name from
; arm_countdown_handler_and_dec_ffa6.asm. $FFA6 has no name yet.

SetCountdownHandler1B7D::
    ld a, LOW(.stepCount)
    ld [hScriptHandler], a
    ld a, HIGH(.stepCount)
    ld [hScriptHandler + 1], a
    call SavePtrAndSplitScriptByte

.stepCount::
    ldh a, [$ffa6]
    dec a
    ldh [$ffa6], a
    ret nz
