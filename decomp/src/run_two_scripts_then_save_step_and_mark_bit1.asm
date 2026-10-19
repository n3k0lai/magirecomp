; Bank 1 at $65D7, the first byte after PlantTailScriptHeadWhenCellMatches.
; rROMB0 is left alone except inside MapScriptBankAndCall and CallBankedHL.
;
; BC is a record. LoadRecordHead copies its first ten bytes into
; $FF8C–$FF95 and leaves HL on the next byte. That byte starts a
; seven-byte script record. LoadScriptBytes, MapScriptBankAndCall, and
; CopyScriptBytes run it and store it back. CopyScriptBytes leaves HL
; on the following byte, and the same three calls run that second record.
;
; Bank 5 is mapped and SaveStepThenApplyOrDispatch ($682D) is called
; through CallBankedHL. StageThirdScriptFromMarkedCell may plant the
; third script. Bit 1 of $FFAA is set. FinishFrame copies $FFAA to
; $FFAB and clears it. What bit 1 marks is still unknown. WriteRecordHead
; stores $FF8C–$FF95 back through the record pointer.
;
; LoadRecordHead, LoadScriptBytes, MapScriptBankAndCall, CopyScriptBytes,
; CallBankedHL, SaveStepThenApplyOrDispatch, StageThirdScriptFromMarkedCell,
; and WriteRecordHead are already source.

RunTwoScriptsThenSaveStepAndMarkBit1::
    call LoadRecordHead
    call LoadScriptBytes
    call MapScriptBankAndCall
    call CopyScriptBytes
    call LoadScriptBytes
    call MapScriptBankAndCall
    call CopyScriptBytes
    ld hl, SaveStepThenApplyOrDispatch
    ld e, $05
    call CallBankedHL
    call StageThirdScriptFromMarkedCell
    ld hl, $ffaa
    set 1, [hl]
    call WriteRecordHead
    ret
