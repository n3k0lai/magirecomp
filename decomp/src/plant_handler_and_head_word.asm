; Bank 1 at $5DA2. StampMapCellInWramBanks jumps here after the bank 7
; call, and other tails in this bank jump here too.
;
; hScriptHandler becomes INITIAL_SCRIPT_HANDLER ($0A66), the script
; dispatcher from reset.asm. The little-endian word $5DB5 is written at
; $FF8D. That is hRecordHead + 1: hRecordPointer is $FF8A and the ten
; head bytes copied by WriteRecordHead start at $FF8C. $5DB5 is the next
; routine in this bank and is still INCBIN. What the record uses that
; word for is still unknown.
;
; Control then jumps to $5D9B, still INCBIN. That tail calls $290A (copy
; the seven HRAM script bytes at $FFA1) and WriteRecordHead, then returns.
;
; hScriptHandler and INITIAL_SCRIPT_HANDLER are the names from reset.asm.
; hRecordHead is the name from write_record_head.asm.

; Next routine in this bank. Still INCBIN. Planted in the record head.
DEF HeadWord5DB5 EQU $5DB5

; Shared tail in this bank. Still INCBIN.
DEF CommitScriptAndRecordHead EQU $5D9B

PlantHandlerAndHeadWord::
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, LOW(HeadWord5DB5)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord5DB5)
    ldh [hRecordHead + 2], a
    jp CommitScriptAndRecordHead
