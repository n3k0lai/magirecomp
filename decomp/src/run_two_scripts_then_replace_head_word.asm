; Bank 1 at $635C, the first byte after ResumePlantedUpRecord.
;
; LoadRecordHead copies the ten-byte head and leaves HL on the next
; byte. $C187, the high byte of the word opcode $10 keeps at
; $C186/$C187, is cleared. Two script records then run in order:
; LoadScriptBytes, MapScriptBankAndCall, and CopyScriptBytes, and the
; same three calls again. CopyScriptBytes leaves HL on the following
; record.
;
; SelectWRAM5AdjustRecordHead in bank 5 runs through CallBankedHL.
; When $C187 is not zero, that word replaces the head word: the high
; byte at hRecordHead + 2 and the low byte at hRecordHead + 1.
; WriteRecordHead stores the head and returns.
;
; LoadRecordHead, LoadScriptBytes, MapScriptBankAndCall,
; CopyScriptBytes, CallBankedHL, SelectWRAM5AdjustRecordHead, and
; WriteRecordHead are already source. hRecordHead is the name from
; write_record_head.asm. $C186 and $C187 are the pair from
; opcode_10.asm. ResumePlantedUpRecord is the label in
; resume_planted_up_record.asm.

RunTwoScriptsThenReplaceHeadWord::
    call LoadRecordHead
    xor a
    ld [$c187], a
    call LoadScriptBytes
    call MapScriptBankAndCall
    call CopyScriptBytes
    call LoadScriptBytes
    call MapScriptBankAndCall
    call CopyScriptBytes
    ld hl, SelectWRAM5AdjustRecordHead
    ld e, $05
    call CallBankedHL
    ld a, [$c187]
    and a
    jr z, .keepHeadWord
    ldh [hRecordHead + 2], a
    ld a, [$c186]
    ldh [hRecordHead + 1], a
.keepHeadWord:
    call WriteRecordHead
    ret
