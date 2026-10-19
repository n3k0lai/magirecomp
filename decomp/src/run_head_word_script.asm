; Bank 1 at $5DB5. PlantHandlerAndHeadWord stores this address as the
; little-endian word at hRecordHead + 1. PlantOtherRightCellScript
; stores $5DB9 as hScriptPtr. That address is the store below, after
; xor a. rROMB0 is left alone except inside the calls.
;
; LoadRecordHead copies the ten-byte head. $C187, the high byte of the
; word opcode $10 keeps at $C186/$C187, is cleared. One script record
; is loaded, run, and stored back. SelectWRAM5AdjustRecordHead in bank
; 5 runs through CallBankedHL, then the camera is nudged past the
; follow edge.
;
; When $C187 is not zero, that word replaces the head word: the high
; byte at hRecordHead + 2 and the low byte at hRecordHead + 1.
; WriteRecordHead stores the head and returns.
;
; LoadRecordHead, LoadScriptBytes, MapScriptBankAndCall,
; CopyScriptBytes, CallBankedHL, SelectWRAM5AdjustRecordHead,
; NudgeCameraPastFollowEdge, and WriteRecordHead are already source.
; hRecordHead is the name from write_record_head.asm. $C186 and $C187
; are the pair from opcode_10.asm. PlantHandlerAndHeadWord and
; PlantOtherRightCellScript name the two planters.

RunHeadWordScript::
    call LoadRecordHead
    xor a
; $5DB9, planted as hScriptPtr from PlantOtherRightCellScript.
    ld [$c187], a
    call LoadScriptBytes
    call MapScriptBankAndCall
    call CopyScriptBytes
    ld hl, SelectWRAM5AdjustRecordHead
    ld e, $05
    call CallBankedHL
    call NudgeCameraPastFollowEdge
    ld a, [$c187]
    and a
    jr z, .keepHeadWord
    ldh [hRecordHead + 2], a
    ld a, [$c186]
    ldh [hRecordHead + 1], a
.keepHeadWord:
    call WriteRecordHead
    ret
