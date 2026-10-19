; Bank 1 at $5F25, the first byte after RunRecordScriptTwice.
; rROMB0 is left alone.
;
; Bit 0 of $C932 must be set, and the byte at HL must be $00. Either
; miss returns to the caller. $C932 is the action mask from
; DispatchMaskedAction. What bit 0 selects is still unknown.
;
; On a hit, $C12B becomes $01 and $C12A becomes $00. HL is saved
; little-endian at $C190 (the word MatchWRAM5ScriptByte compares).
; B is stored at $C18E and C at $C18F, the script-base word from
; opcode $02. The return address is popped, so the caller does not
; resume.
;
; hScriptBank becomes $22. hScriptHandler becomes
; INITIAL_SCRIPT_HANDLER ($0A66). hScriptPtr becomes $40AD. The
; little-endian word $6405 is written at hRecordHead + 1. What the
; record uses that word for is still unknown. $40AD is a script
; pointer; this routine does not map bank $22 and does not call it.
;
; Control then jumps to CommitScriptRecord, which copies the seven
; HRAM script bytes and writes the record head.
;
; hScriptBank, hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER
; are the names from reset.asm. hRecordHead is the name from
; write_record_head.asm. CommitScriptRecord is the name from
; commit_script_and_record_head.asm. $C18E is the name from
; center_fine_scroll_on_script_base.asm. $C190 is the name from
; match_wram5_script_byte.asm.

; Script pointer planted at hScriptPtr. Bank $22 is not mapped here.
DEF ScriptPtr40AD EQU $40AD

; Word planted at hRecordHead + 1. What it addresses is still unknown.
DEF HeadWord6405 EQU $6405

PlantBank22ScriptOnZeroByte::
    ld a, [$c932]
    bit 0, a
    ret z

    ld a, [hl]
    cp $00
    ret nz

    ld a, $01
    ld [$c12b], a
    xor a
    ld [$c12a], a
    ld a, h
    ld [$c191], a
    ld a, l
    ld [$c190], a
    ld hl, $c18e
    ld a, b
    ld [hl+], a
    ld [hl], c
    pop hl
    ld a, $22
    ldh [hScriptBank], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(ScriptPtr40AD)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr40AD)
    ldh [hScriptPtr + 1], a
    ld a, LOW(HeadWord6405)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord6405)
    ldh [hRecordHead + 2], a
    jp CommitScriptRecord
