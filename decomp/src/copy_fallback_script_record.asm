; Copies three script bytes at BC into the fallback script record
; (wFallbackScriptBank and the little-endian pointer at
; wFallbackScriptPtr) and jumps to DispatchScriptOpcode. BC advances
; past those three bytes. SetupCommand4D reads this record when the
; group-list word at $CDAE is zero.
;
; wFallbackScriptBank and wFallbackScriptPtr are the names from
; setup_command_4d.asm. DispatchScriptOpcode is the name from
; dispatch_script_opcode.asm.

CopyFallbackScriptRecord::
    ld hl, wFallbackScriptBank
    ld a, [bc]
    ld [hli], a
    inc bc
    ld a, [bc]
    ld [hli], a
    inc bc
    ld a, [bc]
    ld [hli], a
    inc bc
    jp DispatchScriptOpcode
