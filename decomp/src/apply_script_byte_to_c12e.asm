; Bank 1 entry at $45E6. StageScriptByteEnterBank1 jumps here with the
; script byte in E and BC one past that byte.
;
; $C12E through $C131 are cleared. Bits 0 through 3 of E then write $FF
; into $C12E, $C12F, $C130, and $C131. What those four bytes mean is
; still unknown.
;
; BC is stored at hScriptPtr with the 3-byte form, high byte first.
; hScriptHandler becomes INITIAL_SCRIPT_HANDLER ($0A66). Those two
; stores are ldh. Control returns to the caller of
; StageScriptByteEnterBank1.
;
; hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm. Nothing here calls or jumps into an INCBIN.

ApplyScriptByteToC12E::
    ld hl, $C131
    xor a
    ld [hl-], a
    ld [hl-], a
    ld [hl-], a
    ld [hl], a
    cpl
    bit 0, e
    jr z, .bit1
    ld [hl], a
.bit1::
    inc hl
    bit 1, e
    jr z, .bit2
    ld [hl], a
.bit2::
    inc hl
    bit 2, e
    jr z, .bit3
    ld [hl], a
.bit3::
    inc hl
    bit 3, e
    jr z, .plant
    ld [hl], a
.plant::
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ret
