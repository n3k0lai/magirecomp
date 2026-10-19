; Script entry at $1725. Point HL at the second seven-byte script record
; ($C70D) and jump to CopyThreeScriptBytesThenDispatch. That routine copies
; the next three script bytes through HL, stores DispatchScriptOpcode in the
; next two bytes, and jumps there.
;
; The record at $C70D is the second of the four records named in
; finish_frame.asm. The sibling at $171F points HL at wScriptRecord ($C706).
; CopyThreeScriptBytesThenDispatch is the name from
; copy_three_script_bytes_then_dispatch.asm.

FillScriptRecordC70DFromScript::
    ld hl, $C70D
    jp CopyThreeScriptBytesThenDispatch
