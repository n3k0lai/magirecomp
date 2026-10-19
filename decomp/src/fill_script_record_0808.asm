; Skip one byte of the record at HL, copy two script bytes from BC, store
; $08 $08, copy five more script bytes, then jump to
; CopyThreeScriptBytesAndHandler.
;
; The first record byte is left unchanged. Each copied script byte uses the
; auto-increment form, so HL ends on the byte after the fifth copy and BC
; ends seven bytes past the first read. The jump copies three more script
; bytes, stores DispatchScriptOpcode, and skips two record bytes. What the
; skipped byte and the $08 pair mean is still unknown. Opcode05 calls this
; through the address constant FillScriptRecord08.

FillScriptRecord0808::
    inc hl
    ld a, [bc]
    inc bc
    ld [hl+], a
    ld a, [bc]
    inc bc
    ld [hl+], a
    ld a, $08
    ld [hl+], a
    ld a, $08
    ld [hl+], a
    ld a, [bc]
    inc bc
    ld [hl+], a
    ld a, [bc]
    inc bc
    ld [hl+], a
    ld a, [bc]
    inc bc
    ld [hl+], a
    ld a, [bc]
    inc bc
    ld [hl+], a
    ld a, [bc]
    inc bc
    ld [hl+], a
    jp CopyThreeScriptBytesAndHandler
