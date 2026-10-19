; Script entry at $1B0E. The previous routine jumps away at $1B0B, so this
; is the next uncovered byte.
;
; hScriptHandler ($FFA4) is set to $1B1B, the countdown that follows the
; call. Those two stores are the 3-byte form. $1997, still INCBIN, writes
; BC to hScriptPtr, splits [BC] into $FFA7 (low six bits) and $FFA6 (high
; two bits, swapped, plus one), then leaves BC on that same byte.
;
; $FFA6 is then decremented with ldh. A nonzero result returns. Zero falls
; through into the next byte, which stays INCBIN.
;
; hScriptHandler and hScriptPtr are the names from reset.asm. $FFA6 has no
; name yet.

; Bank 0, still INCBIN. Saves BC and loads the two count bytes from [BC].
DEF SavePtrAndSplitScriptByte EQU $1997

ArmCountdownHandlerAndDecFFA6::
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
