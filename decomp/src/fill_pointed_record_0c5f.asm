; Read a little-endian pointer from the script at BC and fill that record,
; then jump to DispatchScriptOpcode.
;
; The first record byte is left unchanged. The next two bytes are stored as
; $0C then $5F, a little-endian word ($5F0C). Two bytes are skipped, two
; script bytes are copied, two more are skipped, and one script byte is
; copied. CopyThreeScriptBytesAndHandler then copies three script bytes,
; plants DispatchScriptOpcode, and skips two. StoreScriptPair0214 skips
; three, stores $02 $14, and skips two.
;
; Which bank $5F0C belongs to is still unknown; this routine does not write
; one. What the skipped fields mean is still unknown. BC ends eight bytes
; past the first read. CopyThreeScriptBytesAndHandler, StoreScriptPair0214,
; and DispatchScriptOpcode are the names from those files.

FillPointedRecord0C5F::
    ld a, [bc]
    inc bc
    ld l, a
    ld a, [bc]
    inc bc
    ld h, a
    inc hl
    ld a, $0C
    ld [hl+], a
    ld a, $5F
    ld [hl+], a
    inc hl
    inc hl
    ld a, [bc]
    inc bc
    ld [hl+], a
    ld a, [bc]
    inc bc
    ld [hl+], a
    inc hl
    inc hl
    ld a, [bc]
    inc bc
    ld [hl+], a
    call CopyThreeScriptBytesAndHandler
    call StoreScriptPair0214
    jp DispatchScriptOpcode
