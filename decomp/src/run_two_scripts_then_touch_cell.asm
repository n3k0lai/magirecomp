; Bank 1 at $4A8F. Same sequence as RunTwoScriptsFromRecord: LoadRecordHead
; copies the ten-byte record head at BC into $FF8C–$FF95, then the two
; seven-byte script records that follow are loaded, called, and stored
; back. ClearRecordHeadBit5 then runs with WRAM bank 5 mapped.
;
; Bank 5 is mapped and $67A3 is called through CallBankedHL. $4AD5, still
; INCBIN, runs before WriteRecordHead stores $FF8C–$FF95 back through the
; record pointer. From the following bytes, $4AD5 returns at once unless
; bit 1 of hLatchedFFAB ($FFAB) is set. When the byte at the little-endian
; pointer in hMapCellPointer ($FF93) is $00, it writes $08 there and sets
; bit 5 of hRecordHead.
;
; LoadRecordHead, WriteRecordHead, LoadScriptBytes, MapScriptBankAndCall,
; CopyScriptBytes, ClearRecordHeadBit5, and CallBankedHL are already source.

RunTwoScriptsThenTouchCell::
    call LoadRecordHead
    call LoadScriptBytes
    call MapScriptBankAndCall
    call CopyScriptBytes
    call LoadScriptBytes
    call MapScriptBankAndCall
    call CopyScriptBytes
    call ClearRecordHeadBit5
    ld hl, $67A3
    ld e, $05
    call CallBankedHL
    call $4AD5
    call WriteRecordHead
    ret
