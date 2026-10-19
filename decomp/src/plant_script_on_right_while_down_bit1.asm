; Bank 1 at $53A5. ResumeYStepBit1SetRecord jumps here when right is
; held with down. ResumeRightWhileDownRecord also jumps here when bit 1
; of the $c9a3 byte is set. That byte is the copy of wButtonsHeld
; FinishFrame writes. Bit 7 is down and bit 4 is right, from the high
; nibble ReadJoypad stores. What bit 1 means is still unknown. rROMB0
; is left alone.
;
; hRecordHead ($FF8C) becomes $02. hScriptHandler becomes
; INITIAL_SCRIPT_HANDLER ($0A66). hScriptPtr becomes $5091. The
; little-endian word $53C4 is written at hRecordHead + 1. $53C4 is the
; next routine in this bank (`call $5DE1`, then the bit-4 test that
; RightHeldFromBit4 continues) and is still INCBIN. What the record uses
; that word for is still unknown. $5091 is a script address still INCBIN
; in this bank.
;
; Control then jumps to CommitScriptAndRecordHead ($5D9B), which copies
; the script bytes and writes the record head.
;
; hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm. hRecordHead is the name from write_record_head.asm.
; CommitScriptAndRecordHead is the name from plant_handler_and_head_word.asm.
; wButtonsHeld is the name from read_joypad.asm.

; Script planted at hScriptPtr. Still INCBIN in this bank.
DEF ScriptPtr5091 EQU $5091

; Next routine in this bank. Still INCBIN. Planted in the record head.
DEF HeadWord53C4 EQU $53C4

PlantScriptOnRightWhileDownBit1::
    ld a, $02
    ldh [hRecordHead], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(ScriptPtr5091)
    ldh [hScriptPtr], a
    ld a, HIGH(ScriptPtr5091)
    ldh [hScriptPtr + 1], a
    ld a, LOW(HeadWord53C4)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord53C4)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead
