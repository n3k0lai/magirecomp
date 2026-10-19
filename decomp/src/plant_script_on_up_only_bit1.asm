; Bank 1 at $5437. ResumeScriptLowFromARecord jumps here when bit 1 of
; the $c9a3 byte is set. That byte is the copy of wButtonsHeld
; FinishFrame writes. The caller has already required up held and left
; and right clear. Bit 6 is up, bit 5 is left, and bit 4 is right, from
; the high nibble ReadJoypad stores. What bit 1 means is still unknown.
; rROMB0 is left alone.
;
; hRecordHead ($FF8C) becomes $00. hScriptHandler becomes
; INITIAL_SCRIPT_HANDLER ($0A66). hScriptPtr becomes $504D. The
; little-endian word $5456 is written at hRecordHead + 1. $5456 is the
; next routine in this bank (`call $5DE1`, then the up test) and is
; still INCBIN. What the record uses that word for is still unknown.
; $504D falls inside PlantRightPressedHead01Script, which is already
; source. What those bytes mean as a script is still unknown.
;
; Control then jumps to CommitScriptAndRecordHead ($5D9B), which copies
; the script bytes and writes the record head.
;
; hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm. hRecordHead is the name from write_record_head.asm.
; CommitScriptAndRecordHead is the name from plant_handler_and_head_word.asm.
; wButtonsHeld is the name from read_joypad.asm.

; Script planted at hScriptPtr. Lands inside existing source.
DEF ScriptPtr504D EQU $504D

; Next routine in this bank. Still INCBIN. Planted in the record head.
DEF HeadWord5456 EQU $5456

PlantScriptOnUpOnlyBit1::
    ld a, $00
    ldh [hRecordHead], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(ScriptPtr504D)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr504D)
    ldh [hScriptPtr + 1], a
    ld a, LOW(HeadWord5456)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord5456)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead
