; Bank 1 at $56C9. Taken from $594C when bit 6 of $c9a3 is clear.
; rROMB0 is left alone.
;
; hScriptHandler becomes INITIAL_SCRIPT_HANDLER ($0A66), the script
; dispatcher from reset.asm. The little-endian word $56DC is written at
; $FF8D. That is hRecordHead + 1: hRecordPointer is $FF8A and the ten
; head bytes copied by WriteRecordHead start at $FF8C. $56DC is the next
; byte in this bank and is still INCBIN. What the record uses that word
; for is still unknown.
;
; Control then jumps to CommitScriptRecord, which copies the seven HRAM
; script bytes at $FFA1 and writes the record head.
;
; hScriptHandler and INITIAL_SCRIPT_HANDLER are the names from reset.asm.
; hRecordHead is the name from write_record_head.asm. CommitScriptRecord
; is the name from commit_script_and_record_head.asm.

; Next bytes in this bank. Still INCBIN. Planted in the record head.
DEF HeadWord56DC EQU $56DC

PlantHandlerWhenUpClear::
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(HeadWord56DC)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord56DC)
    ldh [hRecordHead + 2], a
    jp CommitScriptRecord
