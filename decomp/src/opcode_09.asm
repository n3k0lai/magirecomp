; Script opcode $09. DispatchScriptOpcode jumps here with BC still pointing
; at the bytes after the opcode.
;
; The first operand is a slot index. LookupScriptIndexPointer returns that
; record in HL. One script byte is stored at record offset $0A. The next two
; script bytes and DispatchScriptOpcode are written at $0B through $0E by
; CopyTwoScriptBytesAndHandler, which returns with HL at offset $11. Three
; more bytes are skipped. $02 $14 is stored at offsets $14 and $15, the same
; pair StoreScriptPair0214 writes, with the $14 left in place rather than
; advanced past. BC is left on the following opcode. Control returns through
; jp DispatchScriptOpcode. What the filled fields mean is still unknown.

Opcode09::
    call LookupScriptIndexPointer
    ld de, $000A
    add hl, de
    ld a, [bc]
    inc bc
    ld [hl+], a
    call CopyTwoScriptBytesAndHandler
    inc hl
    inc hl
    inc hl
    ld a, $02
    ld [hl+], a
    ld [hl], $14
    jp DispatchScriptOpcode
