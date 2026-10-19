; Script opcode $05. DispatchScriptOpcode jumps here with BC still pointing
; at the bytes after the opcode.
;
; The first operand is an index. LookupIndexedPointer doubles it and returns
; the word from the table at $0303 in HL. $0ABD, still INCBIN, skips the
; first record byte, copies two script bytes, stores $08 $08, copies five
; more script bytes, then jumps to CopyThreeScriptBytesAndHandler. That
; copies three script bytes, stores DispatchScriptOpcode, and skips two
; record bytes. HL is then seventeen bytes into the record.
;
; StoreScriptPair0214 skips three bytes, stores $02 $14, and skips two more.
; CopyThreeScriptBytes copies the next three script bytes. BC is left on the
; following opcode. Control returns through jp DispatchScriptOpcode. What
; the filled fields mean is still unknown.
;
; LookupIndexedPointer is the name from opcode_03.asm.

; Bank 0, still INCBIN. Fills the record at HL from the script at BC.
DEF FillScriptRecord08 EQU $0ABD

Opcode05::
    call LookupIndexedPointer
    call FillScriptRecord08
    call StoreScriptPair0214
    call CopyThreeScriptBytes
    jp DispatchScriptOpcode
