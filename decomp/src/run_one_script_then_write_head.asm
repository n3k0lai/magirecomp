; Bank 1 at $63CE, the first byte after the rDIV map-cell table.
; Opcode11 stores this address as the little-endian word at $FF8D.
;
; LoadRecordHead copies the ten-byte record head at BC into
; $FF8C–$FF95 and leaves HL on the next byte. That byte starts one
; seven-byte script record. LoadScriptBytes, MapScriptBankAndCall, and
; CopyScriptBytes run it and store it back.
;
; Bank 5 at SelectWRAM5AdjustRecordHead then runs through CallBankedHL.
; WriteRecordHead stores $FF8C–$FF95 back through the record pointer.
;
; LoadRecordHead, LoadScriptBytes, MapScriptBankAndCall, CopyScriptBytes,
; CallBankedHL, SelectWRAM5AdjustRecordHead, and WriteRecordHead are
; already source. Opcode11 is the label in opcode_11.asm.

RunOneScriptThenWriteHead::
    call LoadRecordHead
    call LoadScriptBytes
    call MapScriptBankAndCall
    call CopyScriptBytes
    ld hl, SelectWRAM5AdjustRecordHead
    ld e, $05
    call CallBankedHL
    call WriteRecordHead
    ret

RunOneScriptThenWriteHeadEnd:
