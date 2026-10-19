; Bank 1 at $64D1. StageScratchThenPlantHeadWord64D1 plants this
; address as the little-endian head word at record byte 1.
;
; LoadRecordHead copies the ten-byte head and leaves HL on the next
; byte. That address is stored at hScriptDest with the 3-byte form,
; high byte first. The two seven-byte script slots that follow are
; skipped ($000E). The three bytes after them are the script bank and
; the little-endian pointer. hScriptHandler is forced to
; DispatchScriptOpcode ($0A66). MapScriptBankAndCall runs that handler
; and CopyScriptBytes writes the seven HRAM script bytes back through
; hScriptDest, over the first script slot. $FFA6 and $FFA7 were not
; loaded here, so those two written bytes are whatever HRAM already held.
;
; LoadScriptBytes then takes the seven bytes that begin at the end of
; this $1B-byte record, and the same run-and-copy pair runs that
; script. ClearRecordHeadBit5 clears bit 5 of hRecordHead. Bank 5 is
; mapped and $67A3 is called through CallBankedHL. The head word at
; hRecordHead + 1 becomes RunTwoScriptsFromRecord ($4A6B).
; WriteRecordHead stores the ten head bytes back. $651A, still INCBIN
; in this bank, runs next and this returns.
;
; LoadRecordHead, WriteRecordHead, LoadScriptBytes, MapScriptBankAndCall,
; CopyScriptBytes, ClearRecordHeadBit5, CallBankedHL, and
; DispatchScriptOpcode are already source. hScriptDest is the name from
; finish_startup.asm. hScriptBank, hScriptPtr, and hScriptHandler are
; the names from reset.asm. hRecordHead is the name from
; write_record_head.asm. rROMB0 is left alone except inside the calls.

; Bytes from the end of the ten-byte head to the three-byte tail.
DEF RECORD_TAIL_SKIP EQU $000E

; Bank 5 at $67A3 while that bank is mapped. File address $167A3.
DEF Bank5AfterTwoScripts EQU $67A3

RunTailScriptThenPlantTwoScripts::
    call LoadRecordHead
    ld a, h
    ld [hScriptDest + 1], a
    ld a, l
    ld [hScriptDest], a
    ld de, RECORD_TAIL_SKIP
    add hl, de
    ld a, [hl+]
    ldh [hScriptBank], a
    ld a, [hl+]
    ldh [hScriptPtr], a
    ld a, [hl+]
    ldh [hScriptPtr + 1], a
    ld a, LOW(DispatchScriptOpcode)
    ldh [hScriptHandler], a
    ld a, HIGH(DispatchScriptOpcode)
    ldh [hScriptHandler + 1], a
    call MapScriptBankAndCall
    call CopyScriptBytes
    call LoadScriptBytes
    call MapScriptBankAndCall
    call CopyScriptBytes
    call ClearRecordHeadBit5
    ld hl, Bank5AfterTwoScripts
    ld e, $05
    call CallBankedHL
    ld a, LOW(RunTwoScriptsFromRecord)
    ldh [hRecordHead + 1], a
    ld a, HIGH(RunTwoScriptsFromRecord)
    ldh [hRecordHead + 2], a
    call WriteRecordHead
    call FillFirstRecordScriptSlots
    ret
