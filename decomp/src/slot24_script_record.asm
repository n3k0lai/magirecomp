; Slot $24 of command $4D. SetupCommand4D jumps here and this bank stays mapped.
;
; wUnknownCCA5 picks which five-byte record is written at wThirdScriptRecord.
; A nonzero value stores bank $22 and pointer $4127. Zero stores bank $12 and
; pointer $79D3. Both use INITIAL_SCRIPT_HANDLER ($0A66). What the flag and
; the two scripts do is still unknown. The byte after this routine is a lone
; ret and stays INCBIN.
;
; wUnknownCCA5 is the name from finish_startup.asm. wThirdScriptRecord is the
; name from setup_command_4d.asm. INITIAL_SCRIPT_HANDLER is the name from
; reset.asm.

; Nonzero $CCA5: bank, then little-endian pointer.
DEF SLOT24_SCRIPT_BANK_SET EQU $22
DEF SLOT24_SCRIPT_PTR_SET EQU $4127

; Zero $CCA5: bank, then little-endian pointer.
DEF SLOT24_SCRIPT_BANK_CLEAR EQU $12
DEF SLOT24_SCRIPT_PTR_CLEAR EQU $79D3

WriteSlot24ScriptRecord::
    ld a, [wUnknownCCA5]
    and a
    jr z, .cca5Clear

    ld hl, wThirdScriptRecord
    ld a, SLOT24_SCRIPT_BANK_SET
    ld [hl+], a
    ld a, LOW(SLOT24_SCRIPT_PTR_SET)
    ld [hl+], a
    ld a, HIGH(SLOT24_SCRIPT_PTR_SET)
    ld [hl+], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hl+], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hl+], a
    ret

.cca5Clear:
    ld hl, wThirdScriptRecord
    ld a, SLOT24_SCRIPT_BANK_CLEAR
    ld [hl+], a
    ld a, LOW(SLOT24_SCRIPT_PTR_CLEAR)
    ld [hl+], a
    ld a, HIGH(SLOT24_SCRIPT_PTR_CLEAR)
    ld [hl+], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hl+], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hl+], a
    ret
