; Tail of script opcode $12. Opcode12 stores the commit state at $C188
; and $10, $5E at $C18A, $C18B, then jumps here.
;
; $C6F4 is set to 1. Its role is still unknown. The script pointer is set
; to $0000 and the handler to this routine, both with ldh, and each store
; reloads A from an immediate. The bank at hScriptBank is left alone.
; The next pass through hScriptHandler enters here again and writes the
; same record. Those four bytes are the 00 00 02 14 pattern WriteQuadRecords
; stores at $C70E and $C71C.
;
; hScriptPtr and hScriptHandler are the names from reset.asm.

; Set to 1 here. The clear at $28A9 starts at the next byte.
DEF wFlagC6F4 EQU $C6F4

InstallParkedScript::
    ld a, $01
    ld [wFlagC6F4], a
    ld a, $00
    ldh [hScriptPtr], a
    ld a, $00
    ldh [hScriptPtr + 1], a
    ld a, LOW(InstallParkedScript)
    ldh [hScriptHandler], a
    ld a, HIGH(InstallParkedScript)
    ldh [hScriptHandler + 1], a
    ret
