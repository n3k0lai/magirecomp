; Script entry at $1A44. Plants .wait as hScriptHandler, then calls
; SaveScriptPtrAndSplitByte. That helper saves BC as hScriptPtr, stores
; the low six bits of [BC] at $FFA7, stores (([BC] & $C0) >> 6) + 1 at
; $FFA6, and leaves BC on that same byte.
;
; .wait is also the fall-through. It decrements $FFA6 and returns while
; the count stays above zero. At zero it calls ReloadHighBitsIntoFFA6,
; which reloads that high-bit count into $FFA6 and advances BC.
;
; Unlike the $1A16 entry, this does not copy a script color word.
; wEntryRecord is set to $01. Bank 7 is mapped and $5C29 is called.
; BC is restored and control jumps to StepBank7CallbackCountdown.
;
; hScriptHandler is the name from reset.asm. The handler stores are the
; 3-byte form. wEntryRecord is the name from record_ptr_from_id.asm.
; wCurrentROMBank and rROMB0 are the names from reset.asm. $FFA6 and
; bank 7's $5C29 are still unnamed. $5C29 is file address $01DC29.

; Bank 7, still INCBIN. CPU address while bank 7 is mapped.
DEF BANK7_CALL_5C29 EQU $07

Call5C29AfterCountdown::
    ld a, LOW(.wait)
    ld [hScriptHandler], a
    ld a, HIGH(.wait)
    ld [hScriptHandler + 1], a
    call SaveScriptPtrAndSplitByte

.wait:
    ldh a, [$FFA6]
    dec a
    ldh [$FFA6], a
    ret nz

    call ReloadHighBitsIntoFFA6
    ld a, $01
    ld [wEntryRecord], a
    push bc
    ld a, BANK7_CALL_5C29
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call ApplyPanelRowAndCopyC7DB
    pop bc
    jp StepBank7CallbackCountdown
