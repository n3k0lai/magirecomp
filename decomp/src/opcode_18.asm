; Script opcode $18. DispatchScriptOpcode jumps here with BC still pointing
; at the bytes after the opcode.
;
; The next script byte is stored at hSpriteTileBase ($FF95) with ldh, and
; BC advances past it. queue_sprite_list.asm adds that byte to each record's
; tile when a sprite list is queued. Control leaves through
; jp DispatchScriptOpcode ($0A66).

Opcode18::
    ld a, [bc]
    inc bc
    ldh [hSpriteTileBase], a
    jp DispatchScriptOpcode
