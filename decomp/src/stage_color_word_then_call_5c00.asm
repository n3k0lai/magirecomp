; Script entry at $1A16. Plants .wait as hScriptHandler, then calls
; $1997. That routine, still INCBIN, saves BC as hScriptPtr, stores the
; low six bits of [BC] at $FFA7, stores (([BC] & $C0) >> 6) + 1 at $FFA6,
; and leaves BC on that same byte.
;
; .wait is also the fall-through. It decrements $FFA6 and returns while
; the count stays above zero. At zero it calls $19AD, which reloads that
; high-bit count into $FFA6 and advances BC, then $19B9. $19B9 copies the
; next two script bytes to wUnknownC9DA (low, high). If bit 7 of the high
; byte is set, it replaces that word with the word at $C9E5.
;
; wEntryRecord is then set to $01. Bank 7 is mapped and $5C00 is called.
; BC is restored and control jumps to StepBank7CallbackCountdown.
;
; hScriptHandler is the name from reset.asm. The handler stores are the
; 3-byte form. wUnknownC9DA is the name from dispatch_nonzero_d016.asm.
; wEntryRecord is the name from record_ptr_from_id.asm. wCurrentROMBank
; and rROMB0 are the names from reset.asm. $FFA6, $FFA7, $C9E5, $1997,
; $19AD, $19B9, and bank 7's $5C00 are still unnamed. $5C00 is file
; address $01DC00.

; Bank 7, still INCBIN. CPU address while bank 7 is mapped.
DEF BANK7_COLOR_CALL EQU $07

StageColorWordThenCall5C00::
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
    call CopyNextScriptWordOrC9E5
    ld a, $01
    ld [wEntryRecord], a
    push bc
    ld a, BANK7_COLOR_CALL
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call StepStagedColorAndCopyC7DB
    pop bc
    jp StepBank7CallbackCountdown
