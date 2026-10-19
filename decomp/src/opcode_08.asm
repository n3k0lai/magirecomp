; Script opcode $08. DispatchScriptOpcode jumps here with BC on the
; operand after the opcode.
;
; LookupScriptIndexPointer reads that operand as a slot index and returns
; the record pointer from RecordSlotBases in HL. BC moves past the index.
; Control then leaves through jp $0E09. That tail is still INCBIN, so what
; it does with the record is still unknown.

Opcode08::
    call LookupScriptIndexPointer
    jp $0E09
