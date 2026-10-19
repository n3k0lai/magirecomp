; Script entry at $1ADB, the first byte of this hole.
;
; hScriptHandler ($FFA4) is set to $1AE8, the countdown that follows the
; call. Those two stores are the 3-byte form. SaveScriptPtrAndSplitByte
; writes BC to hScriptPtr, splits [BC] into $FFA7 (low six bits) and
; $FFA6 (high two bits, swapped, plus one), then leaves BC on that same
; byte.
;
; $FFA6 is then decremented with ldh. A nonzero result returns. Zero falls
; through into the next byte, which stays INCBIN.
;
; hScriptHandler and hScriptPtr are the names from reset.asm. $FFA6 has no
; name yet.

ArmCountdown1AE8AndDecFFA6::
    ld a, LOW(.stepCount)
    ld [hScriptHandler], a
    ld a, HIGH(.stepCount)
    ld [hScriptHandler + 1], a
    call SaveScriptPtrAndSplitByte

.stepCount::
    ldh a, [$ffa6]
    dec a
    ldh [$ffa6], a
    ret nz
