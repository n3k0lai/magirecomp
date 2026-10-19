; Script handler planted by Opcode9BHandler. $FFA6 starts at $1A.
;
; Each visit decrements that count. While it stays above zero, the new
; value is stored back and wCallback becomes CopyGlyphBytes ($2949).
; wCallbackBank stays the low nibble Opcode9BHandler wrote.
;
; At zero, wCallbackBank becomes 1 and wCallback becomes $4806 in that
; bank. hScriptHandler becomes $250C, the instruction after
; FinishWindowYSlide stores 2 at wUnknownC6EE. Both paths return.
;
; wCallback and wCallbackBank are the names from default_state.asm.
; hScriptHandler is the name from reset.asm. Every store below is the
; 3-byte form. $FFA6 has no name on this path. Bank 1's $4806 is still
; INCBIN.

Opcode9BCountdownHandler::
    ld a, [$ffa6]
    dec a
    jr z, .expired
    ld [$ffa6], a
    ld a, LOW(CopyGlyphBytes)
    ld [wCallback], a
    ld a, HIGH(CopyGlyphBytes)
    ld [wCallback + 1], a
    ret

.expired:
    ld a, $01
    ld [wCallbackBank], a
    ld a, LOW($4806)
    ld [wCallback], a
    ld a, HIGH($4806)
    ld [wCallback + 1], a
    ld a, LOW($250C)
    ld [hScriptHandler], a
    ld a, HIGH($250C)
    ld [hScriptHandler + 1], a
    ret
