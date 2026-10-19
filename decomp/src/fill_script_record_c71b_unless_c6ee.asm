; Script entry at $172B. When [wUnknownC6EE] is already $01, return.
; Otherwise point HL at the script record at $C71B and jump to
; CopyThreeScriptBytesThenDispatch. That routine copies the next three
; script bytes through HL, stores DispatchScriptOpcode in the next two
; bytes, and jumps there.
;
; wUnknownC6EE is the name from setup_window.asm. $C71B is the record
; named wScriptC71BRecord in setup_command_4d.asm. The siblings at $171F
; and $1725 point HL at $C706 and $C70D with no test of $C6EE.
; CopyThreeScriptBytesThenDispatch is the name from
; copy_three_script_bytes_then_dispatch.asm. What $01 in $C6EE means
; here is still unknown.
;
; Nothing this routine calls is still inside an INCBIN.

FillScriptRecordC71BUnlessC6EEIs1::
    ld a, [$C6EE]
    cp $01
    ret z
    ld hl, $C71B
    jp CopyThreeScriptBytesThenDispatch
