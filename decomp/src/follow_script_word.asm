; Script path taken when [$C936] is zero. The caller at $1459 is still
; INCBIN. It jumps here instead of skipping the next two script bytes.
;
; BC addresses a little-endian pointer. The low byte is read first, then
; the high byte. BC becomes that pointer. The stream position is discarded.
;
; Control leaves through DispatchScriptOpcode, which reads the opcode at
; the new BC. DispatchScriptOpcode is the name from reset.asm.

FollowScriptWord::
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [bc]
    ld b, a
    ld c, l
    jp DispatchScriptOpcode
