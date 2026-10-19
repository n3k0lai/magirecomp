; Bank 1 at $4A6B. BC is a record. LoadRecordHead copies its first ten
; bytes into $FF8C–$FF95 and leaves HL on the next byte. That byte starts
; a seven-byte script record. LoadScriptBytes, MapScriptBankAndCall, and
; CopyScriptBytes run it and store it back. CopyScriptBytes leaves HL on
; the following byte, and the same three calls run that second record.
;
; $4AB6, still INCBIN, then runs with WRAM bank 5 mapped. It clears bit 5
; of the first head byte at $FF8C. When that bit was set, it writes $00
; through the little-endian pointer in $FF93/$FF94.
;
; Bank 5 is mapped and $67A3 is called through CallBankedHL. WriteRecordHead
; stores $FF8C–$FF95 back through the record pointer.
;
; LoadRecordHead, WriteRecordHead, LoadScriptBytes, MapScriptBankAndCall,
; CopyScriptBytes, and CallBankedHL are already source.

RunTwoScriptsFromRecord::
    call LoadRecordHead
    call LoadScriptBytes
    call MapScriptBankAndCall
    call CopyScriptBytes
    call LoadScriptBytes
    call MapScriptBankAndCall
    call CopyScriptBytes
    call $4AB6
    ld hl, $67A3
    ld e, $05
    call CallBankedHL
    call WriteRecordHead
    ret
