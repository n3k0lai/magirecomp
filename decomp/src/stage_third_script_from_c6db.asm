; Bank 1 at $41AC, the first byte after Unknown_418D.
;
; D is set to $C7, the high byte of wThirdScriptRecord, and then left
; alone. The routine returns while A is still nonzero, and again when
; [wUnknownC6EE] is not zero. That compare is the two-byte `cp $00`.
;
; Otherwise $C6D7 becomes $FF and the three bytes at $C6DB-$C6DD are
; copied to the bank and little-endian pointer of wThirdScriptRecord.
; The handler there becomes INITIAL_SCRIPT_HANDLER ($0A66). $C6D7 and
; $C6DB have no names yet. What reads D afterward is still unknown.
;
; wThirdScriptRecord is the name from setup_command_4d.asm.
; wUnknownC6EE is the name from setup_window.asm.
; INITIAL_SCRIPT_HANDLER is the name from reset.asm.

StageThirdScriptFromC6DB::
    ld d, $C7
    and a
    ret nz
    ld a, [wUnknownC6EE]
    cp $00
    ret nz
    ld a, $FF
    ld [$c6d7], a
    ld a, [$c6db]
    ld [wThirdScriptRecord], a
    ld a, [$c6dc]
    ld [wThirdScriptRecord + 1], a
    ld a, [$c6dd]
    ld [wThirdScriptRecord + 2], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [wThirdScriptRecord + 3], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [wThirdScriptRecord + 4], a
    ret

StageThirdScriptFromC6DBEnd:
