; Bank 1 at $5F0C, the first byte after RunTwoScriptsThenStoreScreenY.
; rROMB0 is left alone except inside the script calls.
;
; BC already points at a record. LoadRecordHead copies the ten-byte head
; into HRAM. The seven-byte script is loaded, run, and written back, then
; loaded, run, and written back a second time. WriteRecordHead stores the
; ten-byte head and this returns.
;
; LoadRecordHead, LoadScriptBytes, MapScriptBankAndCall, CopyScriptBytes,
; and WriteRecordHead are already source.

RunRecordScriptTwice::
    call LoadRecordHead
    call LoadScriptBytes
    call MapScriptBankAndCall
    call CopyScriptBytes
    call LoadScriptBytes
    call MapScriptBankAndCall
    call CopyScriptBytes
    call WriteRecordHead
    ret
