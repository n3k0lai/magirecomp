; Script entry at $1BD2. The previous routine returns at $1BD1, so this
; is the next uncovered byte.
;
; $CCA6 is set to 1. Its role is still unknown. hScriptHandler ($FFA4)
; is set to $1BE4, the countdown that follows the call. Those two stores
; are the 3-byte form. SaveScriptPtrAndSplitByte ($1997) writes BC to
; hScriptPtr, splits [BC] into $FFA7 (low six bits) and $FFA6 (high two
; bits, swapped, plus one), then leaves BC on that same byte.
;
; $FFA6 is then decremented with ldh. A nonzero result returns. Zero falls
; through into the next byte, which stays INCBIN.
;
; hScriptHandler and hScriptPtr are the names from reset.asm.
; SaveScriptPtrAndSplitByte is the name from
; save_script_ptr_and_split_byte.asm. $CCA6 and $FFA6 have no names yet.

SetCCA6Countdown1BE4::
    ld a, $01
    ld [$cca6], a
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
