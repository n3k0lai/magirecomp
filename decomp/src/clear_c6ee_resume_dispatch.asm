; Script handler planted by Opcode9ACountdown when the $FFA6 count hits 0.
; Bank 1 at $495D. Stores 0 at wUnknownC6EE, then falls into
; ClearScriptBankBit, which clears script-bank bit 7 and points
; hScriptHandler at DispatchScriptOpcode.
;
; wUnknownC6EE is the name from setup_window.asm. The load is the
; two-byte form `ld a, $00`. The store is the three-byte absolute form.

ClearC6EEResumeDispatch::
    ld a, $00
    ld [wUnknownC6EE], a
