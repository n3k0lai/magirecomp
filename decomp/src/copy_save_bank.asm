; CopySramBankOntoPair. MirrorAcceptedSave calls this twice. D is the
; source SRAM bank and E is the destination. Each call copies both 4 KiB
; halves of that bank ($A000 and $B000) through the WRAM bank 6 window at
; $D000, then increments D and E so the next call covers the following pair.
;
; Callers know this entry as CopySaveBankPair (see mirror_accepted_save.asm).
; rRAMB is the name from handle_start_press.asm.

; First byte of an SRAM bank, and the second 4 KiB half.
DEF sSaveBankLo EQU $A000
DEF sSaveBankHi EQU $B000

; 4 KiB buffer in the current WRAM bank. Bank 6 is selected by the caller.
DEF wSaveCopyBuffer EQU $D000

; H after the forward fill ($D000-$DFFF) and after the backward drain.
DEF SAVE_COPY_WRAM_END EQU $E0
DEF SAVE_COPY_WRAM_DONE EQU $CF

CopySramBankOntoPair:
    ld bc, sSaveBankLo
    call CopySramHalfThroughWram
    ld bc, sSaveBankHi
    call CopySramHalfThroughWram
    inc e
    inc d
    ret

; Copy $1000 bytes from SRAM [BC] in bank D into WRAM, then write them back
; to the same SRAM addresses in bank E. BC is the start of one half.
CopySramHalfThroughWram:
    ld hl, wSaveCopyBuffer
    ld a, d
    ld [rRAMB], a

.copyToWram:
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, h
    cp SAVE_COPY_WRAM_END
    jr nz, .copyToWram

    ld a, e
    ld [rRAMB], a
    dec bc
    dec hl

.copyToSram:
    ld a, [hl-]
    ld [bc], a
    dec bc
    ld a, [hl-]
    ld [bc], a
    dec bc
    ld a, [hl-]
    ld [bc], a
    dec bc
    ld a, [hl-]
    ld [bc], a
    dec bc
    ld a, h
    cp SAVE_COPY_WRAM_DONE
    jr nz, .copyToSram

    ret
